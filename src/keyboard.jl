module MouseButtons
export MouseButton
@enum MouseButton::UInt8 begin
    LEFT = 1
    MIDDLE = 2
    RIGHT = 3
    WHEEL_UP = 4
    WHEEL_DOWN = 5
end
end

using .MouseButtons

# This somewhat convoluted code below is to map julia code
# like `Keys.A` to the SDLK_* enums, without actually enumerating
# all the values in Julia. We used to do that, but that duplication
# was somewhat problematic. 

# A Keys.X invocation returns the keyscan code (an UInt32) corresponding
# to the SDLK_X enum defined in SDL2. 
# In contrast, a keyboard.X returns true or false depending of whether the X
# key is currently pressed. 
# Thus user code to check if X is pressed is written as
#       ` if game.keyboard.X`
const singleCharStrings = string.(collect('a':'z'))
struct KeyHolder{T} end
const Keys = KeyHolder{:SDLK_}()
const KeyMods = KeyHolder{:KMOD_}()
function Base.getproperty(k::KeyHolder{T}, s::Symbol) where T
    st=string(s)
    if length(st)==1 && only(st) in 'A':'Z'
        st = lowercase(st)
    end
    s=Symbol(T,st)
    try 
        return getproperty(GameZero.SimpleDirectMediaLayer.LibSDL2, s)
    catch 
        @error "Unknown key: $s"
        return nothing
    end 
end

struct Keyboard
    pressed::Array{UInt32, 1}
end

Keyboard() = Keyboard(Array{Any, 1}())

function Base.getproperty(k::Keyboard, s::Symbol)
    return getproperty(GameZero.Keys, s) in getfield(k, :pressed)
end

Base.push!(k::Keyboard, item) = push!(getfield(k, :pressed), item)
function Base.delete!(k::Keyboard, item)
    a = getfield(k, :pressed)
    deleteat!(a, a.==item)
end
