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


"""
    MOI.empty!(optimizer::Optimizer)

Remove all variables, constraints and objective information from `optimizer`,
and discard the results of any previous call to `MOI.optimize!`.

Optimizer attributes such as `MOI.Silent` and `MOI.TimeLimitSec` are preserved.
"""
function MOI.empty!(optimizer::Optimizer)
    # 1. Clear the problem (variables, constraints, objective)
    MOI.empty!(optimizer.model)

    # 2. Reset the results of the last solve
    optimizer.termination_status = MOI.OPTIMIZE_NOT_CALLED
    optimizer.raw_status_string = ""
    optimizer.primal_status = MOI.NO_SOLUTION
    optimizer.objective_value = nothing
    optimizer.variable_primal = Float64[]

    return
end

"""
    MOI.is_empty(optimizer::Optimizer)

Return `true` if `optimizer` is in the same state as directly after
[`MOI.empty!`](@ref), and `false` otherwise.

The optimizer is considered empty if both of the following hold:

1. The cached model contains no variables, constraints or objective.
2. No results from a previous call to `MOI.optimize!` are stored, i.e. all
   result fields have their initial values.

Optimizer attributes such as `MOI.Silent` and `MOI.TimeLimitSec`, as well as
the LMO backend, are not checked, because `MOI.empty!` does not reset them.
"""
function MOI.is_empty(optimizer::Optimizer)
    return MOI.is_empty(optimizer.model) &&
           optimizer.termination_status == MOI.OPTIMIZE_NOT_CALLED &&
           optimizer.raw_status_string == "" &&
           optimizer.primal_status == MOI.NO_SOLUTION &&
           optimizer.objective_value == nothing &&
           optimizer.variable_primal == Float64[]
end

MOI.supports_incremental_interface(::Optimizer) = true

function MOI.copy_to(dest::Optimizer, src::MOI.ModelLike)
    return MOI.Utilities.default_copy_to(dest, src)
end
