# Objective of Boscia.Optimizer.
#
# The objective is not passed to the LMO. It is stored in `optimizer.model`
# and turned into the Frank-Wolfe oracles `f` and `grad!` at `MOI.optimize!`
# (see `build_objective_oracles`).
#
# Supported objective functions:
#
#   ScalarQuadraticFunction{Float64}   (convex quadratic)
#   ScalarNonlinearFunction            (convex nonlinear)

"""
    MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveFunctionType)

Return the type of the objective function stored in `optimizer`.
"""
function MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveFunctionType)
    return MOI.get(optimizer.model, attr)
end

# Affine objectives are not supported natively. 
function MOI.supports(::Optimizer, ::MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}})
    return false
end

# ---------------------------------------------------------------------------
# ScalarQuadraticFunction
# ---------------------------------------------------------------------------

"""
    MOI.set(
        optimizer::Optimizer,
        attr::MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}},
        func::MOI.ScalarQuadraticFunction{Float64},
    )

Store a quadratic objective in `optimizer`.

The function is stored in canonical form: duplicate terms are merged, so each
variable or pair of variables appears at most once.
"""
function MOI.set(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}},
    func::MOI.ScalarQuadraticFunction{Float64},
)
    canonical_func = MOI.Utilities.canonical(func)
    MOI.set(optimizer.model, attr, canonical_func)
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



# ---------------------------------------------------------------------------
# ScalarNonlinearFunction
# ---------------------------------------------------------------------------

"""
    MOI.set(
        optimizer::Optimizer,
        attr::MOI.ObjectiveFunction{MOI.ScalarNonlinearFunction},
        func::MOI.ScalarNonlinearFunction,
    )

Store a nonlinear objective in `optimizer`.

The function is stored unchanged. Its value and gradient are computed by MOI's
automatic differentiation at `MOI.optimize!`.
"""
function MOI.set(
    optimizer::Optimizer,
    attr::MOI.ObjectiveFunction{MOI.ScalarNonlinearFunction},
    func::MOI.ScalarNonlinearFunction,
)
    MOI.set(optimizer.model, attr, func)
    return
end

function MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveFunction{MOI.ScalarNonlinearFunction})
    return MOI.get(optimizer.model, attr)
end

function MOI.supports(::Optimizer, ::MOI.ObjectiveFunction{MOI.ScalarNonlinearFunction})
    return true
end

# ---------------------------------------------------------------------------
# ObjectiveSense
# ---------------------------------------------------------------------------

"""
    MOI.set(optimizer::Optimizer, attr::MOI.ObjectiveSense, sense::MOI.OptimizationSense)

Set whether the objective is minimized or maximized.

Only `MOI.MIN_SENSE` and `MOI.MAX_SENSE` are accepted at `MOI.optimize!`.
`MOI.FEASIBILITY_SENSE` is stored but rejected when solving.
"""
function MOI.set(optimizer::Optimizer, attr::MOI.ObjectiveSense, sense::MOI.OptimizationSense)
    MOI.set(optimizer.model, attr, sense)
    return
end

function MOI.get(optimizer::Optimizer, attr::MOI.ObjectiveSense)
    return MOI.get(optimizer.model, attr)
end
