# termination_status
function MOI.get(
    optimizer::Optimizer,
    ::MOI.TerminationStatus,
)
    return optimizer.termination_status
end

# raw_status_string
function MOI.get(
    optimizer::Optimizer,
    ::MOI.RawStatusString,
)
    return optimizer.raw_status_string
end

# primal_status
function MOI.get(
    optimizer::Optimizer,
    ::MOI.PrimalStatus,
)
    return optimizer.primal_status
end

# objective_value
function MOI.get(
    optimizer::Optimizer,
    ::MOI.ObjectiveValue,
)
    return optimizer.objective_value
end

# variable_primal
function MOI.get(
    optimizer::Optimizer,
    ::MOI.VariablePrimal,
    varibale::MOI.VariableIndex,
)
    return optimizer.variable_primal[varibale.value]
end