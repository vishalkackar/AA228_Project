include("Actor.jl")
include("ValueIter.jl")

using LinearAlgebra
using Plots
using Gtk

println("------------------ NEW RUN ------------------")



map = Board([12,12], createMap1())

prey_start_pos = [4,9]
pred_start_pos = [2,2]

global prey = Actor(prey_start_pos, "Prey", [1], [[2, 2]], 1:5, map, pred_start_pos)
global predator = Actor(pred_start_pos, "Predator", [1], [[11, 11]], 1:5, map, prey_start_pos)

max_state = map.bounds[1] * map.bounds[2]
Problem = MDP(0.9, 1:max_state, 1:5, generate_T(map, prey), 0, 0)

global valIterSolution = solve(ValueIteration(50), Problem, map, predator.ad_coords)

function draw(predator::Actor, prey::Actor, board::Board)
    data = copy(board.layout)
    data[predator.pos[1], predator.pos[2]] = 0.25          # predator
    data[prey.pos[1], prey.pos[2]] = 0.75                  # prey

    h = heatmap(1:size(data,1), 1:size(data,2), data, yflip = true,c=cgrad([:white, :black]), aspect_ratio=:equal)
    display(h)
end

# win = GtkWindow("Tag Project")
# function keycall(w, event)
#     ch = Char(event.keyval)
#     println("You pressed: $ch")
#     draw(predator, prey)
#     # processKey(ch)
# end
  
# signal_connect(keycall, win, "key-press-event")

draw(predator, prey, map)

while true

    # wait for keypress
    # sleep(1)

    # get prey move
    # get_next_action(prey, predator)
    get_prey_move(prey, predator)
    draw(predator, prey, map)
    println("Prey moved to : $(prey.pos[1]),  $(prey.pos[2])")

    # wait for keypress
    sleep(0.5)

    # get predator move
    if test_vision(prey, predator, map.layout)
        println("I HAVE VISION!------------------------------------------------")
        predator.ad_coords = prey.pos
        global valIterSolution = solve(ValueIteration(50), Problem, map, predator.ad_coords)
    end

    get_next_action(predator, valIterSolution, prey.pos)
    draw(predator, prey, map)
    println("Predator moved to : $(predator.pos[1]),  $(predator.pos[2])")

    if (prey.pos == predator.pos)
        println("PREDATOR FOUND THE PREY")
        break
    end
end


