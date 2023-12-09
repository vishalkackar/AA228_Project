function POMDPs.reward(pomdp::TagPOMDP2, s::GameState, a::Int)
    # if pred tagged prey then give tag reward
    if (s.pred_pos == s.prey_pos)
        return pomdp.tag_reward

    # otherwise reward is inversely proportional to manhattan distance
    else
        manhattan_dist = abs(s.pred_pos[1] - s.prey_pos[1]) + abs(s.pred_pos[2] - s.prey_pos[2])

        if a == 1
            return -50
        else
            return -5 * manhattan_dist
        end
        
    end
end