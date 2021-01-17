# This files checks the new way to draw a circle versus the old way

using SimpleDirectMediaLayer
const SDL2 = SimpleDirectMediaLayer 

circles = Vector{Int}[]
for j = 1:10
  push!(circles, [10 + 4 * j; 50; j])
  push!(circles, [100 + 30 * j; 500; 25 * j])
end

function newdraw(ren, circle; fill=false)
  r = Cint(circle[3])
  o = Cint.(circle[1:2])
  
  n = ceil(π * r / 2)
  if fill
    for j = 0:n
      x = round(Cint, r * cos(j / n * π / 2))
      y = round(Cint, r * sin(j / n * π / 2))
      SDL2.RenderDrawLine(ren, o[1] + x, o[2] + y, o[1] + x, o[2] - y)
      SDL2.RenderDrawLine(ren, o[1] - x, o[2] + y, o[1] - x, o[2] - y)
    end
  else
    for j = 0:n
      x = round(Cint, r * cos(j / n * π / 2))
      y = round(Cint, r * sin(j / n * π / 2))
      SDL2.RenderDrawPoint(ren, o[1] + x, o[2] + y)
      SDL2.RenderDrawPoint(ren, o[1] - x, o[2] + y)
      SDL2.RenderDrawPoint(ren, o[1] + x, o[2] - y)
      SDL2.RenderDrawPoint(ren, o[1] - x, o[2] - y)
    end
  end
end

function olddraw(ren, circle; fill=false)
    # define the center and needed sides of circle
    centerX = Cint(circle[1])
    centerY = Cint(circle[2])
    int_rad = Cint(circle[3])
    left = centerX - int_rad
    top = centerY - int_rad

    # we consider a grid with sides equal to the circle's diameter
    for x in left:centerX
        for y in top:centerY

            # for each pixel in the top left quadrant of the grid we measure the distance from the center.
            dist = sqrt( (centerX - x)^2 + (centerY - y)^2 )

            # if it is close to the circle's radius it and all associated points in the other quadrants are colored in.
            if (dist <= int_rad + 0.5 && dist >= int_rad - 0.5)
                rel_x = centerX - x
                rel_y = centerY - y

                quad1 = (x              , y              )
                quad2 = (centerX + rel_x, y              )
                quad3 = (x              , centerY + rel_y)
                quad4 = (quad2[1]       , quad3[2]       )

                SDL2.RenderDrawPoint(ren, quad1[1], quad1[2])
                SDL2.RenderDrawPoint(ren, quad2[1], quad2[2])
                SDL2.RenderDrawPoint(ren, quad3[1], quad3[2])
                SDL2.RenderDrawPoint(ren, quad4[1], quad4[2])

                # if we are told to fill in the circle we draw lines between all of the quadrants to completely fill the circle
                if (fill == true)
                    SDL2.RenderDrawLine(ren, quad1[1], quad1[2], quad2[1], quad2[2])
                    SDL2.RenderDrawLine(ren, quad2[1], quad2[2], quad4[1], quad4[2])
                    SDL2.RenderDrawLine(ren, quad4[1], quad4[2], quad3[1], quad3[2])
                    SDL2.RenderDrawLine(ren, quad3[1], quad3[2], quad1[1], quad1[2])
                end
            end

        end
    end

end

function myinit()
  SDL2.init()
  win = SDL2.CreateWindow("",
      Int32(0), Int32(0), Int32(800), Int32(600), UInt32(SDL2.WINDOW_SHOWN)
     )

  renderer = SDL2.CreateRenderer(win,
      Int32(-1),
      UInt32(SDL2.RENDERER_ACCELERATED | SDL2.RENDERER_PRESENTVSYNC)
     )

  SDL2.SetRenderDrawColor(renderer, 0, 0, 0, 255)
  return renderer
end


function testold(renderer, circles, N, boolfill)
  SDL2.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  for j = 1:N
    SDL2.RenderClear(renderer)
    for k = 1:length(circles)
      olddraw(renderer, circles[k], fill=boolfill)
    end
  end
  SDL2.Quit()
end

function testnew(renderer, circles, N, boolfill)
  SDL2.SetRenderDrawColor(renderer, 255, 255, 255, 255)
  for j = 1:N
    SDL2.RenderClear(renderer)
    for k = 1:length(circles)
      newdraw(renderer, circles[k], fill=boolfill)
    end
  end
  SDL2.Quit()
end
