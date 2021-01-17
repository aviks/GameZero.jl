# -------- Opening a window ---------------
# Forward reference for @cfunction
function window_event_watcher end
const window_event_watcher_cfunc = Ref(Ptr{Nothing}(0))

const window_paused = Threads.Atomic{UInt8}(0) # Whether or not the game should be running (if lost focus)


function make_win_renderer(title = "GameZero Julia", w=400,h=400 )
    global winwidth, winheight, winwidth_highdpi, winHeight_highdpi

    win = SDL2.CreateWindow(title,
        Int32(SDL2.WINDOWPOS_CENTERED()), Int32(SDL2.WINDOWPOS_CENTERED()), Int32(w), Int32(h),
        UInt32(SDL2.WINDOW_ALLOW_HIGHDPI|SDL2.WINDOW_OPENGL|SDL2.WINDOW_SHOWN));
        SDL2.SetWindowMinimumSize(win, Int32(w), Int32(h))
    window_event_watcher_cfunc[] = @cfunction(window_event_watcher, Cint, (Ptr{Nothing}, Ptr{SDL2.Event}))
    SDL2.AddEventWatch(window_event_watcher_cfunc[], win);

    renderer = SDL2.CreateRenderer(win, Int32(-1), UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC))
    SDL2.SetRenderDrawBlendMode(renderer, UInt32(SDL2.BLENDMODE_BLEND))
    return win,renderer
end

# This function handles all window events.
# We currently do no allow window resizes
function window_event_watcher(data_ptr::Ptr{Cvoid}, event_ptr::Ptr{SDL2.Event})::Cint
    global winwidth, winheight, cam, window_paused, renderer, win
    ev = unsafe_load(event_ptr, 1)
    ee = ev._Event
    t = UInt32(ee[4]) << 24 | UInt32(ee[3]) << 16 | UInt32(ee[2]) << 8 | ee[1]
    t = SDL2.Event(t)
    if t == SDL2.WindowEvent
        event = unsafe_load(Ptr{SDL2.WindowEvent}(pointer_from_objref(ev)))
        winevent = event.event;  # confusing, but that's what the field is called.
        if winevent == SDL2.WINDOWEVENT_FOCUS_LOST || winevent == SDL2.WINDOWEVENT_HIDDEN || winevent == SDL2.WINDOWEVENT_MINIMIZED
            # Stop game playing when out of focus
                window_paused[] = 1
            #end
        elseif winevent == SDL2.WINDOWEVENT_FOCUS_GAINED || winevent == SDL2.WINDOWEVENT_SHOWN
            window_paused[] = 0
        end
    end
    return 0
end

function get_window_size(win)
    w,h,w_highdpi,h_highdpi = Int32[0],Int32[0],Int32[0],Int32[0]
    SDL2.GetWindowSize(win, w, h)
    SDL2.GL_GetDrawableSize(win, w_highdpi, h_highdpi)
    return w[],h[],w_highdpi[],h_highdpi[]
end
