abstract type AbstractLMOBackend end

struct MathOptLMOBackend <: AbstractLMOBackend
    optimizer_factory
end

function build_lmo(
    backend::MathOptLMOBackend,
    feasible_region_data,
)
    inner = backend.optimizer_factory()

    index_map = MOI.copy_to(inner, feasible_region_data)
    return FrankWolfe.MathOptLMO(inner)
end

function supports_constraint(
    backend::MathOptLMOBackend,
    ::Type{F},
    ::Type{S},
)::Bool where {F, S}
    inner = backend.optimizer_factory()

    return MOI.supports_constraint(inner, F, S)
end