
HEIGHT = 200
WIDTH = 400
colors = range(colorant"black", colorant"white")
current_color, color_state = iterate(colors)

function draw(g::Game)
    fill(current_color)
    draw(Line(50, 100, 350, 100), colorant"white")
    draw(Rect(50, 100, 20, 50), colorant"red", fill=true)
    draw(Rect(50, 100, 20, 50), colorant"white")
    draw(Circle(330, 80, 20), colorant"red", fill=true)
    draw(Circle(330, 80, 20), colorant"white")

    draw(Circle(0,0,50), colorant"red", fill=true)
    draw(Circle(WIDTH,HEIGHT,50), colorant"green", fill=true)

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
