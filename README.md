# GameZero

[![Build Status](https://github.com/aviks/GameZero.jl/workflows/CI/badge.svg?event=push&branch=master)](https://github.com/aviks/GameZero.jl/actions?query=workflow%3ACI)
[![version](https://juliahub.com/docs/GameZero/version.svg)](https://juliahub.com/ui/Packages/GameZero/tTDGf)
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliahub.com/docs/GameZero/tTDGf/)
[![Build Status](https://travis-ci.org/aviks/GameZero.jl.svg?branch=master)](https://travis-ci.com/aviks/GameZero.jl)

A zero overhead game development framework for beginners.

## Overview
The aim of this package is to remove accidental complexity from the game development process. We therefore always choose simplicity and consistency over features. The users of this package will include young programmers learning their first language, maybe moving on from Scratch. While we aim to support reasonably sophisticated 2D games, our first priority will remain learners, and their teachers.

## Running Games

Games created using GameZero are `.jl` files that live in any directory. 
To play the games, start the Julia REPL and:

```
pkg> add GameZero

pkg> add Colors

julia> using GameZero

julia> rungame("C:\\path\\to\\game\\Spaceship\\Spaceship.jl")

```

## Creating Games
[Read the documentation](https://juliahub.com/docs/GameZero/tTDGf/) to get started. The best way to learn how to use this package is by looking at existing games created with it. There are some simple examples in the [example subdirectory](https://github.com/aviks/GameZero.jl/tree/master/example/BasicGame). More comprehensive examples are listed in the [GZExamples](https://github.com/SquidSinker/GZExamples) repository. The documentation will also display the example sources. 

## Status
This is an early release. Please try to make new games, and [report](https://github.com/aviks/GameZero.jl/issues) any bugs, usability issues or missing features. We particularly welcome more games in the [GZExamples](https://github.com/SquidSinker/GZExamples) repository.

## Acknowledgement
The design of this library is inspired by the python package [PyGameZero](https://pygame-zero.readthedocs.io) by [Daniel Pope](https://github.com/lordmauve). Much of the design however has been changed to make things more Julian, and the implementation is independent.

GameZero uses [SDL2](https://www.libsdl.org/) via the [Julia wrapper](https://github.com/jonathanBieler/SimpleDirectMediaLayer.jl).
