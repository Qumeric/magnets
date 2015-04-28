lady = require 'lady/lady'
require "objects"
require "constants"
require "images"
objTable = {}

function loadgame()
  world, objTable = lady.load_all(LEVELS[LEVEL])
  ball = createBall(world, LEVELP[LEVEL][1], LEVELP[LEVEL][2], {0, 0})
  cnt = LEVELX[LEVEL]

  GAME_STATE = "static"
  
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function love.load()
  love.physics.setMeter(METER_SIZE)
  world = love.physics.newWorld(GRAVITYX, GRAVITYY*METER_SIZE, true)

  loadgame()

  current = createPlatform(world, 0, 0, 33, 33)
end

function love.update(dt)
  if GAME_STATE == "dynamic" then
    world:update(dt) --this puts the world into motion
  end
  
  if current then
    local angle = current.body:getAngle()
    local data = current.fixture:getUserData()
    if love.keyboard.isDown("right") or love.keyboard.isDown("left") then
      if data == "platform" or data == "trap" then
        sizeX = current.sizeX + 2 - (love.keyboard.isDown("left") and 4 or 0)
        sizeY = current.sizeY
        current.fixture:destroy(); 
        current.body:destroy()
        
        if data == "platform" then
          current = createPlatform(world, 0, 0, sizeX, sizeY)
        elseif data == "trap" then
          current = createTrap(world, 0, 0, sizeX, sizeY)
        end
        current.body:setAngle(angle)
      elseif data == "magnet" then
        current.power = current.power + 0.05 - (love.keyboard.isDown("left") and 0.1 or 0)
      end
    elseif love.keyboard.isDown("r") then
      current.body:setAngle(current.body:getAngle()+0.01)
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("up") then
      if data == "magnet" then
        local radius = current.shape:getRadius()
        current.fixture:destroy()
        current.body:destroy()
        current = createMagnet(world, 0, 0, 0.8, radius - 0.1)
      elseif data == "platform" or data == "trap" then
        sizeX = current.sizeX
        sizeY = current.sizeY + 2 - 4 * (love.keyboard.isDown("down") and 1 or 0)
        current.fixture:destroy(); 
        current.body:destroy()
        if data == "platform" then
          current = createPlatform(world, 0, 0, sizeX, sizeY)
        elseif data == "trap" then
          current = createTrap(world, 0, 0, sizeX, sizeY)
        end
        current.body:setAngle(angle)
      end
    end
    
    current.body:setX(love.mouse.getX())
    current.body:setY(love.mouse.getY())
  end
  
  for _, obj in pairs(objTable) do
    x, y = obj.body:getPosition()
    if x > 1500 or x < -200 or y > 1000 or y < -200 then
      table.remove(objTable, _)
    end
  end
  
  if love.keyboard.isDown("a") then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) then
        i.fixture:destroy()
        i.body:destroy()
        table.remove(objTable, _)
      end
    end
  end
  
  if love.keyboard.isDown("s") then
    VELOCITY[1] = (love.mouse:getX()-640)/2
    VELOCITY[2] = (love.mouse:getY()-360)/2
  end
  
  useMagnets()
end

function useMagnets() 
  for _, i in pairs(objTable) do
    if i.fixture:getUserData() == "ball" then
      for a, b in pairs(objTable) do
        if b.fixture:getUserData() == "magnet" then
          xb, yb = i.body:getPosition()
          xm, ym = b.body:getPosition()
          dx = xb-xm
          dy = yb-ym
          dist = math.sqrt(dy*dy+dx*dx)
          if dist > 210 then dist = dist+math.pow((dist-210), 2) end
          ad = 100000/dist
          atan2 = math.atan2(dy, dx)
          i.body:applyForce(BALLP*ad*b.power*math.cos(atan2), BALLP*ad*b.power*math.sin(atan2))
        end
      end
    end
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bgImg, 0, 0)
  love.graphics.printf(cnt, 50, 50, 50)
  for _, i in pairs(objTable) do
    drawObject(i)
  end
  
  if current then drawObject(current) end
  
  love.graphics.printf(VELOCITY[1], 20, 50, 20)
  love.graphics.printf(VELOCITY[2], 20, 100, 20)
end

function clear()
  local deltable = {}
  for a, b in pairs(objTable) do
    b.fixture:destroy()
    b.body:destroy()
    table.insert(deltable, a)
  end
  for a, b in ipairs(deltable) do
    table.remove(objTable, b)
  end
end

function beginContact(a, b, coll)
    ad = a:getUserData()
    bd = b:getUserData()

    if (ad == "ball" and bd == "finish") or (ad == "finish" and bd == "ball") then
      clear()
      LEVEL = LEVEL + 1
      world, objTable = lady.load_all(LEVELS[LEVEL])
      world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    elseif (ad == "ball" and bd == "trap") or (ad == "trap" and bd == "ball") then
      clear()
      world, objTable = lady.load_all(LEVELS[LEVEL])
      world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    end
end

function love.keypressed(key, isrepeat)
  if key == "q" then
    lady.save_all(LEVELS[LEVEL], world, objTable)
    love.event.quit()  
  elseif key == "z" then
    table.insert(objTable, createBall(world, love.mouse:getX(), love.mouse:getY(), VELOCITY))
  elseif love.keyboard.isDown("b") then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  elseif key == " " then
    if GAME_STATE == "dynamic" then GAME_STATE = "static" else GAME_STATE = "dynamic" end
  elseif key >= "1" and key <= "9" then
    if current then current.fixture:destroy(); current.body:destroy() end
    if key == "1" then
      current = createPlatform(world, 0, 0, 33, 33)
    elseif key == "2" then
      current = createMagnet(world, 100, 100, 0.8, 33)
    elseif key == "3" then
      current = createTrap(world, 0, 0, 33, 33)
    elseif key == "4" then
      current = createFinish(world, 0, 0)
    else
      current = nil
    end
  end
end

function love.mousepressed(x, y, button)
  if current then
    if button == "l" then
      table.insert(objTable, current)
      current = nil
    end
  end
end
