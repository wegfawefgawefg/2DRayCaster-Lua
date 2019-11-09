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
    local anglePerSegment = 2 * math.pi / (numPoints)
    for angle=0, 2*math.pi, anglePerSegment do
        verts[#verts+1] = math.cos(angle) * radius
        verts[#verts+1] = math.sin(angle) * radius
    end
    return verts
end

function love.load()
    --  globals
    camera = newShape(
        love.graphics.getWidth()/2,
        love.graphics.getHeight()/2,
        3, 10, 0
    )
    
    numRays = 50
    fov = 120

    --  create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 0, true)
    
    --  create some physics bodies
    objects = {}
    objects.walls = {}
    for i=0,10 do
        local wall = {}
        wall.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
        wall.shape = love.physics.newPolygonShape(makePolygonVerts(love.math.random(3, 7), love.math.random(10, 50)))
        wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
        objects.walls[#objects.walls+1] = wall
    end

    --create camera physics body
    objects.camera = {}
    objects.camera.body = love.physics.newBody(world, love.graphics.getWidth()/4, love.graphics.getHeight()/4, "dynamic")
    objects.camera.shape = love.physics.newPolygonShape(makePolygonVerts(3, 10))
    objects.camera.fixture = love.physics.newFixture(objects.camera.body, objects.camera.shape, 1)
end

function checkKeypresses( dt )
	--	let player controls 	--
	if love.keyboard.isDown( "a" ) then
        objects.camera.body:setAngle(objects.camera.body:getAngle() - 0.1)
	end
	if love.keyboard.isDown( "d" ) then
        objects.camera.body:setAngle(objects.camera.body:getAngle() + 0.1)
	end

	--	right player controls 	--
    local angleDelta = 0.05
    local dist = 1.0
	if love.keyboard.isDown( "s" ) then
        --  get angle of shape
        local camAngle = objects.camera.body:getAngle()
        --  generate point at distance 1 from that angle
        local ldx = math.cos(camAngle - angleDelta) * -dist
        local ldy = math.sin(camAngle - angleDelta) * -dist
        objects.camera.body:setPosition(
            objects.camera.body:getX() + ldx,
            objects.camera.body:getY() + ldy    )
	end
	if love.keyboard.isDown( "w" ) then
        --  get angle of shape
        local camAngle = objects.camera.body:getAngle()
        --  generate point at distance 1 from that angle
        local ldx = math.cos(camAngle + angleDelta) * dist
        local ldy = math.sin(camAngle + angleDelta) * dist
        objects.camera.body:setPosition(
            objects.camera.body:getX() + ldx,
            objects.camera.body:getY() + ldy    )
    end
end

function love.update(dt)
    checkKeypresses(dt)
    world:update( dt )
end

function drawWalls()
    for i, wall in ipairs(objects.walls) do
        love.graphics.setColor( 255, 255, 255 )
        love.graphics.polygon("fill", wall.body:getWorldPoints( wall.shape:getPoints() ) )
    end
end

function drawCamera()
    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("fill", objects.camera.body:getWorldPoints( objects.camera.shape:getPoints() ) )
end

function love.draw()
    drawWalls()
    drawCamera()

    -- --  draw rays coming out of camera
    -- local anglePerRay = fov / numRays
    -- local halfFov = fov / 2
    -- local startingAngle = camera.angle - halfFov
    -- local endingAngle = camera.angle + halfFov
    -- for angle=startingAngle, endingAngle, anglePerRay do
    --     --  draw line centered on camera, of long length
    --     love.graphics.push()
    --     love.graphics.rotate(angle)
    --     love.graphics.translate(camera.x, camera.y)
    --     love.graphics.line(0, 0)
    -- end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
 end

 function love.keyreleased(key)
 end