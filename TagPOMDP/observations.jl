# using POMDPs
# include("actor_types.jl")

POMDPs.observations(pomdp::TagPOMDP) = 1:(num_squares(pomdp.map))
POMDPs.obsindex(pomdp::TagPOMDP, o::Int) = o

function POMDPs.observation(pomdp::TagPOMDP, a::Int, sp::GameState)
    obs = observations(pomdp)
    probs = zeros(length(obs))
    
    if a == 1   # choose to jump
        surrounding_probs = surrounding_cells(pomdp, sp)

        for (i,n) in enumerate(ACTION_DIRS) # loop through actions
            p = sp.prey_pos .+ n            # get the candidate point
            
            # set the corresp value in probs to the calculated probability
            probs[pomdp.map.full_grid_cart_indices[p[1], p[2]]] = surrounding_probs[i]
        end
        
    else        # normal actions
        if has_vision(pomdp, sp)   # has vision
            # get a perfect observation of where the prey is 
            prey_row, prey_col = sp.prey_pos
            probs[pomdp.map.full_grid_lin_indices[prey_row, prey_col]] = 1
        else            # no observation
            # uniform distribution?
            probs = Uniform(length(obs))
        end
    end


    return SparseCat(obs, probs)
end

function has_vision(pomdp::TagPOMDP, sp::GameState)
    returnVal = true

    # check vision here
    x0 = sp.prey_pos[1]
    y0 = sp.prey_pos[2]

    x1 = sp.pred_pos[1]
    y1 = sp.pred_pos[2]

    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = x0 < x1 ? 1 : -1
    sy = y0 < y1 ? 1 : -1
    err = dx - dy

    while true
        # Draw pixel at (x0, y0) here
        if pomdp.map.layout[x0,y0] == 1
            # println("LOS broken!")
            returnVal = false
            break
        end
        
        # Origin and destination overlap
        if x0 == x1 && y0 == y1
            break
        end

        e2 = 2 * err
        if e2 > -dy
            err -= dy
            x0 += sx
        end
        if e2 < dx
            err += dx
            y0 += sy
        end
    end

    return returnVal
end

function surrounding_cells(pomdp::TagPOMDP, sp::GameState)
    p = sp.prey_pos

    probs = zeros(5)
    num_valid = 0

    # iterate through possible neighboring locations
    for (i,n) in enumerate(ACTION_DIRS)
        if !hit_wall(pomdp.map, p, n)       # if valid cell
            num_valid += 1                  # add to count of valid cells
            probs[i] = 1                    # set the probability of that cell to 1
        end
    end
    probs .* 0.05                           # give all valid cells a default value of 0.05

    probs[1] = 0.8 + 0.05*(5 - num_valid)   # give the coord of the prey the highest prob (sums to 1)
    return probs

end