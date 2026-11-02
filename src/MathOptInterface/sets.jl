"""
    ZeroOneHypercube(dimension::Int)

The set ``\\{x \\in \\mathbb{R}^n : 0 \\le x_i \\le 1 \\text{ for all } i\\}``,
where `n = dimension`.
"""
struct ZeroOneHypercube <: MOI.AbstractVectorSet
    dimension::Int
end
