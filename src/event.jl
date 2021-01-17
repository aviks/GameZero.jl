function poll_event!()
  SDL_Event() = Array{UInt8}(zeros(56))
  e = SDL_Event()
  success = (SDL2.PollEvent(e) != 0)
  return e, success
end

function get_event_type(e::Array{UInt8})
  bitcat(UInt32, e[4:-1:1])
end

function get_event_type(e::SDL2.Event)
  bitcat(UInt32, e[4:-1:1])
end

function bitcat(::Type{T}, arr)::T where T<:Number
  out = zero(T)
  for x in arr
    out = out << T(sizeof(x)*8)
    out |= convert(T, x)
  end
  return out
end
