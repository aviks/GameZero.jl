
mutable struct Actor
    image::String
    surface::Ptr{SDL2.Surface}
    position::Rect
    scale::Float64
    angle::Int
    data::Dict{Symbol, Any}
end

function Actor(image::String)
    sf=image_surface(image)
    w, h = size(sf)
    return Actor(image, sf, Rect(0, 0, Int(w), Int(h)), 1.0 , 0, Dict{Symbol,Any}())
end

function Base.setproperty!(s::Actor, p::Symbol, x)
    if hasfield(Actor, p)
        setfield!(s, p, x)
    elseif p == :image
        sf = image_surface(x)
        setfield!(s, :surface, sf)
    elseif p == :x
        return getfield(s, :position).x = x
    elseif p == :y
        return getfield(s, :position).y = x
    elseif p == :w
        return getfield(s, :position).w = x
    elseif p == :h
        return getfield(s, :position).h = x
    else
        data = getfield(s, :data)[p] = x
    end
end


function Base.getproperty(s::Actor, p::Symbol)
    if hasfield(Actor, p)
        getfield(s, p)
    elseif p == :x
        return getfield(s, :position).x
    elseif p == :y
        return getfield(s, :position).y
    elseif p == :w
        return getfield(s, :position).w
    elseif p == :h
        return getfield(s, :position).h
    else
        data = getfield(s, :data)
        if haskey(data, p)
            return data[p]
        else 
            @warn "Unknown data $p requested from Actor($(s.image))"
            return nothing
        end
    end
end

function draw(a::Actor)
    texture = SDL2.CreateTextureFromSurface(game[].screen.renderer, a.surface)
    r=a.position
    SDL2.RenderCopy(game[].screen.renderer, texture, C_NULL, Ref(SDL2.Rect(r.x, r.y, r.w, r.h)) )
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
