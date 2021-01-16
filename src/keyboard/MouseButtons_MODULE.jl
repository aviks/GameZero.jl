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
