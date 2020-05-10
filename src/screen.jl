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

struct Rect{T<:Integer}
    x::T
    y::T
    h::T
    w::T
end

struct Line{T<:Integer}
    x1::T
    y1::T
    x2::T
    y2::T
end

struct Circle{T<:Integer}
    x::T
    y::T
    r::T
end

Base.convert(T::Type{SDL2.Rect}, r::Rect) = SDL2.Rect(Cint.((r.x, r.y, r.w, r.h))...)

function clear(s::Screen)
    fill(s, s.background)
end

function Base.fill(s::Screen, c::Colorant)
    SDL2.SetRenderDrawColor(
        s.renderer,
        Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))...,
    )
    SDL2.RenderClear(s.renderer)
end

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
