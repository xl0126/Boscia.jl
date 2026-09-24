import MathOptInterface as MOI

mutable struct Optimizer{B<:AbstractLMOBackend} <: MOI.AbstractOptimizer
    model::MOI.Utilities.Model{Float64}
    backend::B
    silent::Bool
    timeout::Union{Nothing,Float64}

    termination_status::MOI.TerminationStatusCode
    raw_status_string::String
    primal_status::MOI.ResultStatusCode
    objective_value::Union{Nothing,Float64}
    variable_primal::Vector{Float64}
end

function Optimizer(backend::MathOptLMOBackend)
    return Optimizer{typeof(backend)}(
        MOI.Utilities.Model{Float64}(),
        backend,
        false,
        nothing,
        MOI.OPTIMIZE_NOT_CALLED,
        "",
        MOI.NO_SOLUTION,
        nothing,
        Float64[],
    )
end

function Optimizer(optimizer_factory)
    return Optimizer(MathOptLMOBackend(optimizer_factory))
end

function MOI.empty!(optimizer::Optimizer)
    MOI.empty!(optimizer.model)
    return
end

function MOI.is_empty(optimizer::Optimizer)
    return MOI.is_empty(optimizer.model)
end

MOI.supports_incremental_interface(::Optimizer) = true

function MOI.copy_to(dest::Optimizer, src::MOI.ModelLike)
    return MOI.Utilities.default_copy_to(dest, src)
end
