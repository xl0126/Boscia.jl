
function MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveFunctionType)
    return MOI.get(optimizer.model, attr)
end

# ScalarAffineFunction objective
function MOI.set(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}},
    func::MOI.ScalarAffineFunction{Float64},
)
    MOI.set(optimizer.model, attr, func)
    return
end

function MOI.get(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}},
)
    return MOI.get(optimizer.model, attr)
end

function MOI.supports(::Optimizer, ::MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}})
    return true
end

# ScalarQuadraticFunction
function MOI.set(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}},
    func::MOI.ScalarQuadraticFunction{Float64},
)
    MOI.set(optimizer.model, attr, func)
    return
end

function MOI.get(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}},
)
    return MOI.get(optimizer.model, attr)
end

function MOI.supports(::Optimizer, ::MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}})
    return true
end

# ObjectiveSense
function MOI.set(optimizer::Optimizer, attr::MOI.ObjectiveSense, sense::MOI.OptimizationSense)
    MOI.set(optimizer.model, attr, sense)
    return
end

function MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveSense)
    return MOI.get(optimizer.model, attr)
end
