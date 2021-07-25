using GameZero
using Test

@testset "get positions" begin 
    r = Rect(100, 200, 10, 20)
    @test r.pos == (100, 200)
    @test r.x == 100
    @test r.y == 200
    @test r.topleft == (100, 200)
    @test r.top == 200
    @test r.left == 100
    @test r.topright == (110, 200)
    @test r.right == 110
    @test r.bottomleft == (100, 220)
    @test r.bottom == 220
    @test r.bottomright == (110, 220)
    @test r.center == (105, 210)
    @test r.centerx == 105
    @test r.centery == 210
    @test r.centerleft == (100, 210)
    @test r.centerright == (110, 210)
    @test r.topcenter == (105, 200)
    @test r.bottomcenter == (105, 220)
end

@testset "set positions" begin

@testset    begin
    r = Rect(300, 400, 10, 20)
    @test r.pos == (300, 400)
    r.pos = (100,200)
    @test r.pos == (100, 200)
end 
@testset begin
    r = Rect(300, 400, 10, 20)
    r.x = 100
    r.y = 200
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.topleft = (100,200)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.top = 200
    r.left = 100
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.topright = (110, 200)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.bottomleft = (100, 220)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.bottomright = (110, 220)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.bottom = 220
    r.right = 110
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.center = (105, 210)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.centerx = 105
    r.centery = 210
    @test r.pos == (100, 200)
end

@testset begin
    r = Rect(300, 400, 10, 20)
    r.centerleft = (100, 210)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.centerright = (110, 210)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.topcenter = (105, 200)
    @test r.pos == (100, 200)
end
@testset begin
    r = Rect(300, 400, 10, 20)
    r.bottomcenter = (105, 220)
    @test r.pos == (100, 200)
end
end

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
