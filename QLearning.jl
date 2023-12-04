include("Board.jl")
using LinearAlgebra


struct MDP
    gam # discount factor
    S   # state space
    A   # action space
    T   # transition function
    R   # reward function
    TR  # sample transition and reward
end

mutable struct QLearning
    𝒮 # state space (assumes 1:nstates)
    𝒜 # action space (assumes 1:nactions)
    γ # discount
    Q # action value function
    α # learning rate
end

mutable struct EpsilonGreedyExploration
    ϵ # probability of random arm
end

lookahead(model::QLearning, s, a) = model.Q[s,a]

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



function(TR)(s, a, board::Board, coords)
    sp = s

    row, col = state_to_coord(s, board)

    if rand() < moveProb
        sp = s
    else
        if (a == 1)             # stay in place
            sp = s        
        elseif (a == 2)         # up
            if ( (row - 1 > 0) && (board.layout[row-1, col] == 0) )
                sp = coord_to_state(row-1, col, board)
            end
        elseif (a == 3)     # down
            if ( (row + 1 <= board.bounds[1]) && (board.layout[row+1, col] == 0) )
                sp = coord_to_state(row+1, col, board)
            end
        elseif (a == 4)     # left
            if ( (col - 1 > 0) && (board.layout[row, col-1] == 0) )
                sp = coord_to_state(row, col-1, board)
            end
        else # a == 5       # right
            if ( (col + 1 <= board.bounds[2]) && (board.layout[row, col+1] == 0) )
                sp = coord_to_state(row, col+1, board)
            end
        end
    end

    r = Reward_Func(sp, a, board, coords)

    return sp, r
end

function (π::EpsilonGreedyExploration)(model, s)
    𝒜, ϵ = model.𝒜, π.ϵ
    if rand() < ϵ
        return rand(𝒜)
    end

    Q(s,a) = lookahead(model, s, a)
    return argmax(a->Q(s,a), 𝒜)
end

function update!(model::QLearning, s, a, r, sp)
    γ, Q, α = model.γ, model.Q, model.α
    Q[s,a] += α*(r + γ*maximum(Q[sp,:]) - Q[s,a])
    return model
end

function simulate(P::MDP, model, π, h, s, board::Board,coords)
    for i in 1:h
        a = π(model, s) #right
        sp, r = P.TR(s, a, board, coords) #next state, reward = current state, a = right #T[a,s,sp]
        update!(model, s, a, r, sp)
        s = sp
    end
end


function get_Q_action(Q, s, pred::Actor, coords)
    next_action = argmax(Q[s,:])

    curr_pos = copy(pred.pos)          # get the current position of the specified actor

    if next_action == 1             # stay in place
        curr_pos = curr_pos
        pred.ad_coords = coords
        println("REUPDATING THE VISION SYSTEM")

    elseif next_action == 2         # move up
        if stochMovePred()
            curr_pos[1] = max(curr_pos[1]-1, 1)
            # println("\tGoing up!")
        end

    elseif next_action == 3         # move down
        if stochMovePred()
            curr_pos[1] = min(curr_pos[1]+1, pred.board.bounds[1])
            # println("\tGoing down!")
        end

    elseif next_action == 4         # move left
        if stochMovePred()    
            curr_pos[2] = max(curr_pos[2]-1, 1)
            # println("\tGoing left!")
        end

    elseif next_action == 5         # move right
        if stochMovePred()
            curr_pos[2] = min(curr_pos[2]+1, pred.board.bounds[2])
            # println("\tGoing right!")
        end
        
    end

    # check if potential action leads to an obstacle
    if (pred.board.layout[curr_pos[1], curr_pos[2]] == 1)
        # println("Trying to move to an invalid position")
        curr_pos = pred.pos
    end
    

    # push!(a.action_history, next_action)
    # push!(a.coord_history, curr_pos)
    pred.pos = curr_pos
end