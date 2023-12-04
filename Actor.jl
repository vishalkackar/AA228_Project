using Random
include("Board.jl")

mutable struct Actor
    pos::Vector
    name::String
    action_history::Vector
    coord_history::Vector{Vector}
    actions::Vector
    board::Board
    ad_coords::Vector # estimated coordinates of adversary
end

function stochMovePred()
    if rand() <= moveProb
        return true
    else
        println("Predator failed to move!")
        return false
    end
end

function stochMovePrey()
    if rand() <= preyMoveProb
        return true
    else
        println("Prey failed to move!")
        return false
    end
end


function get_prey_move(prey::Actor, pred::Actor)    
    b = prey.board
    row = prey.pos[1]
    col = prey.pos[2]

    # get manhattan distance between prey and predator
    curr_dist = abs(row - pred.pos[1]) + abs(col - pred.pos[2])

    if stochMovePrey()
        # find the direction that maximizes manhattan distance
        # up
        up_dist = -1
        if ( (b.layout[row-1,col] == 0) && (row-1 > 0) )
            up_dist = abs(row-1 - pred.pos[1]) + abs(col - pred.pos[2])
        end

        # down
        down_dist = -1
        if ( (b.layout[row+1,col] == 0) && (row+1 < b.bounds[1]) )
            down_dist = abs(row+1 - pred.pos[1]) + abs(col - pred.pos[2])
        end

        # left
        left_dist = -1
        if ( (b.layout[row, col-1] == 0) && (col-1 > 0) )
            left_dist = abs(row - pred.pos[1]) + abs(col-1 - pred.pos[2])
        end

        # right
        right_dist = -1
        if ( (b.layout[row, col+1] == 0) && (col+1 < b.bounds[2]) )
            right_dist = abs(row - pred.pos[1]) + abs(col+1 - pred.pos[2])
        end

        distances = [curr_dist-1, up_dist, down_dist, left_dist, right_dist]
        i = argmax(distances)
        coords = [[row,col], [row-1,col], [row+1,col], [row,col-1], [row,col+1]]

        # println("Prey distances $distances ")
        
        prey.pos = coords[i]
        # push!(prey.coord_history, coords[i])
        # push!(prey.action_history, i)
    end
        

end

# Bresenham's line algorithm to raycast and detect wall intersections
# https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
#   (x0, y0) - raycast origin
#   (x1, y1) - raycast destination
#   map - coordinates of walls in map (walls must == 1)
# function test_vision(prey, predator, map)
function test_vision(prey::Actor, pred::Actor, map)
    x0 = prey.pos[1]
    y0 = prey.pos[2]

    x1 = pred.pos[1]
    y1 = pred.pos[2]

    returnVal = true
    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = x0 < x1 ? 1 : -1
    sy = y0 < y1 ? 1 : -1
    err = dx - dy

    while true
        # Draw pixel at (x0, y0) here
        if map[x0,y0] == 1
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