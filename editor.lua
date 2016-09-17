binser = require "binser/binser"

function editor:enter() current_level = 1
  newgame()
end

function editor:update(dt)
  world:update(dt)
  
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
  love.graphics.print("Level: " .. tostring(current_level), 600, 40)
  for _, i in pairs(objTable) do
    drawObject(i)
  end
  
  if current then drawObject(current) end
  if ball then drawObject(ball) end
 
  local x, y = ball.body:getPosition()
  love.graphics.line(x, y, x+velocity[1], y + velocity[2])
end

function editor:keypressed(key, isrepeat)
  print('editor:keypressed', key, isrepeat)
  if key == "return" then
    local level_info = binser.serialize(current_level, cnt)
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
  elseif key == "space" then
    ball.body:setActive(true)
    ball.body:setLinearVelocity(velocity[1], velocity[2])
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
  elseif key == "[" then
    current_level = math.max(1, current_level-1)
  elseif key == "]" then
    current_level = current_level + 1
  end
end

function editor:mousepressed(x, y, button)
  print('Editor: mousepressed', x, y, button)
  if button == 1 and current then
    table.insert(objTable, current)
    print('New number of elements in objTable:', #objTable)
    current = nil
  elseif button == 3 then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) then
        i.fixture:destroy()
        i.body:destroy()
        table.remove(objTable, _)
      end
    end
  end
end
