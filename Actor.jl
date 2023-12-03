using Random
include("Board.jl")
include("ValueIter.jl")

mutable struct Actor
    pos::Vector
    name::String
    action_history::Vector
    coord_history::Vector{Vector}
    actions::Vector
    board::Board
end


function get_next_move(a::Actor, adversary::Actor, pol::ValueFunctionPolicy)
    # next_action = rand(a.actions)
    next_action = greedy(pol.P, pol.U, coord_to_state(a.pos[1], a.pos[2], a.board), a.board).a

    return next_action
end


# get the next action
function get_next_action(a::Actor, adversary::Actor, pol::ValueFunctionPolicy)
    next_action = get_next_move(a, adversary, pol)   # randomly choose an action
    print("action from policy = $next_action")
    curr_pos = copy(a.pos)               # get the current position of the specified actor


    if next_action == 1             # stay in place
        curr_pos = curr_pos
    elseif next_action == 2         # move up
        curr_pos[1] = max(curr_pos[1]-1, 1)
        println("\tGoing up!")
    elseif next_action == 3         # move down
        curr_pos[1] = min(curr_pos[1]+1, a.board.bounds[1])
        println("\tGoing down!")
    elseif next_action == 4         # move left
        curr_pos[2] = max(curr_pos[2]-1, 1)
        println("\tGoing left!")
    elseif next_action == 5         # move right
        curr_pos[2] = min(curr_pos[2]+1, a.board.bounds[2])
        println("\tGoing right!")
    end

    # check if potential action leads to an obstacle
    if (a.board.layout[curr_pos[1], curr_pos[2]] == 1)
        println("Trying to move to an invalid position")
        curr_pos = a.pos
    end
    

    push!(a.action_history, next_action)
    push!(a.coord_history, curr_pos)
    a.pos = curr_pos
    # return curr_pos                 # return the next action
end

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
                    temp_T[i, i-board.bounds[1]] = 1
                end
            end

        elseif a == 3                   # move down
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (row + 1 <= board.bounds[1]) && (board.layout[row+1,col] == 0)
                    temp_T[i, i+board.bounds[1]] = 1
                end
            end

        elseif a == 4                   # move left 
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (col-1 > 0) && (board.layout[row,col-1] == 0)
                    temp_T[i, i-1] = 1
                end
            end

        elseif a == 5                   # move right
            for i = 1:state_size[1]
                row,col = state_to_coord(i, board)

                if (board.layout[row,col] == 0) && (col+1 <= board.bounds[2]) && (board.layout[row,col+1] == 0)
                    temp_T[i, i+1] = 1
                end
            end
        end

        # println("NEW ACTION: ")
        # println(temp_T)
        T[a,:,:] = temp_T

    end

    return T
end