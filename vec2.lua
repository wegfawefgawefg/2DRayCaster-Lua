--  Port of Vec2 class from Processing  -- 
local M = {}

function M.fromAngle(angle)
    return {math.cos(angle), math.sin(angle)}
end

function M.div(vec2, mag)
    vec2[1] = vec2[1] / mag
    vec2[2] = vec2[2] / mag
end

function M.mag(vec2)
    return math.sqrt(vec2[1]*vec2[1] + vec2[2]*vec2[2])
end

function M.normalize(vec2)
    local mag = M.mag(vec2)
    M.div(vec2, mag)
end

function M.mult(vec2, scalar)
    vec2[1] = vec2[1] * scalar
    vec2[2] = vec2[2] * scalar
end

function M.setMag(vec2, mag)
    M.normalize(vec2)
    M.mult(vec2, mag)
end

return M