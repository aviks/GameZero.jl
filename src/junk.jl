"""Transform anchor based upon a rotation of a surface of size w x h."""
function  transform_anchor(ax, ay, w, h, angle)

    θ = -deg2rad(angle)

    sinθ = sin(θ)
    cosθ = cos(θ)

    # Dims of the transformed rect
    tw = abs(w * cosθ) + abs(h * sinθ)
    th = abs(w * sinθ) + abs(h * cosθ)

    # Offset of the anchor from the center
    cax = ax - w * 0.5
    cay = ay - h * 0.5

    # Rotated offset of the anchor from the center
    rax = cax * costheta - cay * sintheta
    ray = cax * sintheta + cay * costheta

    return (
        tw * 0.5 + rax,
        th * 0.5 + ray
    )
end
