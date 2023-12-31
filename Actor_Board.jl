include("Actor.jl")
using LinearAlgebra
using Plots
using Gtk

function createMap1()
    map = zeros(12,12)
    map[1,1:12] .= 1
    map[12,1:12] .= 1
    map[1:12,1] .= 1
    map[1:12,12] .= 1
    map[2:3,6] .= 1
    map[3,3:4] .= 1
    map[5,3:6] .= 1
    map[3:7,8] .= 1
    map[3:4,10] .= 1
    map[6:7,10] .= 1
    map[9:10,10] .= 1
    map[7,2:6] .= 1
    map[9:10,3:8] .= 1
    return map
end

map = Board([12,12], createMap1())
global prey = Actor([2, 2], "Prey", [1], [[2, 2]], 1:5, map)
global predator = Actor([11, 11], "Predator", [1], [[11, 11]], 1:5, map)

# function draw(predator::Actor, prey::Actor, board::Board)
#     data = copy(board.layout)
#     data[predator.pos[1], predator.pos[2]] = 0.25          # predator
#     data[prey.pos[1], prey.pos[2]] = 0.75                  # prey

#     h = heatmap(1:size(data,1), 1:size(data,2), data, yflip = true,c=cgrad([:white, :black]), aspect_ratio=:equal)
#     display(h)
# end

function draw(predator::Actor, prey::Actor, board::Board, i)
    data = copy(board.layout)
    pred_pos = predator.coord_history[i]
    prey_pos = prey.coord_history[i]
    data[pred_pos[1], pred_pos[2]] = 0.25          # predator
    data[prey_pos[1], prey_pos[2]] = 0.75                  # prey
    h = heatmap(1:size(data,1), 1:size(data,2), data, yflip = true,c=cgrad([:white, :black]), aspect_ratio=:equal)
    display(h)
end

# win = GtkWindow("Tag Project")
# function keycall(w, event)
#     ch = Char(event.keyval)
#     println("You pressed: $ch")
# end

# Run simulation until requested horizon
function run_game(HORIZON)
    println("Starting game simulation...")
    for i in range(1, HORIZON)
        get_next_action(prey, predator)
        get_next_action(predator, prey)
    end
    println("Ran simulation for ", HORIZON, " steps.")
end

# Run visualization
function visualize(VIS_HORIZON, DELAY)
    println("Starting visualization...")
    for i in range(1, min(VIS_HORIZON, length(predator.coord_history)))
        draw(predator, prey, map, i)
        sleep(DELAY)
    end
    println("Done.")
end

function debug(HORIZON, DELAY)
    println("Starting simultaneous simulation and visualization...")
    for i in range(1, HORIZON)
        get_next_action(prey, predator)
        get_next_action(predator, prey)
        draw(predator, prey, map, i)
        sleep(DELAY)
    end
    println("Done.")
end

# signal_connect(keycall, win, "key-press-event")

# run_game(100)
# visualize(100, 0.01)
debug(100, 0.5)

# while true

#     # wait for keypress
#     sleep(.1)

#     # get prey move
#     get_next_action(prey, predator)
#     draw(predator, prey, map)
#     println("Prey moved to : $(prey.pos[1]),  $(prey.pos[2])")

#     # wait for keypress
#     sleep(.1)

#     # get predator move
#     get_next_action(predator, prey)
#     draw(predator, prey, map)
#     println("Predator moved to : $(predator.pos[1]),  $(predator.pos[2])")
# end


