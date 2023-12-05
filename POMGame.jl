using QuickPOMDPs: QuickPOMDP
using POMDPTools: Deterministic, Uniform, SparseCat

include("Actor.jl")
include("RewardFunc.jl")

# struct POMDP
#     γ # discount factor
#     𝒮 # state space
#     𝒜 # action space
#     𝒪 # observation space
#     T # transition function
#     R # reward function
#     O # observation function
#     TRO # sample transition, reward, and observation
# end

######################################### SETUP GAME #######################################3
const size = 12
global map = Board([12,12], createMap2())

prey_start_pos = [4,8]
pred_start_pos = [4,2]

global prey = Actor(prey_start_pos, "Prey", [1], [[2, 2]], 1:5, map, pred_start_pos)
global predator = Actor(pred_start_pos, "Predator", [1], [[11, 11]], 1:5, map, prey_start_pos)
global seesPrey = false

max_state = map.bounds[1] * map.bounds[2]
Problem = MDP(0.8, 1:max_state, 1:5, 0, 0, TR)

global T = generate_T(map, prey)

# init_prob = zeros(144)
# init_prob[coord_to_state(prey.pos[1], prey.pos[2], map)] = 1

# define POMDP
m = QuickPOMDP(
    states = 1:144,         # 12 x 12 grid
    actions = 1:5,          # jump, up, down, left, right
    observations = 1:144,   # one for each cell
    discount = 0.9, 
    transition = function(s, a) # stochastic transition function (precomputed)
        row, col = state_to_coord(s, map)
        sp = s

        if a == 1           # jump
            sp = s
        elseif a == 2       # up
            sp = coord_to_state(row-1, col, map)
        elseif a == 3       # down
            sp = coord_to_state(row+1, col, map)
        elseif a == 4       # left
            sp = coord_to_state(row, col-1, map)
        elseif a == 5       # right
            sp = coord_to_state(row, col+1, map)
        end

        # return T[a,s,sp]
        if a == 1
            return SparseCat([s], [1.0])
        else
            return SparseCat([sp, s], [T[a,s,sp], 1.0 - T[a,s,sp]])
        end
        # return SparseCat([1:144], T[a,s,:])
    end,

    observation = function(a, sp)
        if test_vision(prey, predator, map)     # if we have LOS, perfect observation of the prey
            valid_states = coord_to_state(prey.pos[1], prey.pos[2], map)
            valid_probs = 1.0 # guarantee 

        else # otherwise, assign observation distribution to region of prey
            if a == 1   # if we jump, get a distribution around the actual prey location
                row = prey.pos[1]
                col = prey.pos[2]

                # all possible neighboring cells
                neighbor_cells = [[row, col], [row+1, col], [row, col+1], [row-1, col], [row, col-1]]
                valid_cells = []
                
                for cell in neighbor_cells
                    # make sure cell is within bounds and not a wall
                    if ( (cell[1] > 0 && cell[1] < 13) && (cell[1] > 0 && cell[1] < 13) && (map.layout[cell[1]][cell[2]] == 0) )
                        push!(valid_cells, cell)
                    end
                end

                num_valid = length(valid_cells)

                # convert row,col to state
                valid_states = zeros(num_valid)
                for cell in valid_cells
                    push!(valid_states, coord_to_state(cell[1], cell[2], map))
                end
                
                # assign base 0.8 prob to prey position and 0.05 to neighboring cells
                valid_probs = zeros(num_valid)
                valid_probs[1] = 0.8 + 0.05*(5 - num_valid)
                valid_probs[2,:] .= 0.05

            else        # if do not jump, then assume uniform distribution
                valid_states = 1:144
                valid_probs = Uniform(valid_states)
            end
        end

        # assign probablities to entire grid
        # total_probs = zeros(144)
        # for s in 1:num_valid
        #     total_probs[valid_states[s]] = valid_probs[s]
        # end

        # return SparseCat(1:144, total_probs)
        return SparseCat(valid_states, valid_probs)
    end,
    
    reward = function(s, a, sp)
        return Reward_Func(s, a, map, predator.ad_coords)
    end,

    initial_state = SparseCat(coord_to_state(prey.pos[1], prey.pos[2], map), 1.0)
)

function generate_T(board::Board, actor::Actor)
    state_size = (board.bounds[1] * board.bounds[2], board.bounds[1] * board.bounds[2])
    T = zeros(maximum(actor.actions), board.bounds[1] * board.bounds[2], board.bounds[1] * board.bounds[2])
    for a in actor.actions
        temp_T = zeros(state_size)

        if a == 1                       # stay in place
            temp_T = I(state_size[1])

        elseif a == 2                   # move up
            for i = 1:state_size[1]      # loop through s
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (row - 1 > 0) && (board.layout[row-1,col] == 0)
                    temp_T[i, i-board.bounds[1]] = moveProb
                    temp_T[i, i] = 1-moveProb
                end
            end

        elseif a == 3                   # move down
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (row + 1 <= board.bounds[1]) && (board.layout[row+1,col] == 0)
                    temp_T[i, i+board.bounds[1]] = moveProb
                    temp_T[i, i] =  1-moveProb
                end
            end

        elseif a == 4                   # move left 
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (col-1 > 0) && (board.layout[row,col-1] == 0)
                    temp_T[i, i-1] = moveProb
                    temp_T[i, i] =  1-moveProb
                end
            end

        elseif a == 5                   # move right
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (col+1 <= board.bounds[2]) && (board.layout[row,col+1] == 0)
                    temp_T[i, i+1] = moveProb
                    temp_T[i, i] =  1-moveProb
                end
            end
        end

        # println("NEW ACTION: ")
        # println(temp_T)
        T[a,:,:] = temp_T

    end

    return T
end

function Reward_Func(s, a, board::Board, coords)
    # assume prey is stationary at 2,2
    preyRow = coords[1]
    preyCol = coords[2]

    row,col = state_to_coord(s, board)
    dist = abs(row - preyRow) + abs(col - preyCol)
    new_dist = dist

    # distance doesn't change if we stay

    if a == 2           # up
        if ((row - 1 > 0) && board.layout[row-1, col] == 0)
            new_dist = abs(row - 1 - preyRow) + abs(col - preyCol)
        end

    elseif a == 3       # down
        if (row + 1 <= board.bounds[1]) && (board.layout[row+1, col] == 0)
            new_dist = abs(row + 1 - preyRow) + abs(col - preyCol)
        end

    elseif a == 4       # left
        if (col-1 > 0) && (board.layout[row, col-1] == 0)
            new_dist = abs(row - preyRow) + abs(col - 1 - preyCol)
        end

    elseif a == 5       # right
        if (col+1 <= board.bounds[2]) && (board.layout[row, col+1] == 0)
            new_dist = abs(row - preyRow) + abs(col + 1 - preyCol)
        end
    end
    
    return 10 * (dist - new_dist)

end


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