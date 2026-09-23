# Validation
function validate_model(optimizer::Optimizer)
    # sense
    sense = MOI.get(optimizer, MOI.ObjectiveSense())

    if sense != MOI.MAX_SENSE && sense != MOI.MIN_SENSE 
        error("Unsupported objective sense: $sense")
    end

    # objective_type
    objective_type = MOI.get(
        optimizer,
        MOI.ObjectiveFunctionType(),
    )

    if objective_type != MOI.ScalarAffineFunction{Float64} && objective_type != MOI.ScalarQuadraticFunction{Float64}
        error("Unsupported objective type: $objective_type")
    end

    #constraints
    constraint_types = MOI.get(
        optimizer.model,
        MOI.ListOfConstraintTypesPresent(),
    )

    for (F, S) in constraint_types
        if !MOI.supports_constraint(optimizer, F, S)
            error("Unsupported constraint type: F=$F, S=$S")
        end
    end


    return 
end


function MOI.optimize!(optimizer:: Optimizer)
    # Validation
    validate_model(optimizer)

    # settings
    settings = Boscia.create_default_settings()

    settings.branch_and_bound[:verbose] = !optimizer.silent

    if optimizer.timeout !==nothing
        settings.branch_and_bound[:time_limit] = optimizer.timeout
    end

    # objective -> f, gard!
    f, grad! = build_objective_oracles(optimizer)
    
    # lmo
    feasible_region_data = build_feasible_region(optimizer)
    lmo = build_lmo(
        optimizer.backend,
        feasible_region_data,
    )

    # solve
    x, _, result = Boscia.solve(
        f, 
        grad!,
        lmo;
        settings = settings,
    )

    # map result
    optimizer.variable_primal = copy(x)
    optimizer.raw_status_string = result[:status_string]
    optimizer.primal_status = MOI.FEASIBLE_POINT

    # objective_value
    sense = MOI.get(optimizer, MOI.ObjectiveSense())
    if sense == MOI.MIN_SENSE
        optimizer.objective_value = result[:primal_objective]
    elseif sense == MOI.MAX_SENSE
        optimizer.objective_value = -result[:primal_objective]
    end

    # termination_status
    status = result[:status]
    if status == OPT_TREE_EMPTY
        optimizer.termination_status = MOI.OPTIMAL
    elseif status == OPT_GAP_REACHED
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