include("Board.jl")
using LinearAlgebra

mutable struct QLearning
    𝒮 # state space (assumes 1:nstates)
    𝒜 # action space (assumes 1:nactions)
    γ # discount
    Q # action value function
    α # learning rate
end

function update!(model::QLearning, s, a, r, sp)
    γ, Q, α = model.γ, model.Q, model.α
    Q[s,a] += α*(r + γ*maximum(Q[sp,:]) - Q[s,a])
    return model
end

function simulate(P::MDP, model, pol, h, s)
    for i in 1:h
        a = pol(model, s)
        sp, r = P.TR(s, a)
        update!(model, s, a, r, sp)
        s = sp
    end
end


