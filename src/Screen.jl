struct Screen
  window
  renderer
  height::Int
  width::Int
  background::ARGB

  function Screen(name, w, h, color)
    win, renderer = make_win_renderer(name, w, h)
    if !(color isa ARGB)
      color = ARGB(color)
    end
    new(win, renderer, h, w, color)
  end
end

function clear(s::Screen)
  fill(s, s.background)
end

clear() = clear(game[].screen)

Base.fill(c::Colorant) = Base.fill(game[].screen, c)

function Base.fill(s::Screen, c::Colorant)
  SDL2.SetRenderDrawColor(s.renderer, sdl_colors(c)...)
  SDL2.RenderClear(s.renderer)
end
