# LMO backends: what actually solves the linear subproblems for Boscia.
#
# At every Frank-Wolfe iteration, Boscia asks the LMO (linear minimization
# oracle) to solve
#
#     min  <d, x>   s.t.  x in feasible region (+ bounds from branching)
#
# for some direction d. The LMO never sees the user's quadratic or nonlinear
# objective, only linear ones.
#
# Each backend implements two functions:
#   - build_lmo(backend, feasible_region)   -> (LMO passed to Boscia.solve)
#   - supports_constraint(backend, F, S)    -> can this backend handle F-in-S?
#
# Currently only `MathOptLMOBackend` (an inner MIP solver) exists. Custom
# LMOs (e.g. polytope or combinatorial oracles) can be added later as new
# subtypes of `AbstractLMOBackend`, without changing the rest of the wrapper.

"""
    AbstractLMOBackend

Supertype of all LMO backends used by [`Optimizer`](@ref).

A backend decides how the feasible region of the MOI model is turned into an
LMO for `Boscia.solve`. Subtypes must implement [`build_lmo`](@ref) and
[`supports_constraint`](@ref).
"""
abstract type AbstractLMOBackend end

"""
    MathOptLMOBackend(optimizer_factory)

LMO backend that solves the linear subproblems with an inner MIP solver,
such as SCIP or HiGHS, wrapped as a `FrankWolfe.MathOptLMO`.

`optimizer_factory` is anything accepted by `MOI.instantiate`, for example
`SCIP.Optimizer` or `() -> HiGHS.Optimizer()`.
"""
struct MathOptLMOBackend <: AbstractLMOBackend
    optimizer_factory::Any
end

"""
    build_lmo(backend::MathOptLMOBackend, feasible_region_data)

Create a new inner MIP solver, copy the feasible region into it, and wrap it
as a `FrankWolfe.MathOptLMO`.

`feasible_region_data` is the cached model without its objective, as
returned by [`build_feasible_region`](@ref).
"""
function build_lmo(backend::MathOptLMOBackend, feasible_region_data)
    inner = MOI.instantiate(backend.optimizer_factory)

    # Silent MIP solver 
    if MOI.supports(inner, MOI.Silent())
        MOI.set(inner, MOI.Silent(), true)
    end

    index_map = MOI.copy_to(inner, feasible_region_data)
    return FrankWolfe.MathOptLMO(inner)                # Wrap as an LMO
end

"""
    supports_constraint(backend::MathOptLMOBackend, ::Type{F}, ::Type{S}) where {F,S}

Return whether the inner MIP solver supports `F`-in-`S` constraints.

This is the backend's half of `MOI.supports_constraint`: since constraints
are passed to the inner solver unchanged, they are supported exactly when
that solver supports them.
"""
function supports_constraint(backend::MathOptLMOBackend, ::Type{F}, ::Type{S})::Bool where {F,S}
    inner = MOI.instantiate(backend.optimizer_factory)

    return MOI.supports_constraint(inner, F, S)
end
