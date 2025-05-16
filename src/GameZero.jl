module GameZero
using Colors
using Random

export Actor, TextActor, Game, game, draw, scheduler, schedule_once, schedule_interval, schedule_unique, unschedule,
        collide, angle, distance, play_music, play_sound, line, clear, rungame, game_include
export Keys, MouseButtons, KeyMods
export Line, Rect, Triangle, Circle

using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2

include("keyboard.jl")
include("timer.jl")
include("window.jl")
include("resources.jl")
include("screen.jl")
include("actor.jl")

#Magic variables
const HEIGHTSYMBOL = :HEIGHT
const WIDTHSYMBOL = :WIDTH
const BACKSYMBOL = :BACKGROUND

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


function initscreen(gm::Module, name::String)
    h = getifdefined(gm, HEIGHTSYMBOL, 400)
    w = getifdefined(gm, WIDTHSYMBOL, 600)
    background = getifdefined(gm, BACKSYMBOL, ARGB(colorant"white"))
    if !(background isa Colorant)
        background=image_surface(background)
    end
    s = Screen(name, w, h, background)
    clear(s)
    return s
end


getifdefined(m, s, v) = isdefined(m, s) ? getfield(m, s) : v

game_include(jlf::String) = Base.include(game[].game_module, jlf)


mainloop(g::Ref{Game}) = mainloop(g[])

pollEvent = let event=Ref{SDL_Event}()
    ()->SDL_PollEvent(event)
end

function mainloop(g::Game)
    start!(timer)
    while (true)
      #Don't run if game is paused by system (resizing, lost focus, etc)
      while window_paused[] != 0
          _ = pollEvent()
          sleep(0.5)
      end

      # Handle Events
        errorMsg = ""
        try
            event_ref = Ref{SDL_Event}()
            while Bool(SDL_PollEvent(event_ref))
                evt = event_ref[]
                evt_ty = evt.type
                handleEvents!(g, evt, evt_ty)
            end
        catch e
            rethrow()
        end

      # Render
      #if (debug && debugText) renderFPS(renderer,last_10_frame_times) end
        clear(g.screen)
        Base.invokelatest(g.render_function, g)
        SDL_RenderPresent(g.screen.renderer)

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
    if (t == SDL_KEYDOWN || t == SDL_KEYUP)
        handleEvent(g::Game, e.key)
    elseif (t == SDL_MOUSEBUTTONUP || t == SDL_MOUSEBUTTONDOWN)
        handleEvent(g::Game, e.button)
    #TODO elseif (t == SDL_MOUSEWHEEL); handleMouseScroll(e)
    elseif (t == SDL_MOUSEMOTION)
        handleEvent(g::Game, e.motion)
    elseif (t == SDL_QUIT)
        paused[] = playing[] = false
    end
end

function handleEvent(g::Game, e::SDL_KeyboardEvent)
    keySym = e.keysym.sym
    keyMod = e.keysym.mod
    @debug "Keyboard" keySym, keyMod
    if (e.type == SDL_KEYDOWN)
        push!(g.keyboard, keySym)
        Base.invokelatest(g.onkey_function, g, keySym, keyMod)
    elseif (e.type == SDL_KEYUP)
        delete!(g.keyboard, keySym)
    end
    #keyRepeat = (e.repeat != 0)
end

function handleEvent(g::Game, e::SDL_MouseButtonEvent)
    button = e.button
    x = e.x 
    y = e.y
    @debug "Mouse Button" button, x, y
    if (e.type == SDL_MOUSEBUTTONUP)
        Base.invokelatest(g.onmouseup_function, g, (x, y), MouseButtons.MouseButton(button))
    elseif (e.type == SDL_MOUSEBUTTONDOWN)
        Base.invokelatest(g.onmousedown_function, g, (x, y), MouseButtons.MouseButton(button))
    end
end


function handleEvent(g::Game, e::SDL_MouseMotionEvent)
    x = e.x
    y = e.y
    @debug "Mouse Move" x, y
    Base.invokelatest(g.onmousemove_function, g, (x, y))
end

"""
    `rungame(game_file::String)`
    `rungame()`

    The entry point to GameZero. This is the user-facing function that is used to start a game. 
    The single argument method should be used from the REPL or main script. It takes the game source
    file as it's only argument. 

    The zero argument method should be used from the game source file itself when is being executed directly
"""
function rungame(jlf::String, external::Bool=true)
    # The optional argument `external` is used to determine whether the zero or single argument version 
    # has been called. End users should never have to use this argument directly. 
    # external=true means rungame has been called from the REPl or run script, with the game file as input
    # external=false means rungame has been called at the bottom of the game file itself
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
    initSDL()
    game[] = Game()
    scheduler[] = Scheduler()
    g = game[]
    g.keyboard = Keyboard()
    if external 
        module_name = Symbol(name*"_"*randstring(5))
        game_module = Module(module_name)
        @debug "Initialised Anonymous Game Module" module_name
        g.game_module = game_module 
        g.location = dirname(jlf)
    else 
        g.game_module = Main 
        g.location = pwd()
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
    x = SDL_GetError()
    return unsafe_string(x)
end

function initSDL()
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 4)
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4)
    r = SDL_Init(UInt32(SDL_INIT_VIDEO | SDL_INIT_AUDIO))
    if r != 0
        error("Uanble to initialise SDL: $(getSDLError())")
    end
    TTF_Init()

    mix_init_flags = MIX_INIT_FLAC|MIX_INIT_MP3|MIX_INIT_OGG
    inited = Mix_Init(Int32(mix_init_flags))
    if inited & mix_init_flags != mix_init_flags
        @warn "Failed to initialise audio mixer properly. All sounds may not play correctly\n$(getSDLError())"
    end

    device = Mix_OpenAudio(Int32(22050), UInt16(MIX_DEFAULT_FORMAT), Int32(2), Int32(1024) )
    if device != 0
        @warn "No audio device available, sounds and music will not play.\n$(getSDLError())"
        Mix_CloseAudio()
    end
end

function quitSDL(g::Game)
    # Need to close the callback before quitting SDL to prevent it from hanging
    # https://github.com/n0name/2D_Engine/issues/3
    @debug "Quitting the game"
    clear!(scheduler[])
    SDL_DelEventWatch(window_event_watcher_cfunc[], g.screen.window);
    SDL_DestroyRenderer(g.screen.renderer)
    SDL_DestroyWindow(g.screen.window)
    #Run all finalisers
    GC.gc();GC.gc();
    quitSDL()
end

function quitSDL()
    Mix_HaltMusic()
    Mix_HaltChannel(Int32(-1))
    Mix_CloseAudio()
    TTF_Quit()
    Mix_Quit()
    SDL_Quit()
end

function main()
    if length(ARGS) < 1
        throw(ArgumentError("No file to run"))
    end
    jlf = ARGS[1]
    rungame(jlf)
end


end # module
