mutable struct WallTimer
  starttime_ns::typeof(Base.time_ns())
  paused_elapsed_ns::typeof(Base.time_ns())

  WallTimer() = new(0,0)
end

function start!(timer::WallTimer)
  timer.starttime_ns = (Base.time_ns)()
  return nothing
end

started(timer::WallTimer) = (timer.starttime_ns ≠ 0)

""" Return nanoseconds since timer was started or 0 if not yet started. """
function elapsed(timer::WallTimer)
  local elapsedtime_ns = (Base.time_ns)() - timer.starttime_ns
  return started(timer) * elapsedtime_ns
end

function pause!(timer::WallTimer)
  timer.paused_elapsed_ns = (Base.time_ns)() - timer.starttime_ns
  return nothing
end

function unpause!(timer::WallTimer)
  timer.starttime_ns = (Base.time_ns)()
  timer.starttime_ns -= timer.paused_elapsed_ns;
  return nothing
end
