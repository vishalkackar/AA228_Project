using POMDPs
using POMDPTools

using SARSOP # load a  POMDP Solver
using QMDP
using POMDPGifs # to make gifs
using LinearAlgebra
using POMDPTools
using Plots
using SparseArrays

using FileIO
using ImageMagick

 
include("actor_types.jl")
include("states.jl")
include("actions.jl")
include("transition.jl")
include("observations.jl")
include("reward.jl")
include("visualization.jl")


whichMap = 4

#creat pomdps with different maps
if whichMap == 1
    pomdp = TagPOMDP2_1()
elseif whichMap == 2
    pomdp = TagPOMDP2_2()
elseif whichMap == 3
    pomdp = TagPOMDP2_3()
elseif whichMap == 4
    pomdp = TagPOMDP2_4()
end


#create different solvers
# solver_sarsop = SARSOPSolver(timeout=60,policy_filename="sarsopPolicy.out")
# solver_qmdp = QMDPSolver(; max_iterations=60)

#get different policies using different solvers
# policy_sarsop = solve(solver_sarsop, pomdp)
# policy_sarsop = load_policy(pomdp,"sarsopPolicy.out")

# policy_qmdp = solve(solver_qmdp,pomdp)


#simulate results

# sim = GifSimulator(filename="test.gif", max_steps=50) 
# simulate(sim, pomdp, policy_sarsop) 

function gatherDataQMDP(numSims)
    data = zeros(4,numSims)
    timeData = zeros(4)
    for m = 1:4
        #select the map
        if m == 1
            pomdp = TagPOMDP2_1()
        elseif m == 2
            pomdp = TagPOMDP2_2()
        elseif m == 3
            pomdp = TagPOMDP2_3()
        elseif m == 4
            pomdp = TagPOMDP2_4()
        end

        #solve the problem
        TI = time()
        solver_qmdp = QMDPSolver(; max_iterations=60)
        policy_qmdp = solve(solver_qmdp,pomdp)
        TF = time()
        timeData[m] = TF-TI

        #simulate
        for i = 1:numSims
            sim = GifSimulator(filename="QMDPgif.gif", max_steps=50) 
            simulate(sim, pomdp, policy_qmdp) 
            file = "QMDPgif.gif"
            pgif = load(file)
            data[m,i] = size(pgif)[3]
        end
    end

    for m = 1:4
        println("QMDP AVERAGE STEPS FOR MAP $m = $(mean(data[m,:]))")
        println("QMDP solve time for map $m = $(timeData[m])")
    end
    return data
end

function gatherDataSARSOP(numSims)
    data = zeros(4,numSims)
    timeData = zeros(4)
    for m = 1:4
        #select the map
        if m == 1
            pomdp = TagPOMDP2_1()
        elseif m == 2
            pomdp = TagPOMDP2_2()
        elseif m == 3
            pomdp = TagPOMDP2_3()
        elseif m == 4
            pomdp = TagPOMDP2_4()
        end

        #solve the problem
        TI = time()
        solver_sarsop = SARSOPSolver(timeout=60,policy_filename="sarsopPolicy.out")
        policy_sarsop = solve(solver_sarsop, pomdp)
        TF = time()
        timeData[m] = TF-TI

        #simulate
        for i = 1:numSims
            sim = GifSimulator(filename="SarsopGif.gif", max_steps=50) 
            simulate(sim, pomdp, policy_sarsop) 
            file = "SarsopGif.gif"
            pgif = load(file)
            data[m,i] = size(pgif)[3]
        end
    end

    for m = 1:4
        println("SAROP AVERAGE STEPS FOR MAP $m = $(mean(data[m,:]))")
        println("SAROP solve time for map $m = $(timeData[m])")
    end

    return data
end


