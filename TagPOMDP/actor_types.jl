"""
Struct that holds the state of the game

pred_pos: row, col coords of the predator
prey_pos: row, col coords of the prey

"""
struct GameState
    pred_pos::Tuple{Int, Int}
    prey_pos::Tuple{Int, Int}
end


"""
    Map

Grid details for the Tag POMDP.

# Fields

"""
struct Map
    tag_grid::Matrix
    obstacles::Vector
    numRows::Int
    numCols::Int
    full_grid_lin_indices::LinearIndices
    full_grid_cart_indices::CartesianIndices
end

const mapSize = 7
"""
    Map(; kwargs...)

Creates a Map struct to contain the grid details for the Tag POMDP. 

Map has:
- layout: row, col coords and values for those coords
- obstacles: coordinates of the obstacles
"""
function Map()
    # 0 = free space,  1 = obstacle
    # layout = zeros(12,12)
    layout = zeros(mapSize,mapSize)
    # # layout[1,4] = 1
    # layout[3,2] = 1
    # # layout[2,1] = 1
    # layout[2,2] = 1
    # layout[2,3] = 1
    # layout[3,3] = 1

    # layout[3,1:4] .= 1
    layout[2:3,2] .= 1
    layout[2,3] = 1
    layout[5,1:3] .= 1
    layout[1:3,5] .= 1
    layout[7,2:3] .= 1
    layout[5:6,5:6] .= 1
    layout[3,7] = 1
    # layout[3,4:5] .= 1
    
    # layout[4,1] = 1
    # layout[1,1:12] .= 1
    # layout[12,1:12] .= 1
    # layout[1:12,1] .= 1
    # layout[1:12,12] .= 1

    # layout[2:3,6] .= 1
    # layout[3,3:4] .= 1
    # layout[5,3:6] .= 1
    # layout[3:7,8] .= 1
    # layout[3:4,10] .= 1
    # layout[6:7,10] .= 1
    # layout[9:10,10] .= 1
    # layout[7,2:6] .= 1
    # layout[9:10,3:8] .= 1

    # GameMap = Map(
    #     tag_grid=layout,
    #     obstacles = [],
    #     numRows = 12,
    #     numCols = 12,
    #     fill_grid_lin_indices = LinearIndices((12,12)),
    #     full_grid_cart_indices = CartesianIndices((12,12))
    # )
    # GameMap = Map(
    #     layout,
    #     [],
    #     12,
    #     12,
    #     LinearIndices((12,12)),
    #     CartesianIndices((12,12))
    # )
    GameMap = Map(
        layout,
        [],
        mapSize,
        mapSize,
        LinearIndices((mapSize,mapSize)),
        CartesianIndices((mapSize,mapSize))
    )

    return GameMap
end


struct TagPOMDP2 <: POMDP{GameState, Int, Int}
    map::Map
    discount_factor::Float64
    tag_reward::Int64
    move_away_prob::Float64
end



"""
    TagPOMDP(; kwargs...)

Returns a `TagPOMDP <: POMDP{GameState, Int, Int}`.

"""
function TagPOMDP23(;game_map::Map = Map(), discount_factor::Float64 = 0.9, tag_reward::Int64 = 500, move_away_prob = 0.8)
    # return TagPOMDP2(
    #     map = map,
    #     discount_factor = discount_factor,
    #     tag_reward = tag_reward,
    #     move_away_prob = move_away_prob
    # )
    return TagPOMDP2(
        game_map,
        discount_factor,
        tag_reward,
        move_away_prob
    )
end

Base.length(pomdp::TagPOMDP2) = pomdp.map.numRows * pomdp.map.numCols * pomdp.map.numRows * pomdp.map.numCols
POMDPs.discount(pomdp::TagPOMDP2) = pomdp.discount_factor
num_squares(grid::Map) = pomdp.map.numRows * pomdp.map.numCols
POMDPs.isterminal(pomdp::TagPOMDP2, s::GameState) = s.pred_pos == s.prey_pos