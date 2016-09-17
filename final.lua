function final:draw()
  width, height = love.window.getMode( )
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 0, 0, width, height)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("The End!", width/2-80, height/2-20)
end
