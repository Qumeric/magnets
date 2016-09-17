function game:enter()
    newgame()
end

function game:update(dt)
    world:update(dt)
  
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

  if not ball.body:isActive() then
    local x, y = ball.body:getPosition()
    love.graphics.line(x, y, x+velocity[1], y + velocity[2])
  end

  if LEVEL == LASTLEVEL then
    Gamestate.switch(final)
  end
end

function game:keypressed(key, isrepeat)
  print('game:keypressed', key, isrepeat)
  if key == "return" then
    Gamestate.switch(editor)
  elseif key == "r" then
    newgame()
  elseif key == "space" and not ball.body:isActive() then
    ball.body:setActive(true)
    ball.body:setLinearVelocity(velocity[1], velocity[2])
  end
end

function game:mousepressed(x, y, button)
  print('game:mousepressed', x, y, button)
  if button == 1 then
    if cnt > 0 then
      table.insert(objTable, createMagnet(world, love.mouse:getX(), love.mouse:getY(), MAGNET_POWER, MAGNET_RADIUS))
      cnt = cnt - 1
    end
  elseif button == 3 and not ball.body:isActive() then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) then
        i.fixture:destroy()
        i.body:destroy()
        cnt = cnt + 1
        table.remove(objTable, _)
      end
    end
  elseif button == 2 then
    for _, i in pairs(objTable) do
      if i.fixture:testPoint(love.mouse:getX(), love.mouse:getY()) and i.fixture:getUserData() == "magnet" then
        i.power = -i.power
      end
    end
  end
end
