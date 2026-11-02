"""
    validate_zero_one_hypercube(model, constraint_types)

Check the rules for models with a `ZeroOneHypercube` constraint.
"""
function validate_zero_one_hypercube(model, constraint_types)
    cis = MOI.get(model, MOI.ListOfConstraintIndices{MOI.VectorOfVariables,ZeroOneHypercube}())
    if length(cis) > 1
        error("Only one ZeroOneHypercube constraint is supported.")
    end

    func = MOI.get(model, MOI.ConstraintFunction(), only(cis))
    all_variables = MOI.get(model, MOI.ListOfVariableIndices())
    if length(func.variables) != length(all_variables) || Set(func.variables) != Set(all_variables)
        error(
            "The ZeroOneHypercube constraint must contain every variable of the model exactly once.",
        )
    end

    allowed = [
        (MOI.VectorOfVariables, ZeroOneHypercube),
        (MOI.VariableIndex, MOI.Integer),
        (MOI.VariableIndex, MOI.ZeroOne),
    ]
    for (F, S) in constraint_types
        if !((F, S) in allowed)
            error(
                "A ZeroOneHypercube constraint cannot be combined with $F-in-$S constraints; intersections of sets are not supported.",
            )
        end
    end

    return
end


"""
    validate_model(optimizer::Optimizer)

Check that the model stored in `optimizer` can be solved by Boscia, and throw
an error or a warning otherwise.
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

    if objective_type == MOI.ScalarQuadraticFunction{Float64}
        obj = MOI.get(optimizer, MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}}())
        if isempty(obj.quadratic_terms)
            error("Boscia does not support linear objectives; use a MIP solver instead.")
        end
    end

    constraint_types = MOI.get(optimizer.model, MOI.ListOfConstraintTypesPresent())
    for (F, S) in constraint_types
        if !MOI.supports_constraint(optimizer, F, S)
            error("Unsupported constraint type: F=$F, S=$S")
        end
    end

    # ZeroOneHypercubeLMO only knows the hypercube: reject any other constraint.
    if has_zero_one_hypercube(optimizer.model)
        validate_zero_one_hypercube(optimizer.model, constraint_types)
    end

    return

end

"""
    MOI.optimize!(optimizer::Optimizer)

Solve the model stored in `optimizer` with Boscia.
"""
function MOI.optimize!(optimizer::Optimizer)
    optimizer.termination_status = MOI.OPTIMIZE_NOT_CALLED
    optimizer.raw_status_string = ""
    optimizer.primal_status = MOI.NO_SOLUTION
    optimizer.objective_value = nothing
    optimizer.variable_primal = Float64[]

    validate_model(optimizer)

    settings = Boscia.create_default_settings()
    settings.branch_and_bound[:verbose] = !optimizer.silent
    if optimizer.timeout !== nothing
        settings.branch_and_bound[:time_limit] = optimizer.timeout
    end

    f, grad! = build_objective_oracles(optimizer)

    if has_zero_one_hypercube(optimizer.model)
        lmo = build_zero_one_hypercube_lmo(optimizer.model)
    else
        feasible_region_data = build_feasible_region(optimizer)
        lmo = build_lmo(optimizer.backend, feasible_region_data)
    end

    # Report an empty feasible region as INFEASIBLE instead of letting
    # Boscia.solve fail on its first LMO call.
    feasibility_status = check_feasibility(lmo)
    if feasibility_status == MOI.INFEASIBLE ||
       feasibility_status == MOI.INFEASIBLE_OR_UNBOUNDED ||
       feasibility_status == INFEASIBLE
        optimizer.termination_status = MOI.INFEASIBLE
        optimizer.raw_status_string = "Infeasible"
        return
    end

    x, _, result = Boscia.solve(f, grad!, lmo; settings=settings)

    # The status is reported whether or not a solution was found.
    optimizer.raw_status_string = result[:status_string]

    # Returns `x === nothing` if no solution was found, e.g. when the
    # time or node limit is reached first. In that case the result fields
    # keep their "no solution" values set at the start of this function.
    if x !== nothing
        optimizer.variable_primal = copy(x)
        optimizer.primal_status = MOI.FEASIBLE_POINT

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
