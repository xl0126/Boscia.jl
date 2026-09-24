import MathOptInterface as MOI

# SolverName
function MOI.get(model::Optimizer, ::MOI.SolverName)
    return "Boscia"
end

# SolverVersion
function MOI.get(model::Optimizer, ::MOI.SolverVersion)
    return
end

# RawSolver
function MOI.get(model::Optimizer, ::MOI.RawSolver)
    return
end

# Name 
function MOI.get(model::Optimizer, ::MOI.Name)
    return
end

function MOI.set(model::Optimizer, ::MOI.Name, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.Name) = true

# Silent 
function MOI.get(model::Optimizer, ::MOI.Silent)
    return model.silent
end

function MOI.set(model::Optimizer, ::MOI.Silent, value::Bool)
    model.silent = value
    return
end

MOI.supports(::Optimizer, ::MOI.Silent) = true

# TimeLimitSec
function MOI.get(model::Optimizer, ::MOI.TimeLimitSec)
    return
end

function MOI.set(model::Optimizer, ::MOI.TimeLimitSec, value::Union{Nothing,Float64})
    model.timeout = value
    return
end

MOI.supports(::Optimizer, ::MOI.TimeLimitSec) = true

# ObjectiveLimit
function MOI.get(model::Optimizer, ::MOI.ObjectiveLimit)
    return
end

function MOI.set(model::Optimizer, ::MOI.ObjectiveLimit, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.ObjectiveLimit) = true

# SolutionLimit
function MOI.get(model::Optimizer, ::MOI.SolutionLimit)
    return
end

function MOI.set(model::Optimizer, ::MOI.SolutionLimit, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.SolutionLimit) = true

# NodeLimit
function MOI.get(model::Optimizer, ::MOI.NodeLimit)
    return
end

function MOI.set(model::Optimizer, ::MOI.NodeLimit, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.NodeLimit) = true

# RawOptimizerAttribute
function MOI.get(model::Optimizer, ::MOI.RawOptimizerAttribute)
    return
end

function MOI.set(model::Optimizer, ::MOI.RawOptimizerAttribute, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.RawOptimizerAttribute) = true

# NumberOfThreads
function MOI.get(model::Optimizer, ::MOI.NumberOfThreads)
    return
end

function MOI.set(model::Optimizer, ::MOI.NumberOfThreads, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.NumberOfThreads) = true

# AbsoluteGapTolerance
function MOI.get(model::Optimizer, ::MOI.AbsoluteGapTolerance)
    return
end

function MOI.set(model::Optimizer, ::MOI.AbsoluteGapTolerance, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.AbsoluteGapTolerance) = true

# RelativeGapTolerance
function MOI.get(model::Optimizer, ::MOI.RelativeGapTolerance)
    return
end

function MOI.set(model::Optimizer, ::MOI.RelativeGapTolerance, v::Bool)
    return
end

MOI.supports(::Optimizer, ::MOI.RelativeGapTolerance) = true
