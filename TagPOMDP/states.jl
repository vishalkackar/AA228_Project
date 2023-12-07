function POMDPs.stateindex(pomdp::TagPOMDP2, s::GameState)
    # total # of states is 144 x 144 because we have 144 possible prey positions given a predator position
    # there are 144 possible predator positions

    # get cartesian cords of predator and prey
    pred_coords = s.pred_pos
    prey_coords = s.prey_pos

    # convert cartesian coords to linear index
    # pred_lin = (pred_coords[2] - 1) * pomdp.map.numRows + pred_coords[1]
    # prey_lin = (prey_coords[2] - 1) * pomdp.map.numRows + prey_coords[1]
    pred_lin = pomdp.map.full_grid_lin_indices[pred_coords[1], pred_coords[2]]
    prey_lin = pomdp.map.full_grid_lin_indices[prey_coords[1], prey_coords[2]]

    # convert linear index to state index
    state_idx = (pred_lin - 1) * (pomdp.map.numRows * pomdp.map.numCols) + prey_lin

    return state_idx
end

function POMDPs.initialstate(pomdp::TagPOMDP2)
    # change to just be one init state?
    # hard code:
    #           pred = 11,6
    #           prey = 4,3
    # states = [8380]
    # probs = [1]

    # num_s = num_squares(pomdp.map)
    # probs = normalize(ones(num_s * num_s), 1)
    # states = Vector{GameState}(undef, num_s * num_s)
    # for ii in 1:(num_s * num_s)
    #     states[ii] = state_from_index(pomdp, ii)
    # end
    # println("initial")
    # println(length(states))
    # println(length(probs))


    states = [GameState((1,1), (mapSize,mapSize))]
    probs = [1]
    
    return SparseCat(states, probs)
end

POMDPs.states(pomdp::TagPOMDP2) = pomdp

function Base.iterate(pomdp::TagPOMDP2, ii::Int=1)
    if ii > length(pomdp)
        return nothing
    end
    s = state_from_index(pomdp, ii)
    return (s, ii + 1)
end

function state_from_index(pomdp::TagPOMDP2, si::Int)
    # convert the state into predator and prey linear indices
    pred_lin = trunc(Int, (si-1)/(pomdp.map.numRows * pomdp.map.numCols)) + 1
    prey_lin = si - (pomdp.map.numRows * pomdp.map.numCols) * (pred_lin-1)

    # convert linear indices into cartesian coords
    pred_coord = pomdp.map.full_grid_cart_indices[pred_lin]
    prey_coord = pomdp.map.full_grid_cart_indices[prey_lin]

    return GameState(
        Tuple(pred_coord),
        Tuple(prey_coord)
    )

end
