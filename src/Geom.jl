################################################################################
################################################################################
# geometric types
################################################################################
################################################################################

abstract type Geom end

################################################################################
# non-fillable
################################################################################

mutable struct Line <: Geom  
  x1::Int
  y1::Int
  x2::Int
  y2::Int
  
  Line(x::Tuple, y::Tuple) = Line(x[1], x[2], y[1], y[2])
end

################################################################################
# fillable
################################################################################

mutable struct Rect <: Geom
  x::Int
  y::Int
  w::Int
  h::Int

  Rect(x::Tuple, y::Tuple) = Rect(x[1], x[2], y[1], y[2])
end

mutable struct Triangle <: Geom
  p1::Vector{Int}
  p2::Vector{Int}
  p3::Vector{Int}

  function Triangle(p1::Vector{Int}, p2::Vector{Int}, p3::Vector{Int})
    if !(length(p1) == length(p2) == length(p3) == length(p3) == 2)
      error("Given vectors are of incompatible size.")
    end
    return new(p1, p2, p3)
  end

  function Triangle(x1::Int, y1::Int, x2::Int, y2::Int, x3::Int, y3::Int)
    new([x1; y1], [x2; y2], [x3; y3])
  end

  function Triangle(p1::Tuple, p2::Tuple, p3::Tuple)
    if !(length(p1) == length(p2) == length(p3) == length(p3) == 2)
      error("Given tuples are of incompatible size.")
    end
    return new([p1[1]; p1[2]], [p2[1]; p2[2]], [p3[1]; p3[2]])
  end
end

mutable struct Circle <: Geom
  x::Int
  y::Int
  r::Int
end

################################################################################
################################################################################
# methods
################################################################################
################################################################################

function +(r::Rect, t::Tuple{T,T}) where T <: Number
  Rect(Int(r.x+t[1]), Int(r.y+t[2]), r.h, r.w)
end

function Base.convert(T::Type{SDL2.Rect}, r::Rect)
  SDL2.Rect(Cint.((r.x, r.y, r.w, r.h))...)
end

rect(x::Rect) = x
rect(x::Circle) = Rect(x.left, x.top, 2*x.r, 2*x.r)


function Base.setproperty!(s::Geom, p::Symbol, x)
  if hasfield(typeof(s), p)
    setfield!(s, p, Int(round(x)))
  else
    v = getPos(Val(p), s, x)
    setfield!(s, :x, Int(round(v[1])))
    setfield!(s, :y, Int(round(v[2])))
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
getPos(::Val{:centerx}, s::Rect, u) = (u-s.w/2, s.y)
getPos(::Val{:centery}, s::Rect, v) = (s.x, v-s.h/2)
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
getPos(::Val{:topright}, s::Rect) = (s.x+s.w, s.y)
getPos(::Val{:bottomleft}, s::Rect) = (s.x, s.y+s.h)
getPos(::Val{:bottomright}, s::Rect) = (s.x-s.w, s.y-s.h)
getPos(::Val{:center}, s::Rect) = (s.x-s.w/2, s.y-s.h/2)
getPos(::Val{:centerx}, s::Rect) = s.x-s.w/2
getPos(::Val{:centery}, s::Rect) =  s.y-s.h/2
getPos(::Val{:centerleft}, s::Rect) = (s.x, s.y-s.h/2)
getPos(::Val{:centerright}, s::Rect) = (s.x-s.w, s.y-s.h/2)
getPos(::Val{:bottomcenter}, s::Rect) = (s.x-s.w/2, s.y-s.h)
getPos(::Val{:topcenter}, s::Rect) = (s.x-s.w/2, s.y)

# FIXME: Do we need getPos? If we do, then maybe this should belong in
# utility.jl and convert the array to tuples.
getPos(::Val{:center}, s::Triangle) = (s.p1 + s.p2 + s.p3) / 3
getPos(::Val{:left}, s::Triangle) = min(s.p1[1], s.p2[1], s.p3[1])
getPos(::Val{:right}, s::Triangle) = max(s.p1[1], s.p2[1], s.p3[1])
getPos(::Val{:top}, s::Triangle) = max(s.p1[2], s.p2[2], s.p3[2])
getPos(::Val{:bottom}, s::Triangle) = min(s.p1[2], s.p2[2], s.p3[2])
getPos(::Val{:centerx}, s::Triangle) = (s.p1[1] + s.p2[1] + s.p3[1]) / 3
getPos(::Val{:centery}, s::Triangle) = (s.p1[2] + s.p2[2] + s.p3[2]) / 3

getPos(::Val{:center}, s::Circle, u, v) = (u, v)
getPos(::Val{:top}, s::Circle, v) = (s.x, v-s.r)
getPos(::Val{:bottom}, s::Circle, v) = (s.x, v+s.r)
getPos(::Val{:left}, s::Circle, u) = (u-s.r, s.y)
getPos(::Val{:right}, s::Circle, u) = (u+s.r, s.y)
getPos(::Val{:centerx}, s::Circle, u) = (u, s.y)
getPos(::Val{:centery}, s::Circle, v) = (s.x, v)

