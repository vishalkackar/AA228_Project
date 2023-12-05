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

"""
    Map(; kwargs...)

Creates a Map struct to contain the grid details for the Tag POMDP. 

Map has:
- layout: row, col coords and values for those coords
- obstacles: coordinates of the obstacles
"""
function Map()
    # 0 = free space,  1 = obstacle
    layout = zeros(12,12)
    layout[1,1:12] .= 1
    layout[12,1:12] .= 1
    layout[1:12,1] .= 1
    layout[1:12,12] .= 1
    layout[2:3,6] .= 1
    layout[3,3:4] .= 1
    layout[5,3:6] .= 1
    layout[3:7,8] .= 1
    layout[3:4,10] .= 1
    layout[6:7,10] .= 1
    layout[9:10,10] .= 1
    layout[7,2:6] .= 1
    layout[9:10,3:8] .= 1

    GameMap = Map(
        tag_grid=layout,
        obstacles = [],
        numRows = 12,
        numCols = 12,
        fill_grid_lin_indices = LinearIndices((12,12)),
        full_grid_cart_indices = CartesianIndices((12,12))
    )

    return GameMap
end


struct TagPOMDP <: POMDP{GameState, Int, Int}
    map::Map
    discount_factor::Float64
    tag_reward::UInt16
end



"""
    TagPOMDP(; kwargs...)

Returns a `TagPOMDP <: POMDP{TagState, Int, Int}`.

"""
function TagPOMDP(;game_map::Map = Map(), discount_factor::Float64 = 0.9, tag_reward::UInt16 = 500)
    return TagPOMDP(
        map = game_map,
        discount_factor = discount_factor,
        tag_reward = tag_reward
    )
end

Base.length(pomdp::TagPOMDP) = grid.numRows * grid.numCols * grid.numRows * grid.numCols
POMDPs.discount(pomdp::TagPOMDP) = pomdp.discount_factor
num_squares(grid::Map) = grid.numRows * grid.numCols