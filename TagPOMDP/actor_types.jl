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

const mapSize = 12
"""
    Map(; kwargs...)

Creates a Map struct to contain the grid details for the Tag POMDP. 

Map has:
- layout: row, col coords and values for those coords
- obstacles: coordinates of the obstacles
"""
function Map1()
    # 0 = free space,  1 = obstacle
    layout = zeros(mapSize,mapSize)
   
    layout[1,12] = 1
    layout[2:3,6] .= 1
    layout[3,3:4] .= 1
    layout[5,3:6] .= 1
    layout[3:7,8] .= 1
    layout[3:4,10] .= 1
    layout[6:7,10:11] .= 1
    layout[9:10,10] .= 1
    layout[7,2:6] .= 1
    layout[9:10,3:8] .= 1
    layout[10,11] = 1

    
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

function Map2()
    # 0 = free space,  1 = obstacle
    layout = zeros(mapSize,mapSize)
   
    layout[4:7,6] .= 1
    layout[4:6,9] .= 1
    layout[10,4:6] .= 1

    
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

function Map3()
    # 0 = free space,  1 = obstacle
    layout = zeros(mapSize,mapSize)
   
    layout[2,3:6] .= 1
    layout[2:6,3] .= 1
    layout[8:10,4] .= 1
    layout[2:5,8] .= 1
    layout[4:6,11] .= 1
    layout[8,7:9] .= 1
    layout[11,8:10] .= 1
    layout[7,8] = 1

    
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

function Map4()
    # 0 = free space,  1 = obstacle
    layout = zeros(mapSize,mapSize)
   
    layout[2:3,2:3] .= 1
    layout[2:3,6:7] .= 1
    layout[2:3,10:11] .= 1
    layout[6:7,2:3] .= 1
    layout[6:7,6:7] .= 1
    layout[6:7,10:11] .= 1
    layout[10:11,2:3] .= 1
    layout[10:11,6:7] .= 1
    layout[10:11,10:11] .= 1
    
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
function TagPOMDP2_1(;game_map::Map = Map1(), discount_factor::Float64 = 0.9, tag_reward::Int64 = 500, move_away_prob = 0.6)
    return TagPOMDP2(
        game_map,
        discount_factor,
        tag_reward,
        move_away_prob
    )
end

function TagPOMDP2_2(;game_map::Map = Map2(), discount_factor::Float64 = 0.9, tag_reward::Int64 = 500, move_away_prob = 0.9)
    return TagPOMDP2(
        game_map,
        discount_factor,
        tag_reward,
        move_away_prob
    )
end


function TagPOMDP2_3(;game_map::Map = Map3(), discount_factor::Float64 = 0.9, tag_reward::Int64 = 500, move_away_prob = 0.6)
    return TagPOMDP2(
        game_map,
        discount_factor,
        tag_reward,
        move_away_prob
    )
end

function TagPOMDP2_4(;game_map::Map = Map4(), discount_factor::Float64 = 0.9, tag_reward::Int64 = 500, move_away_prob = 0.6)
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