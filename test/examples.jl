# Integration tests. Load the example game files, and verify that no exceptions are thrown
# No user input is inserted, so no actual gameplay is tested. Simply that the file loads
# Running these needs a graphical system -- so xvfb if running on a headless system. 
@testset "Examples" begin
    @testset "basic" begin
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic.jl"), true)
        @test g!=nothing
        sleep(0.2)
        GameZero.quitSDL(g)
    end
    
    @testset "basic2" begin
        g = GameZero.initgame(joinpath("..","example","BasicGame","basic2.jl"), true)
        @test g!=nothing
        sleep(0.2)
        GameZero.quitSDL(g)
    end
    end