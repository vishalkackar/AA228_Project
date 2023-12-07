using POMDPs
# using TagPOMDPProblem2
# include("TagPOMDPProblem.jl")
using SARSOP # load a  POMDP Solver
using POMDPGifs # to make gifs
using LinearAlgebra
using POMDPTools
using Plots
using SparseArrays

# export TagPOMDP2, Map, GameState

include("actor_types.jl")
include("states.jl")
include("actions.jl")
include("transition.jl")
include("observations.jl")
include("reward.jl")
include("visualization.jl")


pomdp = TagPOMDP23()

solver = SARSOPSolver(; timeout=60)
policy = solve(solver, pomdp)

sim = GifSimulator(filename="test.gif", max_steps=50)
# bel0 = zeros(16*16)
# bel0[16] = 1

# bel0 = GameState((1,1), (4,4))
# prob0 = 1
# p = SparseCat(bel0, prob0)

simulate(sim, pomdp, policy)
# simulate(sim, pomdp, policy, s0=SparseCat(1:256, bel0))
# simulate(sim, pomdp, policy,initialstate(pomdp),8380)
#simulate(sim=sim,m=pomdp,p=policy,s0=GameState((1,1),(4,4)))