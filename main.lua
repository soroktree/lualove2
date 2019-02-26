Snake = {}
Snake.__index = Snake

function Snake:new()
  self = setmetatable({}, self)
  local head = {x = love.graphics.getWidth() / 2,
                y = love.graphics.getHeight() / 2}
  self.tail = {head}
  self.direction = {dx = 1, dy = 0}
  self.size = 20
  return self
end

function Snake:move(grow)
  local head = self.tail[1]
  local new_head = {x = head.x + self.direction.dx*self.size,
                    y = head.y + self.direction.dy*self.size}
  table.insert(self.tail, 1, new_head)
  if not grow then
    table.remove(self.tail)
  end
end


function Snake:draw()
  love.graphics.setColor(.44, .55, .66)
  for i, t in ipairs(self.tail) do
    love.graphics.rectangle('fill', t.x, t.y, self.size-1, self.size-1)
  end
end


Food = {}
Food.__index = Food

function Food:new()
  self = setmetatable({},self)
  self.size = 20
  self.x = love.math.random(love.graphics.getWidth()-self.size)
  self.y = love.math.random(love.graphics.getHeight()-self.size)
  self.color = {.88, .30, .30}
  return self
end

function Food:draw()
  local r,g,b = self.color
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end


function collision(a, b, size)
  local dx = a.x - b.x
  local dy = a.y - b.y
  return dx^2 + dy^2 < size^2
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

time = 0

function love.update(dt)
  time = time + dt
  if time < 0.08 then return end
  time = 0
  for key, dir in pairs(keys) do
    if love.keyboard.isDown(key) then
      snake.direction = dir
      break
    end
  end

  if collision(snake.tail[1], food, food.size) then
    food = Food:new()
    snake:move(true)
  else
    snake:move()
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
