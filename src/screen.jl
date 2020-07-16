struct Screen
    window
    renderer
    height::Int
    width::Int
    background::ARGB

    function Screen(name, w, h, color)
        win, renderer = makeWinRenderer(name, w, h)
        if !(color isa ARGB)
            color = ARGB(color)
        end
        new(win, renderer, h, w, color)
    end
end

abstract type Geom end

mutable struct Rect <: Geom
    x::Int
    y::Int
    w::Int
    h::Int
end
Rect(x::Tuple, y::Tuple) = Rect(x[1], x[2], y[1], y[2])

import Base:+
+(r::Rect, t::Tuple{T,T}) where T <: Number = Rect(Int(r.x+t[1]), Int(r.y+t[2]), r.h, r.w)

mutable struct Line <: Geom  
    x1::Int
    y1::Int
    x2::Int
    y2::Int
end

Line(x::Tuple, y::Tuple) = Line(x[1], x[2], y[1], y[2])

mutable struct Circle <: Geom
    x::Int
    y::Int
    r::Int
end


Base.convert(T::Type{SDL2.Rect}, r::Rect) = SDL2.Rect(Cint.((r.x, r.y, r.w, r.h))...)

function Base.setproperty!(s::Geom, p::Symbol, x)
    if hasfield(typeof(s), p)
        setfield!(s, p, x)
    else
        v = getPos(Val(p), s, x)
        setfield!(s, :x, round(Int, v[1]))
        setfield!(s, :y, round(Int, v[2]))
    end
end

function Base.getproperty(s::Geom, p::Symbol) 
    if hasfield(typeof(s), p)
        getfield(s, p)
    else
        v = getPos(Val(p), s)
        return v
    end
end

getPos(X::Val, s::Geom, v...) = nothing
getPos(X::Val, s::Geom, v::Tuple) = getPos(X, s, v[1], v[2])

getPos(::Val{:left}, s::Rect, v) = (v, s.y)
getPos(::Val{:right}, s::Rect, v) = (v-s.w, s.y)
getPos(::Val{:top}, s::Rect, v) = (s.x, v)
getPos(::Val{:bottom}, s::Rect, v) = (s.x, v-s.h)
getPos(::Val{:pos}, s::Rect, u, v) = getPos(Val(:topleft), s, u, v)
getPos(::Val{:topleft}, s::Rect, u, v) = (u, v)
getPos(::Val{:topright}, s::Rect, u, v) = (u-s.w, v)
getPos(::Val{:bottomleft}, s::Rect, u, v) = (u, v-s.h)
getPos(::Val{:bottomright}, s::Rect, u, v) = (u-s.w, v-s.h)
getPos(::Val{:center}, s::Rect, u, v) = (u-s.w/2, v-s.h/2)
getPos(::Val{:centerx}, s::Rect, u, v) = (u-s.w/2, s.y)
getPos(::Val{:centery}, s::Rect, u, v) = (s.x, v-s.h/2)
getPos(::Val{:centerleft}, s::Rect, u, v) = (u, v-s.h/2)
getPos(::Val{:centerright}, s::Rect, u, v) = (u-s.w, v-s.h/2)
getPos(::Val{:bottomcenter}, s::Rect, u, v) = (u-s.w/2, v-s.h)
getPos(::Val{:topcenter}, s::Rect, u, v) = (u-s.w/2, v)

getPos(::Val{:left}, s::Rect) = s.x
getPos(::Val{:right}, s::Rect) = s.x-s.w
getPos(::Val{:top}, s::Rect) = s.y
getPos(::Val{:bottom}, s::Rect) = s.y-s.h
getPos(::Val{:pos}, s::Rect) = getPos(Val(:topleft), s)
getPos(::Val{:topleft}, s::Rect) = (s.x, s.y)
getPos(::Val{:topright}, s::Rect) = (s.x-s.w, s.y)
getPos(::Val{:bottomleft}, s::Rect) = (s.x, s.y-s.h)
getPos(::Val{:bottomright}, s::Rect) = (s.x-s.w, s.y-s.h)
getPos(::Val{:center}, s::Rect) = (s.x-s.w/2, s.y-s.h/2)
getPos(::Val{:centerx}, s::Rect) = s.x-s.w/2
getPos(::Val{:centery}, s::Rect) =  s.y-s.h/2
getPos(::Val{:centerleft}, s::Rect) = (s.x, s.y-s.h/2)
getPos(::Val{:centerright}, s::Rect) = (s.x-s.w, s.y-s.h/2)
getPos(::Val{:bottomcenter}, s::Rect) = (s.x-s.w/2, s.y-s.h)
getPos(::Val{:topcenter}, s::Rect) = (s.x-s.w/2, s.y)

