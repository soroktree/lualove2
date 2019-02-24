Snake = {}
Snake.__index = Snake

function Snake:new()
  self = setmetatable({}, self)
  self.x = love.graphics.getWidth() / 2
  self.y = love.graphics.getHeight() / 2
  self.tail = {}
  self.size = 20
  return self
end

function Snake:grow(dir)
  table.insert(self.tail, 1, {x = self.x, y = self.y})
end


function Snake:draw()
  love.graphics.setColor(.44, .55, .66)
  love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
  for i, t in ipairs(self.tail) do
    love.graphics.rectangle('fill', t.x, t.y, self.size, self.size)
  end
end


Food = {}
Food.__index = Food

function Food:new()
  self = setmetatable({},self)
  self.x = love.math.random(love.graphics.getWidth())
  self.y = love.math.random(love.graphics.getHeight())
  self.size = 20
  self.color = {.88, .30, .30}
  return self
end

function Food:draw()
  local r,g,b = self.color
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

function love.load()
  snake = Snake:new()
  food = Food:new()
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

  local dx = (snake.x - food.x)
  local dy = (snake.y - food.y)

  if dx^2 + dy^2 < snake.size^2 then
    food.color = {.20,.88,.10}
end

    
end


function love.draw()
  snake:draw()
  food:draw()
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
