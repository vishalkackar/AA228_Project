using QuickPOMDPs: QuickPOMDP
using POMDPTools: Deterministic, Uniform, SparseCat

include("Actor.jl")

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

const size = 12

global T = generate_T()
m = QuickPOMDP(
    states = 1:144
    actions = 1:5
    observations = 1:2
    discount = 0.9

    transition = function(s, a)
        if a == 1

        elseif a == 2

        elseif a == 3

        elseif a == 4

        else 
            
        end
    end

    observation
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