getPos(::Val{:center}, s::Circle, u, v) = (u, v)
getPos(::Val{:centerx}, s::Circle, u) = u
getPos(::Val{:centery}, s::Circle, v) = v

getPos(::Val{:center}, s::Circle) = (s.x, s.y)
getPos(::Val{:top}, s::Circle) = s.y-s.r
getPos(::Val{:bottom}, s::Circle) = s.y+s.r
getPos(::Val{:left}, s::Circle) = s.x-s.r
getPos(::Val{:right}, s::Circle) = s.x+s.r
getPos(::Val{:centerx}, s::Circle) = s.x
getPos(::Val{:centery}, s::Circle) = s.x

function clear(s::Screen)
    fill(s, s.background)
end

clear() = clear(game[].screen)

Base.fill(c::Colorant) = Base.fill(game[].screen, c)

function Base.fill(s::Screen, c::Colorant)
    SDL2.SetRenderDrawColor(
        s.renderer,
        sdl_colors(c)...,
    )
    SDL2.RenderClear(s.renderer)
end

draw(l::T, args...; kv...) where T <: Geom = draw(game[].screen, l, args...; kv...)

function draw(s::Screen, l::Line, c::Colorant=colorant"black")
    SDL2.SetRenderDrawColor(
        s.renderer,
        sdl_colors(c)...,
    )
    SDL2.RenderDrawLine(s.renderer, l.x1, l.y1, l.x2, l.y2)
end

function draw(s::Screen, r::Rect, c::Colorant=colorant"black"; fill=false)
    SDL2.SetRenderDrawColor(
        s.renderer,
        sdl_colors(c)...,
    )
    sr = convert(SDL2.Rect, r)
    if !fill
        SDL2.RenderDrawRect(s.renderer, Ref(sr))
    else
        SDL2.RenderFillRect(s.renderer, Ref(sr))
    end
end

sdl_colors(c::Colorant) = sdl_colors(convert(ARGB{Colors.FixedPointNumbers.Normed{UInt8,8}}, c))
sdl_colors(c::ARGB) = Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))

#Naive Algorithm, should be improved.
function draw(s::Screen, circle::Circle, c::Colorant=colorant"black"; fill=false)

    SDL2.SetRenderDrawColor(
        s.renderer,
        sdl_colors(c)...,
    )
    diameter = Cint(circle.r * 2);

    centreX = Cint(circle.x)
    centreY = Cint(circle.y)

    x = Cint(circle.r - 1)
    y = Cint(0)
    tx = Cint(1)
    ty = Cint(1)
    error = (tx - diameter)

    while (x >= y)
        #Each of the following renders an eight of the circle
        if !fill
            SDL2.RenderDrawPoint(s.renderer, centreX + x, centreY - y);
            SDL2.RenderDrawPoint(s.renderer, centreX + x, centreY + y);
            SDL2.RenderDrawPoint(s.renderer, centreX - x, centreY - y);
            SDL2.RenderDrawPoint(s.renderer, centreX - x, centreY + y);
            SDL2.RenderDrawPoint(s.renderer, centreX + y, centreY - x);
            SDL2.RenderDrawPoint(s.renderer, centreX + y, centreY + x);
            SDL2.RenderDrawPoint(s.renderer, centreX - y, centreY - x);
            SDL2.RenderDrawPoint(s.renderer, centreX - y, centreY + x);
        else
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX + x, centreY - y);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX + x, centreY + y);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX - x, centreY - y);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX - x, centreY + y);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX + y, centreY - x);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX + y, centreY + x);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX - y, centreY - x);
            SDL2.RenderDrawLine(s.renderer, centreX, centreY, centreX - y, centreY + x);
        end

        if (error <= 0)
            y += Cint(1)
            error += ty
            ty += Cint(2)
        end

        if (error > 0)
            x -= Cint(1)
            tx += Cint(2)
            error += (tx - diameter)
        end
  end
end

rect(x::Rect) = x
rect(x::Circle) = Rect(x.left, x.top, 2*x.r, 2*x.r)
