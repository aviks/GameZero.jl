struct Keyboard
  pressed::Array{UInt32, 1}
end

Keyboard() = Keyboard(Array{Any, 1}())

function Base.getproperty(k::Keyboard, s::Symbol)
  s = Symbol(uppercase(string(s)))
  if isdefined(GameZero.Keys, s)
    return UInt32(getfield(GameZero.Keys, s)) in getfield(k, :pressed)
  end
  if isdefined(GameZero.Keymods, s)
    return UInt32(getfield(GameZero.Keymods, s)) in getfield(k, :pressed)
  end
  return false
end

Base.push!(k::Keyboard, item) = push!(getfield(k, :pressed), item)
function Base.delete!(k::Keyboard, item)
  a = getfield(k, :pressed)
  deleteat!(a, a.==item)
end
