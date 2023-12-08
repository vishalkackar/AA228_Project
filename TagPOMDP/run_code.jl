using POMDPs
using POMDPTools

using SARSOP # load a  POMDP Solver
using QMDP
using POMDPGifs # to make gifs
using LinearAlgebra
using POMDPTools
using Plots
using SparseArrays


include("actor_types.jl")
include("states.jl")
include("actions.jl")
include("transition.jl")
include("observations.jl")
include("reward.jl")
include("visualization.jl")


whichMap = 1
#creat pomdps with different maps
if whichMap == 1
    pomdp = TagPOMDP2_1()
elseif whichMap == 2
    pomdp = TagPOMDP2_2()
elseif whichMap == 3
    pomdp = TagPOMDP2_3()
end
# pomdp = TagPOMDP2_1()
# pomdp = TagPOMDP2_2()
# pomdp = TagPOMDP2_3()

#create different solvers
solver_sarsop = SARSOPSolver(timeout=60,policy_filename="sarsopPolicy.out")
solver_qmdp = QMDPSolver(; max_iterations=60)

#get different policies using different solvers
# policy_sarsop = solve(solver_sarsop, pomdp)
# policy_sarsop = load_policy(pomdp,"sarsopPolicy.out")

policy_qmdp = solve(solver_qmdp,pomdp)


#simulate results

sim = GifSimulator(filename="test.gif", max_steps=50) 
# simulate(sim, pomdp, policy_sarsop) 
simulate(sim, pomdp, policy_qmdp) 
