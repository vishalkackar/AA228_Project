include("Board.jl")
include("Actor.jl")
using LinearAlgebra

struct MDP
    gam # discount factor
    S   # state space
    A   # action space
    T   # transition function
    R   # reward function
    TR  # sample transition and reward
end

struct ValueIteration
    k_max
end

struct ValueFunctionPolicy
    P
    U
end

function lookahead(P::MDP, U, s, a, board::Board, coords)
    # S, T, R, gam = P.S, P.T, P.R, P.gam
    # return R(s,a) + gam*sum(T(s,a,sp)*U(sp) for sp in S)

    S, T, gam = P.S, P.T, P.gam
    return Reward_Func(s,a,board,coords) + gam*sum(T[a,s,sp]*U[sp] for sp in S)
    # return Reward_Func(s,a,board)
    # return 1
end

function solve(M::ValueIteration, P::MDP, board::Board, coords)
    U = [0.0 for s in P.S]
    for k=1:M.k_max
        U = [backup(P, U, s, board, coords) for s in P.S]
    end
    return ValueFunctionPolicy(P, U)
end

function greedy(P::MDP, U, s, board::Board, coords)
    u, a = findmax(a->lookahead(P, U, s, a, board, coords), P.A)
    return (a=a, u=u)
end

(pi::ValueFunctionPolicy)(s) = greedy(pi.P, pi.U, s, board::Board, coords).a

function backup(P::MDP, U, s, board::Board, coords)
    return maximum(lookahead(P, U, s, a, board, coords) for a in P.A)
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


function get_next_move(a::Actor, pol::ValueFunctionPolicy)
    # next_action = rand(a.actions)
    next_action = greedy(pol.P, pol.U, coord_to_state(a.pos[1], a.pos[2], a.board), a.board, a.ad_coords).a
    # next_action = pol(coord_to_state(a.pos[1], a.pos[2], a.board))

    return next_action
end



# get the next action
function get_next_action(a::Actor, pol::ValueFunctionPolicy, coords)
    next_action = get_next_move(a, pol)   # randomly choose an action
    # print("action from policy = $next_action")
    curr_pos = copy(a.pos)               # get the current position of the specified actor


    if next_action == 1             # stay in place
        curr_pos = curr_pos
        a.ad_coords = coords
        println("REUPDATING THE VISION SYSTEM")
    elseif next_action == 2         # move up
        if stochMovePred()
            curr_pos[1] = max(curr_pos[1]-1, 1)
            # println("\tGoing up!")
        end

    elseif next_action == 3         # move down
        if stochMovePred()
            curr_pos[1] = min(curr_pos[1]+1, a.board.bounds[1])
            # println("\tGoing down!")
        end

    elseif next_action == 4         # move left
        if stochMovePred()    
            curr_pos[2] = max(curr_pos[2]-1, 1)
            # println("\tGoing left!")
        end

    elseif next_action == 5         # move right
        if stochMovePred()
            curr_pos[2] = min(curr_pos[2]+1, a.board.bounds[2])
            # println("\tGoing right!")
        end
        
    end

    # check if potential action leads to an obstacle
    if (a.board.layout[curr_pos[1], curr_pos[2]] == 1)
        # println("Trying to move to an invalid position")
        curr_pos = a.pos
    end
    

    # push!(a.action_history, next_action)
    # push!(a.coord_history, curr_pos)
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

