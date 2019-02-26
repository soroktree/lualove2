Snake = {}
Snake.__index = Snake

function Snake:new()
  self = setmetatable({}, self)
  local head = {x = 0, y = 0}
  self.tail = {head}
  self.direction = {dx = 1, dy = 0}
  self.size = 20
  return self
end

function Snake:next_step()
  local head = self.tail[1]
  return {x = head.x + self.direction.dx*self.size,
          y = head.y + self.direction.dy*self.size}
end

function Snake:move(next_step)
  table.insert(self.tail, 1, next_step)
  table.remove(self.tail)
end

function Snake:grow(next_step)
  table.insert(self.tail, 1, next_step)
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
  return self
end

function Food:draw()
  love.graphics.setColor(.88, .30, .30)
  love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

Brick = {}
Brick.__index = Brick

function Brick:new(xy)
  self = setmetatable(xy, self)
  self.size = 20
  return self
end

function Brick:draw()
  love.graphics.setColor(.77, .77, .77)
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
  walls = {}
  for i = 0, 10 do
    table.insert(walls, Brick:new{x = 100+i*20, y=200})
    table.insert(walls, Brick:new{x = 500+i*20, y=200})
    table.insert(walls, Brick:new{x = 300+i*20, y=300})
    table.insert(walls, Brick:new{x = 300+i*20, y=100})
  end
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

  next_step = snake:next_step()
  can_move = true
  if collision(next_step, food, food.size) then
    food = Food:new()
    snake:grow(next_step)
    can_move = false
  end

  for i, b in ipairs(walls) do
    if collision(next_step, b, b.size) then
      can_move = false
      break
    end
  end

  if can_move then
    snake:move(next_step)
  end
end


function love.draw()
  snake:draw()
  food:draw()
  for i, b in ipairs(walls) do
    b:draw()
  end
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
