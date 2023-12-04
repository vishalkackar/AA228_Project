const moveProb = 0.9
const preyMoveProb = 0.7

mutable struct Board
    bounds::Vector
    layout::Matrix
end

function createMap1()
    map = zeros(12,12)
    map[1,1:12] .= 1
    map[12,1:12] .= 1
    map[1:12,1] .= 1
    map[1:12,12] .= 1
    map[2:3,6] .= 1
    map[3,3:4] .= 1
    map[5,3:6] .= 1
    map[3:7,8] .= 1
    map[3:4,10] .= 1
    map[6:7,10] .= 1
    map[9:10,10] .= 1
    map[7,2:6] .= 1
    map[9:10,3:8] .= 1
    return map
end

function createMap2()
    map = zeros(12,12)
    map[1,1:12] .= 1
    map[12,1:12] .= 1
    map[1:12,1] .= 1
    map[1:12,12] .= 1

    map[4:7,6] .= 1
    map[4:7,9] .= 1
    map[10,4:6] .= 1

    return map
end

# function getWallList(board::Board)
#     map = board.layout
#     numRows = size(map)[1]
#     numCols = size(map)[2]
#     local wallCoords = []
#     for row = 1:numRows
#         for col = 1:numCols
#             if map[row,col] == 1
#                 push!(wallCoords,[row,col])
#             end
#         end
#     end

#     return wallCoords
# end

function state_to_coord(s, board::Board)
    row= Integer(floor(s/board.bounds[1]) + 1)
    col= s%board.bounds[1]

    if row== 13
        row = board.bounds[1]
    end

    if col == 0
        col = board.bounds[2]
    end

    return row,col
end

function coord_to_state(row, col, board::Board)
    return board.bounds[1] * (row-1) + col
end