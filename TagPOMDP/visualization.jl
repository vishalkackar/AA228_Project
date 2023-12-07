function POMDPTools.render(pomdp::TagPOMDP2, step; pre_act_text::String="")

    plt = nothing
    plotted_robot = false

    if !isnothing(get(step, :b, nothing))
        plt = plot_tag(pomdp, step.b)
        plotted_robot = true
    else
        plt = plot_tag(pomdp)
    end

    if !isnothing(get(step, :s, nothing))
        offset = (0.0, 0.0)
        if step.s.prey_pos == step.s.pred_pos
            offset = (0.0, 0.1)
        end
        plt = plot_robot!(plt, step.s.prey_pos .+ offset; color=RGB(0.8, 0.1, 0.1))
        if !plotted_robot
            plt = plot_robot!(plt, step.s.pred_pos)
        end
    end

    if !isnothing(get(step, :a, nothing))
        # Determine appropriate font size based on plot size
        px_p_tick = px_per_tick(plt)
        fnt_size = Int(floor(px_p_tick / 2 / 1.3333333))
        # xc = pomdp.tag_grid.bottom_grid[1] / 2
        xc = 0.0
        yc = 0.0
        action_text = pre_act_text * "a = $(ACTION_NAMES[step.a])"
        plt = annotate!(plt, xc, yc, (text(action_text, :black, :center, fnt_size)))
    end

    return plt

end

function plot_tag(pomdp::TagPOMDP2)
    state_list = [sᵢ for sᵢ in pomdp]
    b = zeros(length(pomdp) - 1)
    return plot_tag(pomdp, b, state_list[1:end-1])
end
function plot_tag(pomdp::TagPOMDP2, b::SparseVector)
    return plot_tag(pomdp, collect(b))
end
function plot_tag(pomdp::TagPOMDP2, b::Vector{Float64})
    state_list = [sᵢ for sᵢ in pomdp]
    if length(b) == length(state_list)
        return plot_tag(pomdp, b[1:end-1], state_list[1:end-1])
    end
    return plot_tag(pomdp, b, state_list[1:end])
end
function plot_tag(pomdp::TagPOMDP2, b::DiscreteBelief)
    return plot_tag(pomdp, b.b[1:end-1], b.state_list[1:end-1])
end
function plot_tag(pomdp::TagPOMDP2, b::SparseCat)
    return plot_tag(pomdp, b.probs, b.vals)
end

function plot_tag(pomdp::TagPOMDP2, b::Vector, state_list::Vector{GameState};
    color_grad=cgrad(:Greens_9),
    prob_color_scale=1.0,
)
    grid = pomdp.map
    num_cells = num_squares(grid)

    # Get the belief of the robot and the target in each cell
    grid_t_b = zeros(num_cells)
    grid_r_b = zeros(num_cells)
    for (ii, sᵢ) in enumerate(state_list)
        # tpi = pos_cart_to_linear(grid, sᵢ.prey_pos)
        # rpi = pos_cart_to_linear(grid, sᵢ.pred_pos)
        tpi = pomdp.map.full_grid_lin_indices[sᵢ.prey_pos[1], sᵢ.prey_pos[2]]
        rpi = pomdp.map.full_grid_lin_indices[sᵢ.pred_pos[1], sᵢ.pred_pos[2]]
        grid_t_b[tpi] += b[ii]
        grid_r_b[rpi] += b[ii]
    end

    plt = plot(; legend=false, ticks=false, showaxis=false, grid=false, aspectratio=:equal)

    # for xi in 1:grid.bottom_grid[1]
    #     plt = plot!(plt, rect(0.5, 0.5, xi, 0); linecolor=RGB(1.0, 1.0, 1.0), color=:white)
    # end

    # Plot the grid
    for cell_i in 1:num_cells
        color_scale = grid_t_b[cell_i] * prob_color_scale
        if color_scale < 0.05
            color = :white
        else
            color = get(color_grad, color_scale)
        end
        # xi, yi = pos_lin_to_cart(grid, cell_i)
        # print(cell_i)
        # print(pomdp.map.full_grid_cart_indices[1])
        xi = pomdp.map.full_grid_cart_indices[cell_i][1]
        yi = pomdp.map.full_grid_cart_indices[cell_i][2]
        
        plt = plot!(plt, rect(0.5, 0.5, xi, yi); color=color)
    end

    # Determine scale of font based on plot size
    px_p_tick = px_per_tick(plt)
    fnt_size = Int(floor(px_p_tick / 4 / 1.3333333))

    # Plot the robot (tranparancy based on belief) and annotate the target belief as well
    for cell_i in 1:num_cells
        # xi, yi = pos_lin_to_cart(grid, cell_i)
        xi = pomdp.map.full_grid_cart_indices[cell_i][1]
        yi = pomdp.map.full_grid_cart_indices[cell_i][2]
        prob_text = round(grid_t_b[cell_i]; digits=2)
        if prob_text < 0.01
            prob_text = ""
        end
        plt = annotate!(xi, yi, (text(prob_text, :black, :center, fnt_size)))
        if grid_r_b[cell_i] >= 1/num_cells - 1e-5
            plt = plot_robot!(plt, (xi, yi); fillalpha=grid_r_b[cell_i])
        end
    end

    for cell_i in 1:num_cells
        row = pomdp.map.full_grid_cart_indices[cell_i][1]
        col = pomdp.map.full_grid_cart_indices[cell_i][2]
        if (pomdp.map.tag_grid[row, col] == 1)
            plt = plot!(plt, rect(0.5, 0.5, row, col); color = :black)
        end
    end

    return plt
end

function plot_robot!(plt::Plots.Plot, (x, y); fillalpha=1.0, color=RGB(1.0, 0.627, 0.0))
    body_size = 0.3
    la = 0.1
    lb = body_size
    leg_offset = 0.3
    plot!(plt, ellip(x + leg_offset, y, la, lb); color=color, fillalpha=fillalpha)
    plot!(plt, ellip(x - leg_offset, y, la, lb); color=color, fillalpha=fillalpha)
    plot!(plt, circ(x, y, body_size); color=color, fillalpha=fillalpha)
    return plt
end

function rect(w, h, x, y)
    return Shape(x .+ [w, -w, -w, w, w], y .+ [h, h, -h, -h, h])
end
function circ(x, y, r; kwargs...)
    return ellip(x, y, r, r; kwargs...)
end
function ellip(x, y, a, b; num_pts=25)
    angles = [range(0; stop=2π, length=num_pts); 0]
    xs = a .* sin.(angles) .+ x
    ys = b .* cos.(angles) .+ y
    return Shape(xs, ys)
end

function px_per_tick(plt)
    (x_size, y_size) = plt[:size]
    xlim = xlims(plt)
    ylim = ylims(plt)
    xlim_s = xlim[2] - xlim[1]
    ylim_s = ylim[2] - ylim[1]
    if xlim_s >= ylim_s
        px_p_tick = x_size / xlim_s
    else
        px_p_tick = y_size / ylim_s
    end
    return px_p_tick
end