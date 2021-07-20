module GameZero
using Colors
using Random

export Actor, Game, game, draw, schduler, schedule_once, schedule_interval, schedule_unique, unschedule,
        collide, angle, distance, play_music, play_sound, line, clear, rungame, game_include
export Keys, MouseButtons, KeyMods
export Line, Rect, Triangle, Circle

using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer

include("keyboard.jl")
include("timer.jl")
include("window.jl")
include("event.jl")
include("resources.jl")
include("screen.jl")
include("actor.jl")

#Magic variables
const HEIGHTSYMBOL = :HEIGHT
const WIDTHSYMBOL = :WIDTH
const BACKSYMBOL = :BACKGROUND
const LOCATION = pwd()



mutable struct Game
    screen::Screen
    location::String
    game_module::Module
    keyboard::Keyboard
    render_function::Function 
    update_function::Function 
    onkey_function::Function 
    onmousedown_function::Function 
    onmouseup_function::Function 
    onmousemove_function::Function 
    Game() = new()
end




# const EVENT_HANDLER_FN = Dict(
#     MOUSEBUTTONDOWN => "on_mouse_down",
#     MOUSEBUTTONUP => "on_mouse_up",
#     MOUSEMOTION => "on_mouse_move",
#     KEYDOWN => "on_key_down",
#     KEYUP => "on_key_up",
#     MUSIC_END => "on_music_end"
# )


const timer = WallTimer()

const game = Ref{Game}()
const playing = Ref{Bool}(false)
const paused = Ref{Bool}(false)

function __init__()

end

function initscreen(gm::Module, name::String)
    h = getifdefined(gm, HEIGHTSYMBOL, 400)
    w = getifdefined(gm, WIDTHSYMBOL, 600)
    color = getifdefined(gm, BACKSYMBOL, ARGB(colorant"white"))
    s = Screen(name, w, h, color)
    clear(s)
    return s
end


getifdefined(m, s, v) = isdefined(m, s) ? getfield(m, s) : v

game_include(jlf::String) = Base.include(game[].game_module, jlf)


mainloop(g::Ref{Game}) = mainloop(g[])

function mainloop(g::Game)
    start!(timer)
    while (true)
      #Don't run if game is paused by system (resizing, lost focus, etc)
      while window_paused[] != 0
          _ = pollEvent!()
          sleep(0.5)
      end

      # Handle Events
        errorMsg = ""
        try
            hadEvents = true
            while hadEvents
                e, hadEvents = pollEvent!()
                t = getEventType(e)
                handleEvents!(g, e, t)
            end
        catch e
            rethrow()
        end

      # Render
      #if (debug && debugText) renderFPS(renderer,last_10_frame_times) end
        SDL2.RenderClear(g.screen.renderer)
        Base.invokelatest(g.render_function, g)
        SDL2.RenderPresent(g.screen.renderer)

        dt = elapsed(timer)
      # Don't let the game proceed at fewer than this frames per second. If an
      # update takes too long, allow the game to actually slow, rather than
      # having too big of frames.
        min_fps = 20.0
        max_fps = 60.0
        dt = min(dt/1e9, 1.0 / min_fps)
        start!(timer)
        Base.invokelatest(g.update_function, g, dt)
        tick!(scheduler[])
        if (playing[] == false)
            throw(QuitException())
        end
    end
end

function handleEvents!(g::Game, e, t)
    global playing, paused
    if (t == SDL2.KEYDOWN || t == SDL2.KEYUP)
        handleKeyPress(g::Game, e, t)
    elseif (t == SDL2.MOUSEBUTTONUP || t == SDL2.MOUSEBUTTONDOWN)
        handleMouseClick(g::Game, e, t)
    #TODO elseif (t == SDL2.MOUSEWHEEL); handleMouseScroll(e)
    elseif (t == SDL2.MOUSEMOTION)
        handleMousePan(g::Game, e, t)
    elseif (t == SDL2.QUIT)
        paused[] = playing[] = false
    end
end

function handleKeyPress(g::Game, e, t)
    keySym = getKeySym(e)
    keyMod = getKeyMod(e)
    @debug "Keyboard" keySym, keyMod
    if (t == SDL2.KEYDOWN)
        push!(g.keyboard, keySym)
        Base.invokelatest(g.onkey_function, g, Keys.Key(keySym), keyMod)
    elseif (t == SDL2.KEYUP)
        delete!(g.keyboard, keySym)
    end
    #keyRepeat = (getKeyRepeat(e) != 0)
end

function handleMouseClick(g::Game, e, t)
    button = getMouseButtonClick(e)
    x = getMouseClickX(e)
    y = getMouseClickY(e)
    @debug "Mouse Button" button, x, y
    if (t == SDL2.MOUSEBUTTONUP)
        Base.invokelatest(g.onmouseup_function, g, (x, y), MouseButtons.MouseButton(button))
    elseif (t == SDL2.MOUSEBUTTONDOWN)
        Base.invokelatest(g.onmousedown_function, g, (x, y), MouseButtons.MouseButton(button))
    end
end


function handleMousePan(g::Game, e, t)
    x = getMouseMoveX(e)
    y = getMouseMoveY(e)
    @debug "Mouse Move" x, y
    Base.invokelatest(g.onmousemove_function, g, (x, y))
end

getKeySym(e) = bitcat(UInt32, e[24:-1:21])
getKeyRepeat(e) = bitcat(UInt8, e[14:-1:14])
getKeyMod(e) = bitcat(UInt16, e[26:-1:25])

