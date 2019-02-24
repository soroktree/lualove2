function love.init()
end

function love.update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  print(key)
end
