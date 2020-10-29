"""
play_sound(filename::String, loops::Integer)

Plays a sound effect from the `sounds` subdirctory. It will play the specified number of times. If not specified, it will default to once.
"""
function play_sound(name, loops=0)
    sound_file = file_path(name, :sounds)
    sample=SDL2.Mix_LoadWAV(sound_file);
    if sample == C_NULL
        @warn "Could not load sound file: $sound_file\n$(getSDLError())"
        return
    end
    r = SDL2.Mix_PlayChannel(Int32(-1), sample, Int32(loops))
    if r == -1
        @warn "Unable to play sound $sound_file\n$(getSDLError())"
    end
end

"""
play_music(name::String, loops::Integer)

Plays music from the `sounds` subdirectory. It will play the file the specified number of times. If not specified, it will default to infinitely.
"""
function play_music(name, loops=-1)
    music_file = file_path(name, :music)
    music = SDL2.Mix_LoadMUS(music_file)
    SDL2.Mix_PlayMusic( music, Int32(loops) )
end

const resource_ext = Dict(
        :images=>"[png|jpg|jpeg]",
        :sounds=>"[mp3|ogg|wav]",
        :music=>"[mp3|ogg|wav]")

function image_surface(image::String)
    image_file = file_path(image, :images)
    sf = SDL2.IMG_Load(image_file)
    if sf == C_NULL
        throw("Error loading $image_file")
    end
    return sf
end

function file_path(name::String, subdir::Symbol)
    path = joinpath(game[].location, String(subdir))
    @assert isdir(path)
    allfiles = readdir(path)
    allexts = resource_ext[subdir]
    validate_name(name)
    for x in allfiles
        if occursin(Regex("$(name)(\\.$(allexts))?", "i"), x)
            return joinpath(path, x)
        end
    end
    # We try to return helpful messages if the file could not be found
    for x in allfiles
        if basename(x) == name
            @warn "Did you mean $x? We can only handle the follwing extensions: $allexts"
        end
        if edit_distance(x, name) / length(name) <= .5
            @warn "Did you mean $x instead of $names. Please check your spelling."
        end
    throw(ArgumentError("No file: $name in $path")); end

end

"""
Simplistic string edit distance method
"""
function edit_distance(x, y)
    #Convert strings to char arrays so that we can index into it
    xx = [i for i in x]
    yy = [i for i in y]

    m=length(xx)
    n=length(yy)

    r = zeros(Int, m+1, n+1)

    # Iterate through substrings
    for i in 1:(m + 1)
        for j in 1:(n + 1)
            if i == 1
                r[i, j] = j
            elseif j == 1
                r[i, j] = i
            elseif xx[i-1] == yy[j-1]
                r[i, j] = r[i-1, j-1]
            else
                r[i, j] = 1 + min(r[i, j-1], r[i-1, j],  r[i-1, j-1])
            end
        end
    end
    return r[m+1, n+1]
end


function validate_name(name::String)
    if occursin(' ', name)
        @warn("Do not use spaces in resource names. It may cause problems when moving accross platforms: $name")
    end
    if lowercase(name) != name
        @warn("Use lowercases names for resource files. It is safer when moving between windows and unix: $name")
    end
end
