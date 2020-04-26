
HEIGHT = 200
WIDTH = 400
colors = range(colorant"red", colorant"green")
current_color, color_state = iterate(colors)

function draw(g::Game)
    fill(g.screen, current_color)
end

function update(g::Game)
    global current_color
    global color_state
    i = iterate(colors, color_state)
    if !isnothing(i)
        current_color, color_state = i
    else
        reverse!(colors)
        current_color, color_state = iterate(colors)
    end

end
