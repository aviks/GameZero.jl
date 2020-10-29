using Documenter, GameZero
using Literate
using LibGit2

docspath=@__DIR__
out_path = joinpath(docspath, "src", "examples")
rm(joinpath(docspath, "gzexamples"); force=true, recursive=true)
rm(out_path; force=true, recursive=true )

cd(docspath) do 
    LibGit2.clone("https://github.com/SquidSinker/GZExamples", "gzexamples")
end

config = Dict{Any, Any}("documenter"=>false, "execute"=>false, "credit"=>false)
config["repo_root_url"] = "https://github.com/SquidSinker/GZExamples"
config["repo_root_path"] = "gzexamples"

Literate.markdown(joinpath(docspath, "..", "example", "BasicGame", "basic.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath, "..", "example", "BasicGame", "basic2.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Breakout", "Breakout.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Spaceship", "Spaceship.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Pandemic Sim", "pandemicsim.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Galaxian", "Galaxian.jl"),  out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Flappy bird", "flappybird.jl"), out_path; config=config)
Literate.markdown(joinpath(docspath,"gzexamples", "Tic-tac-toe", "tictactoe.jl"), out_path; config=config)

makedocs(;
    modules=[GameZero],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "Examples" => Any[
            "Basic Game 1" => "examples/basic.md",
            "Basic Game 2" => "examples/basic2.md",
            "BreakOut" => "examples/Breakout.md",
            "Spaceship" => "examples/Spaceship.md",
            "Pandemic Sim" => "examples/pandemicsim.md",
            "Galaxian" => "examples/Galaxian.md",
            "Flappy Bird" => "examples/flappybird.md",
            "Tic-Tac-Toe" => "examples/tictactoe.md"

        ],
        "API" => "api.md"
    ],
    sitename="GameZero.jl",
    authors="Avik Sengupta, Ahan Sengupta"
)