getPos(::Val{:center}, s::Circle) = (s.x, s.y)
getPos(::Val{:top}, s::Circle) = s.y-s.r
getPos(::Val{:bottom}, s::Circle) = s.y+s.r
getPos(::Val{:left}, s::Circle) = s.x-s.r
getPos(::Val{:right}, s::Circle) = s.x+s.r
getPos(::Val{:centerx}, s::Circle) = s.x
getPos(::Val{:centery}, s::Circle) = s.y

################################################################################
################################################################################
# drawing
################################################################################
################################################################################

function draw(l::T, args...; kv...) where T <: Geom
  draw(game[].screen, l, args...; kv...)
end

function draw(s::Screen, l::Line, c::Colorant=colorant"black")
  SDL2.SetRenderDrawColor(s.renderer, sdl_colors(c)...)
  SDL2.RenderDrawLine(s.renderer, Cint.((l.x1, l.y1, l.x2, l.y2))...)
end

function draw(s::Screen, r::Rect, c::Colorant=colorant"black"; fill=false)
  SDL2.SetRenderDrawColor(s.renderer, sdl_colors(c)...)
  sr = convert(SDL2.Rect, r)
  if !fill
    SDL2.RenderDrawRect(s.renderer, Ref(sr))
  else
    SDL2.RenderFillRect(s.renderer, Ref(sr))
  end
end

function draw(s::Screen, tr::Triangle, c::Colorant=colorant"black"; fill=false)
  p1, p2, p3 = Cint.(tr.p1), Cint.(tr.p2), Cint.(tr.p3)
  SDL2.SetRenderDrawColor(s.renderer, sdl_colors(c)...)
  SDL2.RenderDrawLines(s.renderer, [p1; p2; p3; p1], Cint(4))

  ymax = max(p1[2], p2[2], p3[2])
  ymin = min(p1[2], p2[2], p3[2])
  if fill && ymin != ymax
    # Set q1, q2 and q3 in descending order of y-value
    q1 = (p1[2] != ymax != p2[2]) * p3 +
        (p2[2] != ymax != p3[2]) * p1 +
        (p3[2] != ymax != p1[2]) * p2 +
        (p1[2] == p2[2] == ymax) * p2 +
        (p2[2] == p3[2] == ymax) * p3 +
        (p3[2] == p1[2] == ymax) * p1
    q3 = (p1[2] != ymin != p2[2]) * p3 +
        (p2[2] != ymin != p3[2]) * p1 +
        (p3[2] != ymin != p1[2]) * p2 +
        (p1[2] == p2[2] == ymin) * p2 +
        (p2[2] == p3[2] == ymin) * p3 +
        (p3[2] == p1[2] == ymin) * p1
    q2 = ((q1 == p1 && q3 == p3) || (q1 == p3 && q3 == p1)) * p2 +
        ((q1 == p1 && q3 == p2) || (q1 == p2 && q3 == p1)) * p3 +
        ((q1 == p2 && q3 == p3) || (q1 == p3 && q3 == p2)) * p1

    n = q1[2] - q2[2]
    x0 = q1[1] + (q2[2] - q1[2]) / (q3[2] - q1[2]) * (q3[1] - q1[1])
    for j = Cint(0):n-Cint(1)
      r1 = [round(Cint, q2[1] + j / n * (q1[1] - q2[1])); q2[2] + j]
      r2 = [round(Cint, x0 + j / n * (q1[1] - x0)); q2[2] + j]
      SDL2.RenderDrawLines(s.renderer, [r1; r2], Cint(2))
    end
    n = q2[2] - q3[2]
    for j = Cint(1):n-Cint(1)
      r1 = [round(Cint, q2[1] + j / n * (q3[1] - q2[1])); q2[2] - j]
      r2 = [round(Cint, x0 + j / n * (q3[1] - x0)); q2[2] - j]
      SDL2.RenderDrawLines(s.renderer, [r1; r2], Cint(2))
    end
  end
end

function draw(s::Screen, circle::Circle, c::Colorant=colorant"black"; fill=false)
  SDL2.SetRenderDrawColor(s.renderer, sdl_colors(c)...)
  r = Cint(circle.r)
  o = Cint.([circle.x; circle.y])
  
  n = ceil(π * r / 2)
  if fill
    for j = 0:n
      x = round(Cint, r * cos(j / n * π / 2))
      y = round(Cint, r * sin(j / n * π / 2))
      SDL2.RenderDrawLine(s.renderer, o[1] + x, o[2] + y, o[1] + x, o[2] - y)
      SDL2.RenderDrawLine(s.renderer, o[1] - x, o[2] + y, o[1] - x, o[2] - y)
    end
  else
    for j = 0:n
      x = round(Cint, r * cos(j / n * π / 2))
      y = round(Cint, r * sin(j / n * π / 2))
      SDL2.RenderDrawPoint(s.renderer, o[1] + x, o[2] + y)
      SDL2.RenderDrawPoint(s.renderer, o[1] - x, o[2] + y)
      SDL2.RenderDrawPoint(s.renderer, o[1] + x, o[2] - y)
      SDL2.RenderDrawPoint(s.renderer, o[1] - x, o[2] - y)
    end
  end
end
