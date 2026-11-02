"""
    AbstractLMOBackend

Supertype of all LMO backends used by `Optimizer`.
"""
abstract type AbstractLMOBackend end

"""
    MathOptLMOBackend(optimizer_factory)

LMO backend that solves the linear subproblems with an inner MIP solver,
such as SCIP or HiGHS, wrapped as a `FrankWolfe.MathOptLMO`.
"""
struct MathOptLMOBackend <: AbstractLMOBackend
    optimizer_factory::Any
end

"""
    build_lmo(backend::MathOptLMOBackend, feasible_region_data)

Create a new inner MIP solver, copy the feasible region into it, and wrap it
as a `FrankWolfe.MathOptLMO`.
"""
function build_lmo(backend::MathOptLMOBackend, feasible_region_data)
    inner = MOI.instantiate(backend.optimizer_factory)

    # Silent MIP solver 
    if MOI.supports(inner, MOI.Silent())
        MOI.set(inner, MOI.Silent(), true)
    end

    MOI.copy_to(inner, feasible_region_data)
    return FrankWolfe.MathOptLMO(inner)                # Wrap as an LMO
end

"""
    supports_constraint(backend::MathOptLMOBackend, ::Type{F}, ::Type{S}) where {F,S}

Return whether the inner MIP solver supports `F`-in-`S` constraints.
"""
function supports_constraint(backend::MathOptLMOBackend, ::Type{F}, ::Type{S})::Bool where {F,S}
    inner = MOI.instantiate(backend.optimizer_factory)

    return MOI.supports_constraint(inner, F, S)
end




"""
    has_zero_one_hypercube(model)

Return whether `model` contains a `MOI.VectorOfVariables`-in-
`ZeroOneHypercube` constraint.
"""
function has_zero_one_hypercube(model)
    n_cube = MOI.get(model, MOI.NumberOfConstraints{MOI.VectorOfVariables,ZeroOneHypercube}())
    return n_cube > 0
end

"""
    integer_variables(model)

Return the sorted indices of the variables of `model` that have an
`MOI.Integer` or `MOI.ZeroOne` constraint.
"""
function integer_variables(model)
    int_vars = Int[]
    for S in (MOI.Integer, MOI.ZeroOne)
        for ci in MOI.get(model, MOI.ListOfConstraintIndices{MOI.VariableIndex,S}())
            x = MOI.get(model, MOI.ConstraintFunction(), ci)
            push!(int_vars, x.value)
        end
    end
    return sort!(unique!(int_vars))
end

"""
    build_zero_one_hypercube_lmo(model)

Build the LMO for a model whose feasible region is the 0-1 hypercube.
"""
function build_zero_one_hypercube_lmo(model)
    n = MOI.get(model, MOI.NumberOfVariables())
    int_vars = integer_variables(model)
    lower_bounds = zeros(length(int_vars))
    upper_bounds = ones(length(int_vars))
    return ManagedLMO(ZeroOneHypercubeLMO(), lower_bounds, upper_bounds, int_vars, n)
end
