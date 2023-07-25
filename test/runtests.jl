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

@testset "exported symbols" begin
    vars = names(GameZero)
    @test all(isdefined.(Ref(GameZero),vars))
end

@testset "keys" begin
    @test Keys.ESCAPE==27
    @test KeyMods.LALT==0x100
end

let ev=GameZero.SDL_Event(ntuple(UInt8,56))
    @test ev.window.event==0x0d
end

@testset "timer" begin
    GameZero.scheduler[] = GameZero.Scheduler()
    flag=false
    f()= (flag=true;nothing)
    function _sleep(t)
        t1=Base.time_ns()
        while true
            sleep(0.01)
            Base.time_ns()-t1 > t * 1.0e9 && break
        end
    end

    @testset "once" begin
        flag=false
        schedule_once(f,1)
        schedule_once(f,0.5)
        @test flag==false
        _sleep(0.5)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
        flag=false
        _sleep(0.5)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
    end

    @testset "unique" begin
        flag=false
        schedule_once(f,1)
        schedule_unique(f,0.5)
        @test flag==false
        _sleep(0.5)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
        flag=false
        _sleep(0.5)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==false
    end
    
    @testset "interval" begin
        flag=false
        schedule_interval(f,1)
        @test flag==false
        _sleep(1)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
        flag=false
        _sleep(1)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
        GameZero.clear!(GameZero.scheduler[])
    end

    function schedule_conti(f::Function, interval)
        push!(GameZero.scheduler[], GameZero.ContingentScheduled(WeakRef(f), GameZero.elapsed(scheduler[])+interval*1e9))
    end
    f2()=(flag=true;0.5)
    @testset "contingent" begin
        flag=false
        schedule_conti(f,1)
        @test flag==false
        _sleep(1)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true

        flag=false
        schedule_conti(f2,1)
        @test flag==false
        _sleep(1)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
        flag=false
        _sleep(0.5)
        GameZero.tick!(GameZero.scheduler[])
        @test flag==true
    end

end


include("examples.jl")

@testset "File not exist" begin
    GameZero.file_path(name::String,subdir::Symbol)=throw(ArgumentError("File not exist"))
    @test_throws ArgumentError play_music("filenotexist")
    @test_throws ArgumentError play_sound("filenotexist")
    @test_throws ArgumentError GameZero.image_surface("filenotexist")
end

@testset "Invalid file" begin
    GameZero.file_path(name::String,subdir::Symbol)=@__FILE__
    @test_throws ErrorException play_music("invalidfile")
    @test_logs (:warn,r"Could not load") play_sound("invalidfile")
    @test_throws ErrorException GameZero.image_surface("invalidfile")
end