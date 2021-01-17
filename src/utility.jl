function sdl_colors(c::Colorant)
  sdl_colors(
      convert(ARGB{Colors.FixedPointNumbers.Normed{UInt8,8}}, c)
     )
end

sdl_colors(c::ARGB) = Int.(reinterpret.((red(c), green(c), blue(c), alpha(c))))
