lady = require 'lady/lady'
Gamestate = require 'hump.gamestate'
require "objects"
require "constants"
require "images"

--[[
--COMMON
--]]
function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)

  love.graphics.setNewFont(32)

  love.physics.setMeter(METER_SIZE)

  loadgame()
end

--[[
--MENU
--]]
function menu:draw()
    love.graphics.print("Press Enter to continue", 10, 10)
end

function menu:keypressed(key, isrepeat)
    if key == 'return' then
        Gamestate.switch(game)
    end
end

--[[
--GAME
--]]
function game:enter()
    loadgame()
end

function game:update(dt)
  if GAME_STATE == "dynamic" then
    world:update(dt)
  end
  
  -- FIXME delete or handle ball
  for _, obj in pairs(objTable) do
    x, y = obj.body:getPosition()
    if x > 1500 or x < -200 or y > 1000 or y < -200 then
      table.remove(objTable, _)
    end
  end
  
  useMagnets()
end

function game:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bgImg, 0, 0)
  love.graphics.printf(cnt, 50, 50, 50)
  for _, i in pairs(objTable) do
    drawObject(i)
  end
  if ball then drawObject(ball) end

  if GAME_STATE == "static" then
    local x, y = ball.body:getPosition()
    love.graphics.line(x, y, x+velocity[1], y + velocity[2])
  end

  if LEVEL == LASTLEVEL then
    Gamestate.switch(final)
  end
end

function game:keypressed(key, isrepeat)
  if key == "return" then
    Gamestate.switch(editor)
  elseif key == "r" then
    loadgame()
  elseif key == " " then
    if GAME_STATE == "static" then
      ball.body:setLinearVelocity(velocity[1], velocity[2])
      GAME_STATE = "dynamic"
    end
  elseif love.keyboard.isDown("b") then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  end
end

function game:mousepressed(x, y, button)
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

--[[
--EDITOR
--]]
function editor:enter()
  loadgame()
  current = createPlatform(world, 0, 0, 33, 33)
end

function editor:update(dt)
  if GAME_STATE == "dynamic" then
    world:update(dt)
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
  
  if love.keyboard.isDown("s") then
    velocity[1] = (love.mouse:getX()-640)
    velocity[2] = (love.mouse:getY()-360)
  end
  
  useMagnets()
end

function editor:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(bgImg, 0, 0)
  love.graphics.print(cnt, 50, 50)
  love.graphics.print("Editor", 600, 10)
  for _, i in pairs(objTable) do
    drawObject(i)
  end
  
  if current then drawObject(current) end
  if ball then drawObject(ball) end
 
  local x, y = ball.body:getPosition()
  love.graphics.line(x, y, x+velocity[1], y + velocity[2])
end

function editor:keypressed(key, isrepeat)
  if key == "return" then
    lady.save_all(LEVELS[LEVEL], world, objTable, ball, velocity, {cnt})
    Gamestate.switch(game)
  elseif key == "z" then
    ball.body:setX(love.mouse.getX())
    ball.body:setY(love.mouse.getY())
  elseif love.keyboard.isDown("b") then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  elseif key == " " then
    if GAME_STATE == "dynamic" then
      GAME_STATE = "static"
    else
      ball.body:setLinearVelocity(velocity[1], velocity[2])
      GAME_STATE = "dynamic"
    end
  elseif key >= "1" and key <= "9" then
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    if current then current.fixture:destroy(); current.body:destroy() end
    if key == "1" then
      current = createPlatform(world, x, y, 33, 33)
    elseif key == "2" then
      current = createMagnet(world, x, y, 0.8, 33)
    elseif key == "3" then
      current = createTrap(world, x, y, 33, 33)
    elseif key == "4" then
      current = createFinish(world, x, y)
    else
      current = nil
    end
  elseif key == "kp+" then
    cnt = cnt + 1
  elseif key == "kp-" then
    cnt = math.max(0, cnt - 1)
  end
end

function editor:mousepressed(x, y, button)
  if button == "l" and current then
    table.insert(objTable, current)
    current = nil
  elseif button == "m" then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) then
        i.fixture:destroy()
        i.body:destroy()
        table.remove(objTable, _)
      end
    end
  end
end

--[[
--FINAL
--]]
function final:draw()
  width, height = love.window.getMode( )
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 0, 0, width, height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("The End!", width/2-80, height/2-20)
end

--[[
--OTHER
--]]
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

function useMagnets() 
  for a, b in pairs(objTable) do
    if b.fixture:getUserData() == "magnet" then
      xb, yb = ball.body:getPosition()
      xm, ym = b.body:getPosition()
      dx = xb-xm
      dy = yb-ym
      dist = math.sqrt(dy*dy+dx*dx)
      if dist > 210 then dist = dist+math.pow((dist-210), 2) end
      ad = 100000/dist
      atan2 = math.atan2(dy, dx)
      ball.body:applyForce(BALLP*ad*b.power*math.cos(atan2), BALLP*ad*b.power*math.sin(atan2))
    end
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

function loadgame()
  world, objTable, ball, velocity, cnt = lady.load_all(LEVELS[LEVEL])
  if not world then
    world = love.physics.newWorld(GRAVITYX, GRAVITYY*METER_SIZE, true)
    objTable = {}
    velocity = {0, 0}
    ball = createBall(world, 100, 100, {0, 0})
    cnt = 10
  else
    cnt = cnt[1]
  end

  GAME_STATE = "static"
  
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end
