Gamestate = require 'hump.gamestate'
require "objects"
require "constants"
require "images"

--[[Gamestates]]--
require "menu"
require "game"
require "editor"
require "final"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)

  love.graphics.setNewFont(32)

  love.physics.setMeter(METER_SIZE)

  newgame()
end

function beginContact(a, b, coll)
  ad = a:getUserData()
  bd = b:getUserData()

  if (ad == "ball" and bd == "finish") or (ad == "finish" and bd == "ball") then
    clear()
    LEVEL = LEVEL + 1
    newgame()
  elseif (ad == "ball" and bd == "trap") or (ad == "trap" and bd == "ball") then
    clear()
    newgame()
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

function newgame()
  world = love.physics.newWorld(GRAVITYX, GRAVITYY*METER_SIZE, true)
  objTable = {}
  velocity = {0, 0}
  ball = createBall(world, 100, 100, {0, 0})
  cnt = 10
  ball.body:setActive(false)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end
