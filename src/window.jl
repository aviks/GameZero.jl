# -------- Opening a window ---------------
# Forward reference for @cfunction
function windowEventWatcher end
const window_event_watcher_cfunc = Ref(Ptr{Nothing}(0))

const window_paused = Threads.Atomic{UInt8}(0) # Whether or not the game should be running (if lost focus)


function makeWinRenderer(title = "GameZero Julia", w=400,h=400 )
    global winWidth, winHeight, winWidth_highDPI, winHeight_highDPI

    win = SDL_CreateWindow(title,
        Int32(SDL_WINDOWPOS_CENTERED), Int32(SDL_WINDOWPOS_CENTERED), Int32(w), Int32(h),
        UInt32(SDL_WINDOW_ALLOW_HIGHDPI|SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN));
        SDL_SetWindowMinimumSize(win, Int32(w), Int32(h))
    window_event_watcher_cfunc[] = @cfunction(windowEventWatcher, Cint, (Ptr{Nothing}, Ptr{SDL_Event}))
    SDL_AddEventWatch(window_event_watcher_cfunc[], win);

    renderer = SDL_CreateRenderer(win, Int32(-1), UInt32(SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC))
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)
    return win,renderer
end

# This function handles all window events.
# We currently do no allow window resizes
function windowEventWatcher(data_ptr::Ptr{Cvoid}, event_ptr::Ptr{SDL_Event})::Cint
    # global winWidth, winHeight, cam, window_paused, renderer, win
    ev = unsafe_load(event_ptr)
    if (ev.type == SDL_WINDOWEVENT)
        winevent = ev.window.event
        if (winevent == SDL_WINDOWEVENT_FOCUS_LOST || winevent == SDL_WINDOWEVENT_HIDDEN || winevent == SDL_WINDOWEVENT_MINIMIZED)
            # Stop game playing when out of focus
                window_paused[] = 1
            #end
        elseif (winevent == SDL_WINDOWEVENT_FOCUS_GAINED || winevent == SDL_WINDOWEVENT_SHOWN)
            window_paused[] = 0
        end
    end
    return 0
end

function getWindowSize(win)
    w,h,w_highDPI,h_highDPI = Int32[0],Int32[0],Int32[0],Int32[0]
    SDL_GetWindowSize(win, w, h)
    SDL_GL_GetDrawableSize(win, w_highDPI, h_highDPI)
    return w[],h[],w_highDPI[],h_highDPI[]
end
