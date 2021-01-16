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

using .Keymods
