using GameZero
using Test

@testset "basic" begin
    global g
    @test_nowarn begin
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic.jl"), true)
        GameZero.quitSDL(g)
    end

end

@testset "basic2" begin
    @test_nowarn begin
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic2.jl"), true)
        GameZero.quitSDL(g)
    end
end
