using Documenter, GameZero

makedocs(;
    modules=[GameZero],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/aviks/GameZero.jl/blob/{commit}{path}#L{line}",
    sitename="GameZero.jl",
    authors="Avik Sengupta",
    assets=String[],
)

deploydocs(;
    repo="github.com/aviks/GameZero.jl",
)
