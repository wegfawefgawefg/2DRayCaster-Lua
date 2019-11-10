local Vec2 = require("vec2")
local CPolygon = require("cpolygon")

function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
    if fraction < rayCasts[currentRayBeingCasted].closestHitFrac then
        local hit = {}
        hit.fixture = fixture
        hit.x, hit.y = x, y
        hit.xn, hit.yn = xn, yn
        hit.fraction = fraction

        rayCasts[currentRayBeingCasted].closestHitFrac = fraction

        rayCasts[currentRayBeingCasted].hit = hit
    end
	return 1 -- Continues with ray cast through all shapes.
end

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
    --  render settings
    love.window.setFullscreen(true, "desktop")
    --  globals
    camera = CPolygon.newShape(
        love.graphics.getWidth()/2,
        love.graphics.getHeight()/2,
        3, 100, 0
    )
    
    minNumRays = 20
    numRays = 128
    fov = 90
    currentRayBeingCasted = 1

    rayCasts = {}

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
    objects.camera.shape = love.physics.newPolygonShape(CPolygon.makePolygonVerts(3, 40))
    objects.camera.fixture = love.physics.newFixture(objects.camera.body, objects.camera.shape, 1)
end

function createRays()
    --  ADAPTIVE RAYCOUNT MODE, (DO NOT ENABLE)
    -- fps = love.timer.getFPS()
    -- print(fps)
    -- if fps < 144 then
    --     numRays = numRays - 1
    --     if numRays < minNumRays then
    --         numRays = minNumRays
    --     end
    -- elseif fps >= 144 then
    --     numRays = numRays + 1
    -- end
    local rays = {}
    local anglePerRay = math.rad(fov / numRays)
    local halfFov = math.rad(fov / 2)
    local startingAngle = objects.camera.body:getAngle() - halfFov
    local endingAngle = objects.camera.body:getAngle() + halfFov
    for angle=startingAngle, endingAngle, anglePerRay do
        local ray = {}
        ray = Vec2.fromAngle(angle)
        Vec2.mult(ray, 300)
        --  create closest hit default
        ray.closestHitFrac = 1e309
        table.insert(rays, ray)
    end   
    return rays
end

function checkKeypresses( dt )
    local angleDelta = 0.02
	--	let player controls 	--
	if love.keyboard.isDown( "a" ) then
        objects.camera.body:setAngle(objects.camera.body:getAngle() - angleDelta)
	end
	if love.keyboard.isDown( "d" ) then
        objects.camera.body:setAngle(objects.camera.body:getAngle() + angleDelta)
	end

	--	right player controls 	--
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

function drawWalls()
    love.graphics.setColor( 1.0, 0.6, 0.6 )
    for i, wall in ipairs(objects.walls) do
        love.graphics.polygon("fill", wall.body:getWorldPoints( wall.shape:getPoints() ) )
    end
end

function drawCamera()
    love.graphics.setColor(255, 0, 0)
    love.graphics.polygon("fill", objects.camera.body:getWorldPoints( objects.camera.shape:getPoints() ) )
end

function drawRays()
    love.graphics.push()
    love.graphics.setColor(255, 255, 255)
    for i, ray in ipairs(rayCasts) do
        love.graphics.push()
        love.graphics.translate(
            objects.camera.body:getX(),
            objects.camera.body:getY())
        love.graphics.line(0, 0, ray[1], ray[2])
        love.graphics.pop()
    end
    love.graphics.pop()
end

function castRays()
    for i, ray in ipairs(rayCasts) do
        currentRayBeingCasted = i
        world:rayCast(
            objects.camera.body:getX(), 
            objects.camera.body:getY(),
            objects.camera.body:getX() + ray[1],
            objects.camera.body:getY() + ray[2], 
            worldRayCastCallback)
    end
end

function drawHits()
    for i, ray in ipairs(rayCasts) do
        if ray.hit then
            local hit = ray.hit
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle("line", hit.x, hit.y, 3)
            love.graphics.setColor(0, 255, 0)
            love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
        end
    end
end

function love.update(dt)
    rayCasts = createRays()
    checkKeypresses(dt)
    world:update( dt )
    castRays()
end

function drawRayCastFPView()
    local slitWidth = love.graphics.getWidth() / numRays
    local tlx = -slitWidth
    local halfHeight = love.graphics.getHeight() / 2
    for i, rayCast in ipairs(rayCasts) do
        tlx = tlx + slitWidth
        if rayCast.hit then
            --  get distance to hit
            local dist = math.sqrt(
                math.pow(math.abs(objects.camera.body:getX() - rayCast.hit.x),2) + 
                math.pow(math.abs(objects.camera.body:getY() - rayCast.hit.y),2)
            )
            --  scale distance inversely vertically
            local w = love.graphics.getWidth() / love.graphics.getHeight();
            local d = dist / love.graphics.getWidth();
            local sq = math.pow(dist, 2.0);
            local wSq = math.pow(love.graphics.getWidth(), 2.0);
            local b = 5 / math.pow(d, 2.0);
            local rectHeight = 30 / d;
            
            local ty = halfHeight - rectHeight / 2
            
            --  draw a strip
            local shade = 1/d / 30
            -- print(shade)
            love.graphics.setColor(shade, shade, shade)
            love.graphics.rectangle(
                "fill",
                tlx,
                ty,
                slitWidth,
                rectHeight
            )
            -- love.graphics.line(tlx, ty, tlx, ty + rectHeight)
        end
    end
    
end

function love.draw()
    drawRayCastFPView()

    --  debug prints
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    love.graphics.print("Num Bodies: "..tostring(#objects.walls), 10, 30)
    love.graphics.print("Num Rays: "..tostring(numRays), 10, 50)

    --  draws
    drawWalls()
    drawCamera()
    -- drawRays()
    -- drawHits()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
 end

 function love.keyreleased(key)
 end