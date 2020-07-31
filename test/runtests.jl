using GameZero
using Test

@testset "basic" begin
    global g
    @test_nowarn begin 
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic.jl"))
        GameZero.quitSDL(g)
    end
    
end

@testset "basic2" begin
    @test_nowarn begin 
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic2.jl"))
        GameZero.quitSDL(g)
    end
end
