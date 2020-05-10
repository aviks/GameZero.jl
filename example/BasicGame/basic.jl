
HEIGHT = 400
WIDTH = 400
BACKGROUND = colorant"purple"
count = 1
dx = 2
dy = 2

a=Actor("alien.png")

play_music("radetzky_ogg")

function draw(g::Game)
    draw(a)
end

function update(g::Game)
    global count, dx, dy
    count = count+1
    a.pos=a.pos .+ (dx, dy)
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

function on_key_down(g, k)
    if k == Keys.SPACE
        alien_hurt()
        schedule_once(alien_normal, 1)
    end
end

alien_hurt() = a.image = "alien_hurt.png"
alien_normal() = a.image = "alien.png"
