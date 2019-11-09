function newShape(x, y, numPoints, radius, rotAngle)
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
    for i,k in pairs(shape.verts) do
        print(k)
    end
    return shape
end

function makePolygonVerts(numPoints, radius)
    verts = {}
    local anglePerSegment = 2 * math.pi / (numPoints - 1)
    for angle=0, 2*math.pi, anglePerSegment do
        verts[#verts+1] = math.cos(angle) * radius
        verts[#verts+1] = math.sin(angle) * radius
    end
    return verts
end

function love.load()
    --  globals
    camera = {}
    camera.x = love.graphics.getWidth()/2
    camera.y = love.graphics.getHeight()/2
    camera.angle = 0
    
    numRays = 50
    fov = 120
    

    --  create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 0, true)
    
    --  create some physics bodies
    objects = {}
    objects.walls = {}
    for i=0,1 do
        local wall = {}
        wall.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
        wall.shape = love.physics.newPolygonShape(makePolygonVerts(4, 50))
        wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
        objects.walls[#objects.walls+1] = wall
    end
end

function love.update()
end

function drawWalls()
    for i, wall in ipairs(objects.walls) do
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.polygon("fill", wall.body:getWorldPoints( wall.shape:getPoints() ) )
    end
end

function love.draw()
    drawWalls()

    --  draw camera
    --  draw rays coming out of camera
end

