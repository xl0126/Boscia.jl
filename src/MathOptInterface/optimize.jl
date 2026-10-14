"""
    validate_model(optimizer::Optimizer)

Check that the model stored in `optimizer` can be solved by Boscia, and throw
an error otherwise.

The following conditions are checked:

1. The objective sense is `MOI.MIN_SENSE` or `MOI.MAX_SENSE`.
2. The objective function is a `MOI.ScalarQuadraticFunction{Float64}` or a
   `MOI.ScalarNonlinearFunction`.
3. Every constraint type `(F, S)` in the model is supported, as reported by
   `MOI.supports_constraint`.

This function is called at the start of [`MOI.optimize!`](@ref), so that
unsupported models fail early with a clear message, before any LMO is built.
"""
function validate_model(optimizer::Optimizer)
    # Objective sense: feasibility problems (FEASIBILITY_SENSE) are not supported.
    sense = MOI.get(optimizer, MOI.ObjectiveSense())
    if sense != MOI.MAX_SENSE && sense != MOI.MIN_SENSE
        error("Unsupported objective sense: $sense")
    end

    objective_type = MOI.get(optimizer, MOI.ObjectiveFunctionType())
    if objective_type != MOI.ScalarQuadraticFunction{Float64} &&
       objective_type != MOI.ScalarNonlinearFunction
        error("Unsupported objective type: $objective_type")
    end


    constraint_types = MOI.get(optimizer.model, MOI.ListOfConstraintTypesPresent())
    for (F, S) in constraint_types
        if !MOI.supports_constraint(optimizer, F, S)
            error("Unsupported constraint type: F=$F, S=$S")
        end
    end

    return
end

"""
    MOI.optimize!(optimizer::Optimizer)

Solve the model stored in `optimizer` with Boscia.

The solve proceeds in the following steps:

1. Discard results from any previous solve.
2. Validate the model with [`validate_model`](@ref).
3. Build Boscia settings from `create_default_settings()` and the optimizer
   attributes (`MOI.Silent`, `MOI.TimeLimitSec`).
4. Build the objective oracles `f` and `grad!` from the objective.
5. Build the LMO from the feasible region (constraints and variable bounds).
6. Call `Boscia.solve`.
7. Store the termination status, primal status, objective value and
   variable values, so that they can be queried through MOI.

If Boscia does not find a solution (for example, because the time or node
limit is reached first), the termination status is still set, but
`MOI.PrimalStatus` is `MOI.NO_SOLUTION` and no variable values are available.
"""
function MOI.optimize!(optimizer::Optimizer)
    # discard results from any previous solve. Otherwise, if this solve
    # fails or finds no solution, stale results from the previous model
    # would still be reported.
    optimizer.termination_status = MOI.OPTIMIZE_NOT_CALLED
    optimizer.raw_status_string = ""
    optimizer.primal_status = MOI.NO_SOLUTION
    optimizer.objective_value = nothing
    optimizer.variable_primal = Float64[]

    validate_model(optimizer)

    # Start from Boscia's defaults and override them with the values set
    # through MOI attributes.
    settings = Boscia.create_default_settings()
    settings.branch_and_bound[:verbose] = !optimizer.silent
    if optimizer.timeout !== nothing
        settings.branch_and_bound[:time_limit] = optimizer.timeout
    end

    # Objective -> Frank-Wolfe oracles. MAX_SENSE is handled inside the
    # oracles by negating f and grad!, so Boscia always minimizes.
    f, grad! = build_objective_oracles(optimizer)

    # Feasible region -> LMO (inner MIP solver).
    feasible_region_data = build_feasible_region(optimizer)
    lmo = build_lmo(optimizer.backend, feasible_region_data)

    # Report an empty feasible region as INFEASIBLE instead of letting
    # Boscia.solve fail on its first LMO call.
    feasibility_status = check_feasibility(lmo)
    if feasibility_status == MOI.INFEASIBLE || feasibility_status == MOI.INFEASIBLE_OR_UNBOUNDED
        optimizer.termination_status = MOI.INFEASIBLE
        optimizer.raw_status_string = "Infeasible"
        return
    end

    x, _, result = Boscia.solve(f, grad!, lmo; settings=settings)

    # The status is reported whether or not a solution was found.
    optimizer.raw_status_string = result[:status_string]

    # Boscia returns `x === nothing` if no solution was found, e.g. when the
    # time or node limit is reached first. In that case the result fields
    # keep their "no solution" values set at the start of this function.
    if x !== nothing
        optimizer.variable_primal = copy(x)
        optimizer.primal_status = MOI.FEASIBLE_POINT

        # Boscia minimized the (possibly negated) objective, so the sign is
        # flipped back for MAX_SENSE to report the user's objective value.
        sense = MOI.get(optimizer, MOI.ObjectiveSense())
        if sense == MOI.MIN_SENSE
            optimizer.objective_value = result[:primal_objective]
        elseif sense == MOI.MAX_SENSE
            optimizer.objective_value = -result[:primal_objective]
        end
    end

    # Map Boscia's solving stage to an MOI termination status.
    status = result[:status]
    if status == OPT_TREE_EMPTY
        # All nodes were processed: the solution is proven optimal.
        optimizer.termination_status = MOI.OPTIMAL
    elseif status == OPT_GAP_REACHED
        # The gap tolerance was met: optimal up to the tolerance.
        optimizer.termination_status = MOI.OPTIMAL
    elseif status == TIME_LIMIT_REACHED
        optimizer.termination_status = MOI.TIME_LIMIT
    elseif status == NODE_LIMIT_REACHED
        optimizer.termination_status = MOI.NODE_LIMIT
    elseif status == USER_STOP
        optimizer.termination_status = MOI.INTERRUPTED
    end

    return
end
