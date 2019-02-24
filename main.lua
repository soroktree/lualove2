Snake = {}
Snake.__index = Snake

function Snake:new()
  self = setmetatable({}, self)
  local head = {x = love.graphics.getWidth() / 2,
                y = love.graphics.getHeight() / 2}
  self.tail = {head}
  self.size = 20
  return self
end

function Snake:grow(dir)
  local head = self.tail[1]
  local new_head = {x = head.x + dir.dx*self.size, y = head.y + dir.dy*self.size}
  table.insert(self.tail, 1, new_head)
end


function Snake:move(dir)
  local head = self.tail[1]
  local new_head = {x = head.x + dir.dx*self.size, y = head.y + dir.dy*self.size}
  table.insert(self.tail, 1, new_head)
  table.remove(self.tail)
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
  if time < 0.02 then return end
  time = 0
  for key, dir in pairs(keys) do
    if love.keyboard.isDown(key) then
      snake:move(dir)
      direction = dir
      break
    end
  end

  local dx = (snake.tail[1].x - food.x)
  local dy = (snake.tail[1].y - food.y)

  if dx^2 + dy^2 < snake.size^2 then
    food = Food:new()
    snake:grow(direction)
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
