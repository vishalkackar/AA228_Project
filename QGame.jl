include("Actor.jl")
include("QLearning.jl")

using LinearAlgebra
using Plots
using Gtk

println("------------------ Q LEARNING RUN ------------------")


map = Board([12,12], createMap1())

prey_start_pos = [4,9]
pred_start_pos = [2,2]

global prey = Actor(prey_start_pos, "Prey", [1], [[2, 2]], 1:5, map, pred_start_pos)
global predator = Actor(pred_start_pos, "Predator", [1], [[11, 11]], 1:5, map, prey_start_pos)
global seesPrey = false

max_state = map.bounds[1] * map.bounds[2]
Problem = MDP(0.9, 1:max_state, 1:5, 0, 0, TR)

# define parameters for Q learning problem
Q = zeros((length(Problem.S), length(Problem.S)))
α = 0.2
model = QLearning(Problem.S, Problem.A, Problem.gam, Q, α)

ϵ = 0.3
π = EpsilonGreedyExploration(ϵ)
k = 20
s = coord_to_state(pred_start_pos[1], pred_start_pos[2], map)

# get first simulation
simulate(Problem, model, π, k, s, map, predator.ad_coords)


function draw(predator::Actor, prey::Actor, board::Board, seesPrey)
    data = copy(board.layout)
    if seesPrey
        data[predator.pos[1], predator.pos[2]] = 0.25          # predator
    else 
        data[predator.pos[1], predator.pos[2]] = 0.5
    end
    data[prey.pos[1], prey.pos[2]] = 0.75                  # prey

    h = heatmap(1:size(data,1), 1:size(data,2), data, yflip = true,c=cgrad([:white, :red, :orange, :blue, :black]), aspect_ratio=:equal)
    display(h)
end


draw(predator, prey, map)

while true

    # wait for keypress
    # sleep(1)

    # get prey move
    # get_next_action(prey, predator)
    get_prey_move(prey, predator)
    draw(predator, prey, map, seesPrey)
    println("Prey moved to : $(prey.pos[1]),  $(prey.pos[2])")

    # wait for keypress
    sleep(0.1)

    # get predator move
    if test_vision(prey, predator, map.layout)
        println("I HAVE VISION!------------------------------------------------")
        predator.ad_coords = prey.pos
        global seesPrey = true
    else
        global seesPrey = false
    end

    simulate(Problem, model, π, k, s, map, predator.ad_coords)

    # get_next_action(predator, valIterSolution, prey.pos)
    get_Q_action(model.Q, coord_to_state(predator.pos[1], predator.pos[2], map), predator,prey.pos)
    draw(predator, prey, map, seesPrey)
    println("Predator moved to : $(predator.pos[1]),  $(predator.pos[2])")

    if (prey.pos == predator.pos)
        println("PREDATOR FOUND THE PREY")
        break
    end
end


