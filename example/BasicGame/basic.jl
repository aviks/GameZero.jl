
# Height of the game window
HEIGHT = 400
# Width of the game window
WIDTH = 400
# Background color of the game window
BACKGROUND = colorant"purple"

# Globals to store the velocity of the actor
dx = 2
dy = 2

# Create an `Actor` object with an image
a=Actor("alien.png")
txt = TextActor("Hello World", "moonhouse")
txt.pos = (120,180)

# Start playing background music
play_music("radetzky_ogg")

# The draw function is called by the framework. All we do here is draw the Actor
function draw(g::Game)
    draw(a)
    draw(txt)
end

# The update function is called every frame. Within the function, we 
# * change the position of the actor by the velocity
# * if the actor hits the edges, we invert the velocity, and play a sound 
# * if the up/down/left/right keys are pressed, we change the velocity to move the actor in the direction of the keypress 
function update(g::Game)
    global dx, dy
    a.position.x += dx
    a.position.y += dy
    if a.x > 400-a.w || a.x < 2
        dx = -dx
        play_sound("eep")
    end
    if a.y > 400-a.h || a.y < 2
        dy = -dy
        play_sound("eep")
    end

    if g.keyboard.DOWN
        dy = 2
    elseif g.keyboard.UP
        dy = -2
    elseif g.keyboard.LEFT
        dx = -2
    elseif g.keyboard.RIGHT
        dx = 2
    end

end

# If the "space" key is pressed, change the displayed image to the "hurt" variant. 
# Also schedule an event to change it back to normal after one second. 
function on_key_down(g, k)
    if k == Keys.SPACE
        alien_hurt()
        schedule_once(alien_normal, 1)
    end
end

# We define functions to change the image for the actor. These functions are called from the keydown and scheduled events. 
alien_hurt() = a.image = "alien_hurt.png"
alien_normal() = a.image = "alien.png"
