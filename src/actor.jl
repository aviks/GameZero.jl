
mutable struct Actor
    image::String
    surface
    w::Int
    h::Int
    x::Int
    y::Int
    scale::Float64
end

function Actor(image::String)
    sf=image_surface(image)
    w, h = size(sf)
    return Actor(image, sf, w, h, 0, 0, 1)
end

function Base.setproperty!(s::Actor, p::Symbol, x)
    if p == :pos
        if typeof(x) != Tuple{Int, Int}; throw(ArgumentError(":pos needs a tuple of Integers")); end
        setfield!(s, :x, x[1])
        setfield!(s, :y, x[2])
    elseif p == :image
        sf = image_surface(x)
        setfield!(s, p, x)
        setfield!(s, :surface, sf)
    else
        setfield!(s, p, x)
    end
end

function Base.getproperty(s::Actor, p::Symbol)
    if p == :pos
        return (s.x, s.y)
    else
        getfield(s, p,)
    end
end

function draw(a::Actor)
    texture = SDL2.CreateTextureFromSurface(game[].screen.renderer, a.surface)
    SDL2.RenderCopy(game[].screen.renderer, texture, C_NULL, Ref(SDL2.Rect(a.x, a.y, a.w, a.h)) )
end

"""Angle to the horizontal, of the line between two actors, in degrees"""
function angle(a::Actor, target::Actor)
    angle(a, a.pos...)
end

"""Angle to the horizontal, of the line between an actor and a point in space, in degrees"""
function angle(a::Actor, tx, ty)
    myx, myy = a.pos
    dx = tx - myx
    dy = myy - ty
    return deg2rad(atan(dy/dx))
end

"""Distance in pixels between two actors"""
function distance(a::Actor, target::Actor)
    distance(a, target.pos...)
end

"""Distance in pixels between an actor and a point in space"""
function distance(a::Actor, tx, ty)
    myx, myy = a.pos
    dx = tx - myx
    dy = ty - myy
    return sqrt(dx * dx + dy * dy)
end

atan2(y, x) = pi - pi/2 * (1 + sign(x)) * (1 - sign(y^2)) - pi/4 * (2 + sign(x)) * sign(y) -
                            sign(x*y) * atan((abs(x) - abs(y)) / (abs(x) + abs(y)))


function Base.size(s::Ptr{SDL2.Surface})
    ss = unsafe_load(s)
    return (ss.w, ss.h)
end

function collide(a, x::Integer, y::Integer)
    return a.x <= x < (a.x + a.w) &&
        a.y <= y < (a.y + a.h)
end

collide(a, pos::Tuple) = collide(a, pos[1], pos[2])


function  collide(a, b)
    return a.x < b.x + b.w &&
        a.y < b.y + b.h &&
        a.x + a.w > b.x &&
        a.y + a.h > b.y

end
