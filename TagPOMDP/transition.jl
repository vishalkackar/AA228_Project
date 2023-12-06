"""
    POMDPs.transition(pomdp::TagPOMDP, s::TagState, a::Int)

Transition function for the TagPOMDP. This transition is mimics the original paper.
"""
function POMDPs.transition(pomdp::TagPOMDP, s::GameState, a::Int)
    # Check if tagged first. If so, stay put and flip to tagged=true state
    if a == ACTIONS_DICT[:tag]
        if s.r_pos == s.t_pos
            return Deterministic(pomdp.terminal_state)
        end
    end

    return transition_function(pomdp::TagPOMDP, s::TagState, a::Int)
end


"""
Transition function for the TagPOMDP. This transition is mimics the original paper.
    implementation is structured to be closely aligned with the modified transition
    function.
"""
function transition_function(pomdp::TagPOMDP, s::TagState, a::Int)
    pred_row, pred_col = s.pred_pos
    prey_row, prey_col = s.prey_pos
    grid = pomdp.map
    t_move_pos_options = Vector{Tuple{Int, Int}}()

    # Counters added to modify transition probability to align with original implementation
    cnt_wall_hits_ns = 0
    cnt_ns_options = 0
    cnt_wall_hits_ew = 0
    cnt_ew_options = 0

    # Look for viable moves for the target to move "away" from the robot
    for card_d_i in COL_DIRS
        if ACTION_INEQ[card_d_i](prey_col, pred_col)
            cnt_ew_options += 1
            d_i = ACTION_DIRS[ACTIONS_DICT[card_d_i]]
            if !hit_wall(grid, s.prey_pos, d_i)
                push!(t_move_pos_options, move_direction(grid, s.prey_pos, d_i))
            else
                cnt_wall_hits_ew += 1
            end
        end
    end
    for card_d_i in ROW_DIRS
        if ACTION_INEQ[card_d_i](prey_row, pred_row)
            cnt_ns_options += 1
            d_i = ACTION_DIRS[ACTIONS_DICT[card_d_i]]
            if !hit_wall(grid, s.prey_pos, d_i)
                push!(t_move_pos_options, move_direction(grid, s.prey_pos, d_i))
            else
                cnt_wall_hits_ns += 1
            end
        end
    end

    # Split the move_away_probability across E-W and N-S movements. If a move away direction
    # results in hitting a wall, that probability is allocated to the "stay in place"
    # transition
    ns_moves = cnt_ns_options - cnt_wall_hits_ns
    ew_moves = cnt_ew_options - cnt_wall_hits_ew

    ns_prob = pomdp.move_away_probability / 2 / cnt_ns_options
    ew_prob = pomdp.move_away_probability / 2 / cnt_ew_options

    # Create the transition probability array
    t_probs = ones(length(t_move_pos_options) + 1)
    t_probs[1:ew_moves] .= ew_prob
    t_probs[ew_moves+1:ew_moves+ns_moves] .= ns_prob

    push!(t_move_pos_options, s.t_pos)
    t_probs[end] = 1.0 - sum(t_probs[1:end-1])

    # Robot position is deterministic
    r_pos′ = move_direction(pomdp.tag_grid, s.r_pos, ACTION_DIRS[a])

    states = Vector{TagState}(undef, length(t_move_pos_options))
    for (ii, t_pos′) in enumerate(t_move_pos_options)
        states[ii] = TagState(r_pos′, t_pos′, false)
    end
    return SparseCat(states, t_probs)
end


function move_direction(grid::Map, p::Tuple{Int, Int}, d::Tuple{Int, Int})
    if hit_wall(grid, p, d)
        return p
    end

    return p .+ d
end


function hit_wall(grid::Map, p::Tuple{Int, Int}, d::Tuple{Int, Int})
    p′ = p .+ d

    if p′[1] > grid.numRows || p′ < 0 
        return 
    # add collision and bounds checking here  
end