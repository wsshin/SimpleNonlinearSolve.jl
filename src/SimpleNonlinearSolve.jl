module SimpleNonlinearSolve

using Reexport
using FiniteDiff, ForwardDiff
using ForwardDiff: Dual
using StaticArraysCore
using LinearAlgebra
import ArrayInterfaceCore

@reexport using SciMLBase

abstract type AbstractSimpleNonlinearSolveAlgorithm <: SciMLBase.AbstractNonlinearAlgorithm end
abstract type AbstractBracketingAlgorithm <: AbstractSimpleNonlinearSolveAlgorithm end
abstract type AbstractNewtonAlgorithm{CS, AD, FDT} <: AbstractSimpleNonlinearSolveAlgorithm end
abstract type AbstractImmutableNonlinearSolver <: AbstractSimpleNonlinearSolveAlgorithm end

include("utils.jl")
include("bisection.jl")
include("falsi.jl")
include("raphson.jl")
include("ad.jl")
include("broyden.jl")
include("klement.jl")
include("trustRegion.jl")

import SnoopPrecompile

SnoopPrecompile.@precompile_all_calls begin for T in (Float32, Float64)
    prob_no_brack = NonlinearProblem{false}((u, p) -> u .* u .- p, T(0.1), T(2))
    for alg in (SimpleNewtonRaphson, Broyden, Klement)
        solve(prob_no_brack, alg(), tol = T(1e-2))
    end

    for alg in (TrustRegion(10.0),)
        solve(prob_no_brack, alg, tol = T(1e-2))
    end

    #=
    for alg in (SimpleNewtonRaphson,)
        for u0 in ([1., 1.], StaticArraysCore.SA[1.0, 1.0])
            u0 = T.(.1)
            probN = NonlinearProblem{false}((u,p) -> u .* u .- p, u0, T(2))
            solve(probN, alg(), tol = T(1e-2))
        end
    end
    =#

    prob_brack = IntervalNonlinearProblem{false}((u, p) -> u * u - p, T.((0.0, 2.0)), T(2))
    for alg in (Bisection, Falsi)
        solve(prob_brack, alg(), tol = T(1e-2))
    end
end end

# DiffEq styled algorithms
export Bisection, Broyden, Falsi, Klement, SimpleNewtonRaphson, TrustRegion

end # module
