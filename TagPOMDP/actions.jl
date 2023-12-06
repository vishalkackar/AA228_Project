const COL_DIRS = (:east, :west)
const ROW_DIRS = (:north, :south)
const ACTIONS_DICT = Dict(:jump => 1, :north => 2, :south => 3, :east => 4, :west => 5)
const ACTION_INEQ = Dict(:north => >=, :east => >=, :south => <=, :west => <=)
const ACTION_NAMES = Dict(1 => "Jump", 2 => "North", 3 => "South", 4 => "East", 5 => "West")
const ACTION_DIRS = [(0,0), (-1, 0), (1, 0), (0, 1), (0, -1)]

POMDPs.actions(pomdp::TagPOMDP) = 1:length(ACTIONS_DICT)
POMDPs.actionindex(POMDP::TagPOMDP, a::Int) = a