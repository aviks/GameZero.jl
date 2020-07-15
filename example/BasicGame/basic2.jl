
HEIGHT = 200
WIDTH = 400
colors = range(colorant"red", colorant"green")
current_color, color_state = iterate(colors)

function draw(g::Game)
    fill(current_color)
    draw(GameZero.Line(50, 100, 350, 100), colorant"white")
    draw(GameZero.Rect(50, 100, 20, 50), colorant"red", true)
    draw(GameZero.Rect(50, 100, 20, 50), colorant"white")
    draw(GameZero.Circle(330, 80, 20), colorant"red", true)
    draw(GameZero.Circle(330, 80, 20), colorant"white")
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
