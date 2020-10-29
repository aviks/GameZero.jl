
mutable struct Actor
    image::String
    surface::Ptr{SDL2.Surface}
    position::Rect
    scale::Vector{Float64}
    angle::Float64
    alpha::UInt8
    data::Dict{Symbol, Any}
end

"""
`Actor(image::String)`

Creates an Actor with the image given, which must be located in the `image` subdirectory.
"""
function Actor(image::String; kv...)
    sf=image_surface(image)
    w, h = size(sf)
    a = Actor(image, sf, Rect(0, 0, Int(w), Int(h)), [1.0, 1.0], 0, 255, Dict{Symbol,Any}())

    for (k, v) in kv
        setproperty!(a, k, v)
    end
    return a
end


function Base.setproperty!(s::Actor, p::Symbol, x)
    if p == :image
        sf = image_surface(x)
        setfield!(s, :surface, sf)
    elseif hasfield(Actor, p)
        setfield!(s, p, convert(fieldtype(Actor, p), x))
    else
        position = getfield(s, :position)
        v = getproperty(position, p)
        if v != nothing
            setproperty!(position, p, x)
        else
            getfield(s, :data)[p] = x
        end
    end
end


function Base.getproperty(s::Actor, p::Symbol)
    if hasfield(Actor, p)
        getfield(s, p)
    else
        position = getfield(s, :position)
        v = getproperty(position, p)
        if v != nothing
            return v
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
end

"""
`draw(a::Actor)`

Draws the Actor on-screen at its current position.
"""
function draw(a::Actor)
    texture = SDL2.CreateTextureFromSurface(game[].screen.renderer, a.surface)
    r=a.position
    w′=floor(r.w * a.scale[1])
    h′=floor(r.h * a.scale[2])

    if (a.alpha < 255)
        SDL2.SetTextureBlendMode(texture, SDL2.BLENDMODE_BLEND)
        SDL2.SetTextureAlphaMod(texture, a.alpha)
    end
    
    SDL2.RenderCopyEx(
        game[].screen.renderer, 
        texture, 
        C_NULL,
        Ref(SDL2.Rect(r.x, r.y, w′, h′)),
        a.angle,
        C_NULL,
        UInt32(0) 
    )
    SDL2.DestroyTexture(texture)
end

"""
`angle(a1::Actor, a2::Actor)`

Angle between the horizontal and the line between two actors. Value returned is in degrees.
"""
function Base.angle(a::Actor, target::Actor)
    angle(a, a.pos...)
end

"""
`angle(a::Actor, xy::Tuple{Number, Number})`

Angle between the horizontal of the line between an actor and a point in space. Value returned is in degrees.
"""
Base.angle(a::Actor, txy::Tuple) = angle(a, txy[1], txy[2])

"""
`angle(a::Actor, x::Number, y::Number)`

Angle between the horizontal of the line between an actor and a point in space. Value returned is in degrees.
"""
function Base.angle(a::Actor, tx, ty)
    myx, myy = a.pos
    dx = tx - myx
    dy = myy - ty
    return deg2rad(atan(dy/dx))
end

"""
`distance(a1::Actor, a2::Actor)`

Distance in pixels between two actors.
"""
function distance(a::Actor, target::Actor)
    distance(a, target.pos...)
end

"""
`distance(a::Actor, x::Number, y::Number)`

Distance in pixels between an actor and a point in space
"""
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


"""
```
collide(a, x::Integer, y::Integer)
collide(a, xy::Tuple{Integer, Integer})
```

Checks if a (a game object) is colliding with a point.
"""
function collide(a, x::Integer, y::Integer)
    a=rect(a)
    return a.x <= x < (a.x + a.w) &&
        a.y <= y < (a.y + a.h)
end

collide(a, pos::Tuple) = collide(a, pos[1], pos[2])

"""
`collide(a, b)`

Checks if a and b (both game objects) are colliding.
"""
function collide(a, b)
    a=rect(a)
    b=rect(b)
    return a.x < b.x + b.w &&
        a.y < b.y + b.h &&
        a.x + a.w > b.x &&
        a.y + a.h > b.y

end

rect(a::Actor) = a.position
