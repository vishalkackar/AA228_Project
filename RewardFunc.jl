include("Board.jl")

function Reward_Func(s, a, board::Board, coords)
    preyRow = coords[1]
    preyCol = coords[2]
    # println(coords)

    row,col = state_to_coord(s, board)
    dist = abs(row - preyRow) + abs(col - preyCol)
    new_dist = dist

    # distance doesn't change if we stay

    if a == 2           # up
        if ((row - 1 > 0) && board.layout[row-1, col] == 0)
            new_dist = abs(row - 1 - preyRow) + abs(col - preyCol)
        end

    elseif a == 3       # down
        if (row + 1 <= board.bounds[1]) && (board.layout[row+1, col] == 0)
            new_dist = abs(row + 1 - preyRow) + abs(col - preyCol)
        end

    elseif a == 4       # left
        if (col-1 > 0) && (board.layout[row, col-1] == 0)
            new_dist = abs(row - preyRow) + abs(col - 1 - preyCol)
        end

    elseif a == 5       # right
        if (col+1 <= board.bounds[2]) && (board.layout[row, col+1] == 0)
            new_dist = abs(row - preyRow) + abs(col + 1 - preyCol)
        end
    end
    
    return 10 * (dist - new_dist)

end