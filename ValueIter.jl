# include("Actor.jl")
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
    x = Integer(floor(s/board.bounds[1]) + 1)
    y = s%board.bounds[1]

    if x == 13
        x = 12
    end

    if y == 0
        y = 12
    end

    return x,y
end

function coord_to_state(x, y, board::Board)
    return board.bounds[1] * (x-1) + y
end

function Reward_Func(s, a, board::Board)
    # assume prey is stationary at 2,2
    x,y = state_to_coord(s, board)
    dist = abs(x - 2) + abs(y - 2)
    new_dist = dist

    # distance doesn't change if we stay

    if a == 2           # up
        if ((x - 1 > 0) && board.layout[x-1, y] == 0)
            new_dist = abs(x - 1 - 2) + abs(y - 2)
        end

    elseif a == 3       # down
        if (x + 1 <= board.bounds[1]) && (board.layout[x+1, y] == 0)
            new_dist = abs(x + 1 - 2) + abs(y - 2)
        end

    elseif a == 4       # left
        if (y-1 > 0) && (board.layout[x, y-1] == 0)
            new_dist = abs(x - 2) + abs(y - 1 - 2)
        end

    elseif a == 5       # right
        if (y+1 <= board.bounds[2]) && (board.layout[x, y+1] == 0)
            new_dist = abs(x - 2) + abs(y + 1 - 2)
        end
    end
    
    return 10 * (dist - new_dist)

end