getMouseButtonClick(e) = bitcat(UInt8, e[17:-1:17])
getMouseClickX(e) =  bitcat(Int32, e[24:-1:21])
getMouseClickY(e) = bitcat(Int32, e[28:-1:25])

getMouseMoveX(e) = bitcat(Int32, e[24:-1:21])
getMouseMoveY(e) = bitcat(Int32, e[28:-1:25])

function rungame(jlf::String, external::Bool=true)
    global playing, paused
    g = initgame(jlf::String, external)
    try
        playing[] = paused[] = true
        mainloop(g)
    catch e
        if !isa(e, QuitException) && !isa(e, InterruptException)
            @error e exception = (e, catch_backtrace())
        end
    finally
        GameZero.quitSDL(game[])
    end
end

function rungame()
    rungame(abspath(PROGRAM_FILE), false)
end

function initgame(jlf::String, external::Bool)
    if !isfile(jlf)
        ArgumentError("File not found: $jlf")
    end
    name = titlecase(replace(basename(jlf), ".jl"=>""))
    if external
        module_name = Symbol(name*"_"*randstring(5))
        game_module = Module(module_name)
        @debug "Initialised Anonymous Game Module" module_name
    end
    initSDL()
    game[] = Game()
    scheduler[] = Scheduler()
    g = game[]
    g.location = dirname(jlf)
    g.keyboard = Keyboard()
    if external 
        g.game_module = game_module 
    else 
        g.game_module = Main 
    end

    if external
        Base.include_string(g.game_module, "using GameZero")
        Base.include_string(g.game_module, "import GameZero.draw")
        Base.include_string(g.game_module, "using Colors")
        Base.include(g.game_module, jlf)
    end

    g.update_function = getfn(g.game_module, :update, 2)
    g.render_function = getfn(g.game_module, :draw, 1)
    g.onkey_function = getfn(g.game_module, :on_key_down, 3)
    g.onmouseup_function = getfn(g.game_module, :on_mouse_up, 3)
    g.onmousedown_function = getfn(g.game_module, :on_mouse_down, 3)
    g.onmousemove_function = getfn(g.game_module, :on_mouse_move, 2)
    g.screen = initscreen(g.game_module, "GameZero::"*name)
    clear(g.screen)
    return g
end


function getfn(m::Module, s::Symbol, maxargs=3)
    if isdefined(m, s)
        fn = getfield(m, s)

        ms = copy(methods(fn).ms)
        filter!(x->x.module == m, ms)
        if length(ms) > 1
            sort!(ms, by=x->x.nargs, rev=true)
        end
        m = ms[1]
        if (m.nargs - 1) > maxargs
            error("Found a $s function with $(m.nargs-1) arguments. A maximum of $maxargs arguments are allowed.")
        end
        @debug "Event method" fn m.nargs
        #TODO Validate types for arguments
        if m.nargs - 1 == maxargs #required to handle the zero-arg case
            return fn
        end
        return (x...) -> fn(x[1:(m.nargs-1)]...)
    else
        return (x...) -> nothing
    end
end


# Having a QuitException is useful for testing, since an exception will simply
# pause the interpreter. For release builds, the catch() block will call quitSDL().
struct QuitException <: Exception end

function getSDLError()
    x = SDL2.GetError()
    return unsafe_string(x)
end

function initSDL()
    SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLEBUFFERS, 4)
    SDL2.GL_SetAttribute(SDL2.GL_MULTISAMPLESAMPLES, 4)
    r = SDL2.Init(UInt32(SDL2.INIT_VIDEO | SDL2.INIT_AUDIO))
    if r != 0
        error("Uanble to initialise SDL: $(getSDLError())")
    end
    SDL2.TTF_Init()

    mix_init_flags = SDL2.MIX_INIT_FLAC|SDL2.MIX_INIT_MP3|SDL2.MIX_INIT_OGG
    inited = SDL2.Mix_Init(Int32(mix_init_flags))
    if inited & mix_init_flags != mix_init_flags
        @warn "Failed to initialise audio mixer properly. All sounds may not play correctly\n$(getSDLError())"
    end

    device = SDL2.Mix_OpenAudio(Int32(22050), UInt16(SDL2.MIX_DEFAULT_FORMAT), Int32(2), Int32(1024) )
    if device != 0
        @warn "No audio device available, sounds and music will not play.\n$(getSDLError())"
        SDL2.Mix_CloseAudio()
    end
end

function quitSDL(g::Game)
    # Need to close the callback before quitting SDL to prevent it from hanging
    # https://github.com/n0name/2D_Engine/issues/3
    @debug "Quitting the game"
    clear!(scheduler[])
    SDL2.DelEventWatch(window_event_watcher_cfunc[], g.screen.window);
    SDL2.DestroyRenderer(g.screen.renderer)
    SDL2.DestroyWindow(g.screen.window)
    #Run all finalisers
    GC.gc();GC.gc();
    quitSDL()
end

function quitSDL()
    SDL2.Mix_HaltMusic()
    SDL2.Mix_HaltChannel(Int32(-1))
    SDL2.Mix_CloseAudio()
    SDL2.TTF_Quit()
    SDL2.Mix_Quit()
    SDL2.Quit()
end

function main()
    if length(ARGS) < 1
        throw(ArgumentError("No file to run"))
    end
    jlf = ARGS[1]
    rungame(jlf)
end


end # module
