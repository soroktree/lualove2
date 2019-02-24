Snake = {}

function Snake:new()
  o = {}
  o.x = love.graphics.getWidth() / 2
  o.y = love.graphics.getHeight() / 2
  o.size = 20
  self.__index = self
  return setmetatable(o, self)
end

function Snake:draw()
  love.graphics.setColor(.44, .55, .66)
  love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end


function love.load()
  snake = Snake:new()
end


keys = {
  left = {dx = -1, dy = 0},
  right = {dx = 1, dy = 0},
  up = {dx = 0, dy = -1},
  down = {dx = 0, dy = 1},
}

function love.update(dt)
  for key, dir in pairs(keys) do
    if love.keyboard.isDown(key) then
      snake.x = snake.x + 100*dir.dx*dt
      snake.y = snake.y + 100*dir.dy*dt
    end
  end
end


function love.draw()
  snake:draw()
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
