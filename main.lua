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
  love.graphics.setNewFont(32)

  love.physics.setMeter(METER_SIZE)
  world = love.physics.newWorld(GRAVITYX, GRAVITYY*METER_SIZE, true)

  loadgame()
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

function love.update(dt)
  if GAME_STATE == "dynamic" then
    world:update(dt)
  end
  
  for _, obj in pairs(objTable) do
    x, y = obj.body:getPosition()
    if x > 1500 or x < -200 or y > 1000 or y < -200 then
      table.remove(objTable, _)
    end
  end
  
  useMagnets()
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bgImg, 0, 0)
  love.graphics.printf(cnt, 50, 50, 50)
  for _, i in pairs(objTable) do
    drawObject(i)
  end
  if ball then drawObject(ball) end

  if LEVEL == 5 then
    width, height = love.window.getMode( )
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("The End!", width/2-80, height/2-20)
  end
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
      loadgame()
    elseif (ad == "ball" and bd == "trap") or (ad == "trap" and bd == "ball") then
      clear()
      loadgame()
    end
end

function love.keypressed(key, isrepeat)
  if key == "r" then
    loadgame()
  elseif key == " " then
    if GAME_STATE == "static" then
      ball.body:applyForce(LEVELV[LEVEL][1], LEVELV[LEVEL][2])
      table.insert(objTable, ball)
      GAME_STATE = "dynamic"
    end
  elseif key == "z" then -- cheat code FIXME
    table.insert(objTable, createBall(world, love.mouse:getX(), love.mouse:getY(), VELOCITY))
  elseif love.keyboard.isDown("b") then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  end
end

function love.mousepressed(x, y, button)
  if button == "l" then
    if cnt > 0 then
      table.insert(objTable, createMagnet(world, love.mouse:getX(), love.mouse:getY(), MAGNET_POWER, MAGNET_RADIUS))
      cnt = cnt - 1
    end
  elseif button == "m" and GAME_STATE == "static" then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) then
        i.fixture:destroy()
        i.body:destroy()
        cnt = cnt + 1
        table.remove(objTable, _)
      end
    end
  elseif button == "r" then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  end
end
