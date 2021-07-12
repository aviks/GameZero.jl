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

module Keys
import SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer
export Key
@enum Key::UInt32 begin
    UNKNOWN = SDL2.SDLK_UNKNOWN;
    BACKSPACE = SDL2.SDLK_BACKSPACE;
    TAB = SDL2.SDLK_TAB;
    CLEAR = SDL2.SDLK_CLEAR;
    RETURN = SDL2.SDLK_RETURN;
    PAUSE = SDL2.SDLK_PAUSE;
    ESCAPE = SDL2.SDLK_ESCAPE;
    SPACE = SDL2.SDLK_SPACE;
    EXCLAIM = SDL2.SDLK_EXCLAIM;
    QUOTEDBL = SDL2.SDLK_QUOTEDBL;
    HASH = SDL2.SDLK_HASH;
    DOLLAR = SDL2.SDLK_DOLLAR;
    AMPERSAND = SDL2.SDLK_AMPERSAND;
    QUOTE = SDL2.SDLK_QUOTE;
    LEFTPAREN = SDL2.SDLK_LEFTPAREN;
    RIGHTPAREN = SDL2.SDLK_RIGHTPAREN;
    ASTERISK = SDL2.SDLK_ASTERISK;
    PLUS = SDL2.SDLK_PLUS;
    COMMA = SDL2.SDLK_COMMA;
    MINUS = SDL2.SDLK_MINUS;
    PERIOD = SDL2.SDLK_PERIOD;
    SLASH = SDL2.SDLK_SLASH;
    K_0 = SDL2.SDLK_0;
    K_1 = SDL2.SDLK_1;
    K_2 = SDL2.SDLK_2;
    K_3 = SDL2.SDLK_3;
    K_4 = SDL2.SDLK_4;
    K_5 = SDL2.SDLK_5;
    K_6 = SDL2.SDLK_6;
    K_7 = SDL2.SDLK_7;
    K_8 = SDL2.SDLK_8;
    K_9 = SDL2.SDLK_9;
    COLON = SDL2.SDLK_COLON;
    SEMICOLON = SDL2.SDLK_SEMICOLON;
    LESS = SDL2.SDLK_LESS;
    EQUALS = SDL2.SDLK_EQUALS;
    GREATER = SDL2.SDLK_GREATER;
    QUESTION = SDL2.SDLK_QUESTION;
    AT = SDL2.SDLK_AT;
    LEFTBRACKET = SDL2.SDLK_LEFTBRACKET;
    BACKSLASH = SDL2.SDLK_BACKSLASH;
    RIGHTBRACKET = SDL2.SDLK_RIGHTBRACKET;
    CARET = SDL2.SDLK_CARET;
    UNDERSCORE = SDL2.SDLK_UNDERSCORE;
    BACKQUOTE = SDL2.SDLK_BACKQUOTE;
    A = SDL2.SDLK_a;
    B = SDL2.SDLK_b;
    C = SDL2.SDLK_c;
    D = SDL2.SDLK_d;
    E = SDL2.SDLK_e;
    F = SDL2.SDLK_f;
    G = SDL2.SDLK_g;
    H = SDL2.SDLK_h;
    I = SDL2.SDLK_i;
    J = SDL2.SDLK_j;
    K = SDL2.SDLK_k;
    L = SDL2.SDLK_l;
    M = SDL2.SDLK_m;
    N = SDL2.SDLK_n;
    O = SDL2.SDLK_o;
    P = SDL2.SDLK_p;
    Q = SDL2.SDLK_q;
    R = SDL2.SDLK_r;
    S = SDL2.SDLK_s;
    T = SDL2.SDLK_t;
    U = SDL2.SDLK_u;
    V = SDL2.SDLK_v;
    W = SDL2.SDLK_w;
    X = SDL2.SDLK_x;
    Y = SDL2.SDLK_y;
    Z = SDL2.SDLK_z;
    DELETE = SDL2.SDLK_DELETE;
    KP0 = SDL2.SDLK_KP_0;
    KP1 = SDL2.SDLK_KP_1;
    KP2 = SDL2.SDLK_KP_2;
    KP3 = SDL2.SDLK_KP_3;
    KP4 = SDL2.SDLK_KP_4;
    KP5 = SDL2.SDLK_KP_5;
    KP6 = SDL2.SDLK_KP_6;
    KP7 = SDL2.SDLK_KP_7;
    KP8 = SDL2.SDLK_KP_8;
    KP9 = SDL2.SDLK_KP_9;
    KP_PERIOD = SDL2.SDLK_KP_PERIOD;
    KP_DIVIDE = SDL2.SDLK_KP_DIVIDE;
    KP_MULTIPLY = SDL2.SDLK_KP_MULTIPLY;
    KP_MINUS = SDL2.SDLK_KP_MINUS;
    KP_PLUS = SDL2.SDLK_KP_PLUS;
    KP_ENTER = SDL2.SDLK_KP_ENTER;
    KP_EQUALS = SDL2.SDLK_KP_EQUALS;
    UP = SDL2.SDLK_UP;
    DOWN = SDL2.SDLK_DOWN;
    RIGHT = SDL2.SDLK_RIGHT;
    LEFT = SDL2.SDLK_LEFT;
    INSERT = SDL2.SDLK_INSERT;
    HOME = SDL2.SDLK_HOME;
    END = SDL2.SDLK_END;
    PAGEUP = SDL2.SDLK_PAGEUP;
    PAGEDOWN = SDL2.SDLK_PAGEDOWN;
    F1 = SDL2.SDLK_F1;
    F2 = SDL2.SDLK_F2;
    F3 = SDL2.SDLK_F3;
    F4 = SDL2.SDLK_F4;
    F5 = SDL2.SDLK_F5;
    F6 = SDL2.SDLK_F6;
    F7 = SDL2.SDLK_F7;
    F8 = SDL2.SDLK_F8;
    F9 = SDL2.SDLK_F9;
    F10 = SDL2.SDLK_F10;
    F11 = SDL2.SDLK_F11;
    F12 = SDL2.SDLK_F12;
    F13 = SDL2.SDLK_F13;
    F14 = SDL2.SDLK_F14;
    F15 = SDL2.SDLK_F15;
    NUMLOCK = SDL2.SDLK_NUMLOCKCLEAR;
    CAPSLOCK = SDL2.SDLK_CAPSLOCK;
    SCROLLOCK = SDL2.SDLK_SCROLLLOCK;
    RSHIFT = SDL2.SDLK_RSHIFT;
    LSHIFT = SDL2.SDLK_LSHIFT;
    RCTRL = SDL2.SDLK_RCTRL;
    LCTRL = SDL2.SDLK_LCTRL;
    RALT = SDL2.SDLK_RALT;
    LALT = SDL2.SDLK_LALT;
    # RMETA = SDL2.SDLK_RGUI;
    # LMETA = SDL2.SDLK_LGUI;
    LSUPER = SDL2.SDLK_LGUI;
    RSUPER = SDL2.SDLK_RGUI;
    MODE = SDL2.SDLK_MODE;
    HELP = SDL2.SDLK_HELP;
    SYSREQ = SDL2.SDLK_SYSREQ;
    MENU = SDL2.SDLK_MENU;
    POWER = SDL2.SDLK_POWER;
    EURO = SDL2.SDLK_CURRENCYUNIT;
end
end

module Keymods
export Keymod
@enum Keymod::UInt16 begin
    NONE = 0
    LSHIFT = 1
    RSHIFT = 2
    LCTRL = 64
    RCTRL = 128
    LALT = 256
    RALT = 512
    LMETA = 1024
    RMETA = 2048
    NUM = 4096
    CAPS = 8192
    MODE = 16384
    CTRL = 192
    SHIFT = 3
    ALT = 768
    META = 3072
end

end



using .MouseButtons
using .Keys
using .Keymods

struct Keyboard
    pressed::Array{UInt32, 1}
end

Keyboard() = Keyboard(Array{Any, 1}())

function Base.getproperty(k::Keyboard, s::Symbol)
    s = Symbol(uppercase(string(s)))
    if isdefined(GameZero.Keys, s)
        return UInt32(getfield(GameZero.Keys, s)) in getfield(k, :pressed)
    end
    if isdefined(GameZero.Keymods, s)
        return UInt32(getfield(GameZero.Keymods, s)) in getfield(k, :pressed)
    end
    return false
end

Base.push!(k::Keyboard, item) = push!(getfield(k, :pressed), item)
function Base.delete!(k::Keyboard, item)
    a = getfield(k, :pressed)
    deleteat!(a, a.==item)
end
