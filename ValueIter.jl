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

struct ValueIteration
    k_max
end

struct ValueFunctionPolicy
    P
    U
end

function lookahead(P::MDP, U, s, a, board::Board)
    # S, T, R, gam = P.S, P.T, P.R, P.gam
    # return R(s,a) + gam*sum(T(s,a,sp)*U(sp) for sp in S)

    S, T, gam = P.S, P.T, P.gam
    return Reward_Func(s,a,board) + gam*sum(T[a,s,sp]*U[sp] for sp in S)
    # return Reward_Func(s,a,board)
    # return 1
end

function solve(M::ValueIteration, P::MDP, board::Board)
    U = [0.0 for s in P.S]
    for k=1:M.k_max
        U = [backup(P, U, s, board) for s in P.S]
    end
    return ValueFunctionPolicy(P, U)
end

function greedy(P::MDP, U, s, board::Board)
    u, a = findmax(a->lookahead(P, U, s, a, board), P.A)
    return (a=a, u=u)
end

(pi::ValueFunctionPolicy)(s) = greedy(pi.P, pi.U, s, board::Board).a

function backup(P::MDP, U, s, board::Board)
    return maximum(lookahead(P, U, s, a, board) for a in P.A)
end

function state_to_coord(s, board::Board)
    row= Integer(floor(s/board.bounds[1]) + 1)
    col= s%board.bounds[1]

    if row== 13
        row = board.bounds[1]
    end

    if col == 0
        col = board.bounds[2]
    end

    return row,col
end

function coord_to_state(row, col, board::Board)
    return board.bounds[1] * (row-1) + col
end

function Reward_Func(s, a, board::Board)
    # assume prey is stationary at 2,2
    row,col = state_to_coord(s, board)
    dist = abs(row - 2) + abs(col - 2)
    new_dist = dist

    # distance doesn't change if we stay

    if a == 2           # up
        if ((row - 1 > 0) && board.layout[row-1, col] == 0)
            new_dist = abs(row - 1 - 2) + abs(col- 2)
        end

    elseif a == 3       # down
        if (row + 1 <= board.bounds[1]) && (board.layout[row+1, col] == 0)
            new_dist = abs(row + 1 - 2) + abs(col- 2)
        end

    elseif a == 4       # left
        if (col-1 > 0) && (board.layout[row, col-1] == 0)
            new_dist = abs(row - 2) + abs(col- 1 - 2)
        end

    elseif a == 5       # right
        if (col+1 <= board.bounds[2]) && (board.layout[row, col+1] == 0)
            new_dist = abs(row - 2) + abs(col+ 1 - 2)
        end
    end
    
    return 10 * (dist - new_dist)

end

