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

abstract type Scheduled end

"""
The schedule type stores an array of `Sheduled` objects, and a `WallTimer` object
that is used to keep time. The scheduler object keeps its own timer, and does
not reuse the timer in the game main loop, since the game timer can be reset every
frame, while the scheduler timer needs to keep absolute time.
"""
struct Scheduler
    actions::Array{Scheduled}
    timer::WallTimer

    function Scheduler()
        w = WallTimer()
        start!(w)
        new(Vector{Scheduled}(), w)
    end
end

const scheduler = Ref{Scheduler}()

elapsed(s::Scheduler) = elapsed(s.timer)
Base.push!(s::Scheduler, x::Scheduled) = push!(s.actions, x)
Base.filter!(x::Scheduled, s::Scheduler) = filter!(a->x!=a, s.actions)
clear!(s::Scheduler) = deleteat!(s.actions, 1:length(s.actions))

"""
A scheduled action that is run once. The action is a zero-argument function that is wrapped as a
WeakRef object. This ensures that schedules do not inadvertantly store references
to game objects. This does however mean that anynymous functions should not be used
as scheduled actions.

The time stored in the schedule is in absolute nanoseconds since epoch
(Note the epoch for nanoseconds can be arbitrary).
User facing times should always be in seconds, or fractions of a second, and usually
specifed as interval from current time. Hence the time should be converted before
being stored in a `Sheduled` object.
"""
struct OnceScheduled <: Scheduled
    action::WeakRef
    time::Int64
end

"""
A scheduled action that is repeated indefinitely. The time of next invocation is
stored as `time`, while the interval between each invocation is stored in `interval`.
Both of these are stored in units of nanoseconds.
"""
struct RepeatScheduled <: Scheduled
    action::WeakRef
    time::Int64
    interval::Int64
end

"""
A contingent schdule. This type of schedule checks the return value of the action.
If the action method returns `nothing`, no further action is scheduled. Otherwise,
the return value is considered to be the interval, in seconds, to the next invocation of the action.

Since action methods are written by end users, the return value of those methods are
not considered significant for ease of use. Hence ContingentScheduled is a separate
type that should not be end user visible.
"""
struct ContingentScheduled <: Scheduled
    action::WeakRef
    time::Int64
end

"Run all actions in the global scheduler that are due"
function tick!(s::Scheduler)
    t = elapsed(s.timer)
    for x in s.actions
        tick(x, t, s)
    end
    return
end

"Run a single scheduled action if due"
function tick(x::OnceScheduled, elapsed, s=scheduler[])
    if x.time <= elapsed && x.action.value != nothing
        @debug "Running single scheduled function" x.action.value
        Base.invokelatest(x.action.value)
        filter!(x, s)
    end

end

"Run a repeated scheduled action if due. If run, this method will add a new scheduled action to the scheduler"
function tick(x::RepeatScheduled, elapsed, s=scheduler[])
    if x.time <= elapsed && x.action.value != nothing
        @debug "Running repeated scheduled function" x.action.value
        Base.invokelatest(x.action.value)
        filter!(x, s)
        push!(s, RepeatScheduled(x.action, x.interval+elapsed, x.interval))
    end

end

"Run a contingent schduled action if due. If run, and not stopped, add a new scheduled action to the scheduler"
function tick(x::ContingentScheduled, elapsed, s=scheduler[])
    if x.time <= elapsed && x.action.value != nothing
        @debug "Running contingent scheduled function" x.action.value
        r = Base.invokelatest(x.action.value)
        filter!(x, s)
        if r == nothing
            return
        else
            push!(s, ContingetScheduled(x.action, 1e9*r+elapsed))
        end
    end
end

function schedule_once(f::Function, interval)
    t = elapsed(scheduler[])
    push!(scheduler[], OnceScheduled(WeakRef(f), t+interval*1e9) )
    @debug "Added Single Schedule" f
end

function schedule_unique(f::Function, interval)
    filter(WeakRef(f), scheduler)
    push!(scheduler[], OnceScheduled(WeakRef(f), elapsed(scheduler[])+interval*1e9) )
    @debug "Added Unique Schedule" f
end

function schedule_interval(f::Function, interval, first_interval=interval)
     push!(scheduler[], RepeatScheduled(WeakRef(f), elapsed(scheduler[])+first_interval*1e9), interval*1e9 )
     @debug "Added Repeated Schedule" f
end
unschedule(f::Function) = filter!(WeakRef(f), scheduler[])
