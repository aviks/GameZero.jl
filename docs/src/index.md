# Zero Overhead Game Development

## Overview
The aim of this package is to remove accidental complexity from the game development process. We therefore always choose simplicity and consistency over features. The users of this package will include young programmers learning their first language, maybe moving up from Scratch. While we aim to support reasonably sophisticated 2D games, our first priority will remain learners, and their teachers.

## Example
The best way to learn how to use this package is by looking at code. There are some simple examples in the [example subdirectory](https://github.com/aviks/GameZero.jl/tree/master/example/BasicGame). More comprehensive examples are listed in the [GZExamples](https://github.com/SquidSinker/GZExamples) repository.

## Assets
![](assets/directory_structure.png)
Each game, and its assets, are stored in a separate directory. Within this directory, there is a .jl file, which stores the game code. As well as this, there are three subfolders for sounds, images, and music. The games are executed using the rungame function provided by the Game Zero package, meaning that games do not have to be Julia packages or modules, making it much simpler. An empty file also counts as a valid game.

## Initialising a screen
To initalise a screen, all that is needed to define a set of three global variables:
```
HEIGHT
WIDTH
BACKGROUND
```
All of these are optional, and if not specified, will default to 400*400, and a white background

## Actors
Game objects on-screen are represented as `Actors` which have several associated attributes. Using `Actors`, you can change position, change the image and check for collisions. However, not all moving parts need to be Actors as those without a specific image can be defined as a `Circle` or a `Rect`, which have the same associated attributes (apart from image). `Actors` are usually the primary game objects that you move around.

## Rects and Circles
GameZero.jl also includes basic geometric shapes. `Rects`, `Circles` and `Lines` can be used to do everything an `Actor` can, having the same attributes (apart from image).

## Moving objects
All objects have many attributes to define position. The corners — `topleft`, `topright`, `bottomleft`, and `bottomright` — are tuples (x and y coordinates). The sides — `top`, `bottom`, `left` and `right` — read either the x or y coordinate (top and bottom are x, left and right are y). These position attributes can be used either to read position or to set position. In addition, objects also have an x and y attribute which are anchored to the top left of the objects.

## Draw and Update methods
These functions are run by the game engine automatically every frame, meaning developers do not have to define their own event loop. The `update` function is used to change game state and attributes of the Actors and the `draw` function renders on-screen objects.

## Keyboard inputs
To take an instantaneous input, use the `on_key_down`. For a constant input, such as for movement, use an if statement in the update function to check the value of the keyboard attribute of the game object (`g.keyboard`).

## Mouse input
Mouse movement can be tracked using the `on_mouse_move` function. For mouse clicks, use the `on_mouse_down` function.

## Playing sounds
To play sound effects, you can use the `play_sound` function. To play music on a loop, use the `play_music` function.

## Timers
To set a timer in a normal program, `sleep` would be used. However, in this instance, this would cause the whole game to pause for that amount of time. Therefore, to avoid having to use a complicated `@async` loop, you can use the function `schedule_once`, which takes a function and a time in seconds, and sets the function to run after that amount of time.

## Animation
To animate an actor, the image is changed several times as seen in the loop below. Better animation is most likely coming very soon.
```
function shoot_animation()
    global shoot_frame
    if shoot_frame < 16
        space_pod.image = "space_pod_shoot" * string(shoot_frame) * ".png"
        shoot_frame += 1
        schedule_once(shoot_animation, 1/16)
    else
        space_pod.image = "space_pod.png"
    end
end
```
