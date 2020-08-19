
# Height of the screen
HEIGHT = 200
# Width of the screen
WIDTH = 400
# Global variables to store a range of colors. 
# The Colors package is always imported into a game
colors = range(colorant"black", colorant"white")
current_color, color_state = iterate(colors)

# The draw function is called once per frame to render objects to the screen.
# In our game, we only define the `draw` function, it's called by the engine. 
# Within the function, we draw the individual elements, in this case line, rectangles and circles
function draw()
    fill(current_color)
    draw(Line(50, 100, 350, 100), colorant"white")
    draw(Rect(50, 100, 20, 50), colorant"red", fill=true)
    draw(Rect(50, 100, 20, 50), colorant"white")
    draw(Circle(330, 80, 20), colorant"red", fill=true)
    draw(Circle(330, 80, 20), colorant"white")

    draw(Circle(0,0,50), colorant"red", fill=true)
    draw(Circle(WIDTH,HEIGHT,50), colorant"green", fill=true)

end

# The update function is called once per frame by the game engine, and should be used
# to change the game state. In this case, we iterate through the color range, and store
# the current color in a global variable. The global value is then used in the `draw`
# function to render the screen background
function update()
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
