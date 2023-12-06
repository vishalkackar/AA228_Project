function POMDPs.reward(pomdp::TagPOMDP2, s::GameState, a::Int)
    # if pred tagged prey then give tag reward
    if (s.pred_pos == s.prey_pos)
        return pomdp.tag_reward

    # otherwise reward is inversely proportional to manhattan distance
    else
        manhattan_dist = abs(s.pred_pos[1] - s.prey_pos[1]) + abs(s.pred_pos[2] - s.prey_pos[2])
        return -5 * manhattan_dist
    end
end




# function POMDPs.reward(pomdp::TagPOMDP2, s::TagState, a::Int)
#     if isterminal(pomdp, s)
#         return 0.0
#     end
#     if a == ACTIONS_DICT[:tag]
#         if s.r_pos == s.t_pos
#             return pomdp.tag_reward
#         end
#         return pomdp.tag_penalty
#     end
#     return pomdp.step_penalty
# end