module GameZero

export
  # Actor
  Actor,
  angle,
  collide,
  distance,

  # Game
  Game,
  game,
  rungame,

  # Screen and drawing
  clear,
  draw,

  # Audio
  play_music,
  play_sound,

  # Timer
  scheduler,
  schedule_once,
  schedule_interval,
  schedule_unique,
  unschedule,

  # Keyboard modules
  Keys,
  MouseButtons,
  KeyMods, 

  # Geometric structs
  Line,
  Rect,
  Triangle,
  Circle

using Random
import Base: +

using Colors
using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer


include("keyboard/Keys_MODULE.jl")
include("keyboard/Keymods_MODULE.jl")
include("keyboard/MouseButtons_MODULE.jl")
include("keyboard/Keyboard.jl")

include("timer/WallTimer.jl")
include("timer/Scheduled.jl")

include("window.jl")
include("event.jl")
include("resources.jl")
include("utility.jl")

include("Screen.jl")
include("Geom.jl")
include("Actor.jl")

include("Game.jl")

end
