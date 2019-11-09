local Vec2 = require("vec2")
local CPolygon = require("cpolygon")

function addAnotherWallPolygon()
    local wall = {}
    wall.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
    local numVerts = 4--love.math.random(3, 7)
    local radius = 5--love.math.random(10, 20)
    wall.shape = love.physics.newPolygonShape(CPolygon.makePolygonVerts(numVerts, radius))
    wall.fixture = love.physics.newFixture(wall.body, wall.shape, 1)
    objects.walls[#objects.walls+1] = wall
end

function love.load()
    --  globals
    camera = CPolygon.newShape(
        love.graphics.getWidth()/2,
        love.graphics.getHeight()/2,
        3, 10, 0
    )
    
    numRays = 50
    fov = 40

    --  create physics world
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 0, true)
    
    --  create some physics bodies
    objects = {}
    objects.walls = {}
    for i=0,100 do
        addAnotherWallPolygon()
    end

    --create camera physics body
    objects.camera = {}
    objects.camera.body = love.physics.newBody(world, love.graphics.getWidth()/4, love.graphics.getHeight()/4, "dynamic")
    objects.camera.shape = love.physics.newPolygonShape(CPolygon.makePolygonVerts(3, 10))
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
    if love.keyboard.isDown("space") then
        addAnotherWallPolygon()
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
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Num Bodies: "..tostring(#objects.walls), 10, 30)

    -- --  draw rays coming out of camera
    local anglePerRay = math.rad(fov / numRays)
    local halfFov = math.rad(fov / 2)
    local startingAngle = objects.camera.body:getAngle() - halfFov - math.pi/2
    local endingAngle = objects.camera.body:getAngle() + halfFov - math.pi/2
    for angle=startingAngle, endingAngle, anglePerRay do
        --  draw line centered on camera, of long length
        love.graphics.push()
        love.graphics.translate(objects.camera.body:getX(), objects.camera.body:getY())
        love.graphics.rotate(angle)
        love.graphics.line(0, 0, 0, 100)
        love.graphics.pop()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
 end

 function love.keyreleased(key)
 end