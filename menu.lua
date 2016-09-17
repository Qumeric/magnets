function menu:draw()
    love.graphics.print("Press Enter to continue", 10, 10)
end

function menu:keypressed(key, isrepeat)
    if key == 'return' then
        Gamestate.switch(game)
    end
end
