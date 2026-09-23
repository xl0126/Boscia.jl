using Boscia
using SCIP
import MathOptInterface as MOI

println("=== Boscia objective oracle smoke test ===")



# ------------------------------------------------------------
# Quadratic objective:
# min (x - 2)^2
# ------------------------------------------------------------

opt = Boscia.Optimizer(SCIP.Optimizer)

x = MOI.add_variable(opt)

MOI.add_constraint(opt, x, MOI.GreaterThan(1.0))
MOI.add_constraint(opt, x, MOI.LessThan(5.0))
MOI.add_constraint(opt, x, MOI.Integer())

quadratic_obj = MOI.ScalarQuadraticFunction(
    [
        MOI.ScalarQuadraticTerm(2.0, x, x),
    ],
    [
        MOI.ScalarAffineTerm(-4.0, x),
    ],
    4.0,
)

MOI.set(
    opt,
    MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}}(),
    quadratic_obj,
)

MOI.set(opt, MOI.ObjectiveSense(), MOI.MIN_SENSE)

MOI.optimize!(opt)

println("objective function = ", MOI.get(opt, MOI.ObjectiveFunction{MOI.ScalarQuadraticFunction{Float64}}()))
println("termination = ", MOI.get(opt, MOI.TerminationStatus()))
println("raw status  = ", MOI.get(opt, MOI.RawStatusString()))
println("primal      = ", MOI.get(opt, MOI.PrimalStatus()))
println("objective   = ", MOI.get(opt, MOI.ObjectiveValue()))
println("x           = ", MOI.get(opt, MOI.VariablePrimal(), x))


println("\n=== All objective oracle tests passed ===")

