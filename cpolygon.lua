local M = {}

function M.newShape(x, y, numPoints, radius, rotAngle)
    local shape = {}
    shape.x = x
    shape.y = y
    shape.radius = radius
    shape.angle = rotAngle
    shape.verts = {}

    -- fill verts
    local anglePerSegment = 2 * math.pi / (numPoints - 1)
    for angle=0, 2*math.pi, anglePerSegment do
        shape.verts[#shape.verts+1] = math.cos(angle) * radius
        shape.verts[#shape.verts+1] = math.sin(angle) * radius
    end
    return shape
end

function M.makePolygonVerts(numPoints, radius)
    verts = {}
    local anglePerSegment = 2 * math.pi / (numPoints)
    for angle=0, 2*math.pi, anglePerSegment do
        verts[#verts+1] = math.cos(angle) * radius
        verts[#verts+1] = math.sin(angle) * radius
    end
    return verts
end

return M