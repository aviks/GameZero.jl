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

mutable struct Rect{T<:Integer} <: Geom
    x::T
    y::T
    w::T
    h::T
end

import Base:+
+(r::Rect{T}, t::Tuple{T,T}) where T = Rect(r.x+t[1], r.y+t[2], r.h, r.w)

struct Line{T<:Integer} <: Geom  
    x1::T
    y1::T
    x2::T
    y2::T
end

struct Circle{T<:Integer} <: Geom
    x::T
    y::T
    r::T
end

Base.convert(T::Type{SDL2.Rect}, r::Rect) = SDL2.Rect(Cint.((r.x, r.y, r.w, r.h))...)

function Base.setproperty!(s::Rect, p::Symbol, x)
    if hasfield(typeof(s), p)
        setfield!(s, p, x)
    else
        v = getPos(Val(p), s, x)
        setfield!(s, :x, v[1])
        setfield!(s, :y, v[2])
    end
end

getpos(X::Val, s::Rect, v::Tuple) = getpos(X, s::Rect, v[1], v[2])
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
getPos(::Val{:centerleft}, s::Rect, u, v) = (u, v-s.h/2)
getPos(::Val{:centerright}, s::Rect, u, v) = (u-s.w, v-s.h/2)
getPos(::Val{:bottomcenter}, s::Rect, u, v) = (u-s.w/2, v-s.h)
getPos(::Val{:topcenter}, s::Rect, u, v) = (u-s.w/2, v)

function clear(s::Screen)
    fill(s, s.background)
end

clear() = clear(game[].screen)

Base.fill(c::Colorant) = Base.fill(game[].screen, c)

function Base.fill(s::Screen, c::Colorant)
    SDL2.SetRenderDrawColor(
        s.renderer,
        Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))...,
    )
    SDL2.RenderClear(s.renderer)
end

draw(l::T, args...) where T <: Geom = draw(game[].screen, l, args...)

function draw(s::Screen, l::Line, c::Colorant=colorant"black")
    SDL2.SetRenderDrawColor(
        s.renderer,
        Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))...,
    )
    SDL2.RenderDrawLine(s.renderer, l.x1, l.y1, l.x2, l.y2)
end

function draw(s::Screen, r::Rect, c::Colorant=colorant"black", fill=false)
    SDL2.SetRenderDrawColor(
        s.renderer,
        Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))...,
    )
    sr = convert(SDL2.Rect, r)
    if !fill
        SDL2.RenderDrawRect(s.renderer, Ref(sr))
    else
        SDL2.RenderFillRect(s.renderer, Ref(sr))
    end
end


#Naive Algorithm, should be improved.
function draw(s::Screen, circle::Circle, c::Colorant=colorant"black", fill=false)

    SDL2.SetRenderDrawColor(
        s.renderer,
        Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))...,
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
