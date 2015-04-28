require "images"

function createBall(world, x, y, VELOCITY)
  body = love.physics.newBody(world, x, y, "dynamic")
  shape = love.physics.newCircleShape(25)
  fixture = love.physics.newFixture(body, shape)
  fixture:setUserData("ball")
  fixture:setRestitution(0.5)
  body:setLinearVelocity(VELOCITY[1], VELOCITY[2])
  return {body = body, shape = shape, fixture = fixture}
end

function createPlatform(world, x, y, sizeX, sizeY)
  body = love.physics.newBody(world, x, y)
  shape = love.physics.newRectangleShape(sizeX, sizeY)
  fixture = love.physics.newFixture(body, shape)
  fixture:setUserData("platform")
  return {body = body, shape = shape, fixture = fixture, sizeX = sizeX, sizeY = sizeY, data = "platform"}
end

function createMagnet(world, x, y, power, radius)
  body = love.physics.newBody(world, x, y)
  shape = love.physics.newCircleShape(radius)
  fixture = love.physics.newFixture(body, shape)
  fixture:setUserData("magnet")
  return {body = body, shape = shape, fixture = fixture, power = power}
end

function createTrap(world, x, y, sizeX, sizeY)
  body = love.physics.newBody(world, x, y)
  shape = love.physics.newRectangleShape(sizeX, sizeY)
  fixture = love.physics.newFixture(body, shape)
  fixture:setUserData("trap")
  return {body = body, shape = shape, fixture = fixture, sizeX = sizeX, sizeY = sizeY}
end

function createFinish(world, x, y)
  body = love.physics.newBody(world, x, y, "static")
  shape = love.physics.newCircleShape(44)
  fixture = love.physics.newFixture(body, shape)
  fixture:setUserData("finish")
  return {body = body, shape = shape, fixture = fixture}
end

function drawObject(object)
    love.graphics.setColor(255, 255, 255)
    if object.fixture:getUserData()== "ball" then
      local radius = object.shape:getRadius()
      love.graphics.draw(ballImg, object.body:getX()-radius, object.body:getY()-radius, 0, radius*2/ballImg:getWidth(), radius*2/ballImg:getHeight())
    elseif object.fixture:getUserData() == "platform" then
      love.graphics.setColor(51, 35, 60)
      love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
      --love.graphics.draw(platformImg, object.body:getX()-object.sizeX/2, object.body:getY()-object.sizeY/2, object.body:getAngle(), object.sizeX/543, object.sizeY/154)
    elseif object.fixture:getUserData() == "magnet" then
      local radius = object.shape:getRadius()
      local img = (object.power >= 0 and magnetImg1 or magnetImg2)
      love.graphics.draw(img, object.body:getX()-radius, object.body:getY()-radius, 0, radius*2/img:getWidth(), radius*2/img:getHeight())
    elseif object.fixture:getUserData() == "trap" then
      love.graphics.setColor(100, 230, 50)
      love.graphics.polygon("fill", object.body:getWorldPoints(object.shape:getPoints()))
      --love.graphics.draw(trapImg, object.body:getX()-object.sizeX/2, object.body:getY()-object.sizeY/2, object.body:getAngle(), object.sizeX/543, object.sizeY/154)
    elseif object.fixture:getUserData() == "finish" then
      love.graphics.draw(finishImg, object.body:getX()-40, object.body:getY()-45)
      --love.graphics.draw()
    end
end
