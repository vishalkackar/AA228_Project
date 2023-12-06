using POMDPs
using TagPOMDPProblem
# include("TagPOMDPProblem.jl")
using SARSOP # load a  POMDP Solver
using POMDPGifs # to make gifs

pomdp = TagPOMDP2()

solver = SARSOPSolver(; timeout=150)
policy = solve(solver, pomdp)

sim = GifSimulator(filename="test.gif", max_steps=50)
simulate(sim, pomdp, policy)