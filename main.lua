local Snake = require("snake")
local Food = require("food")
local Brick = require("brick")


function collision(a, b, size)
  local dx = a.x - b.x
  local dy = a.y - b.y
  return dx^2 + dy^2 < size^2
end


function love.load()
  snake = Snake:new()
  objects = {snake, Food:new()}
  for i = 0, 10 do
    table.insert(objects, Brick:new{x = 100+i*20, y=200})
    table.insert(objects, Brick:new{x = 500+i*20, y=200})
    table.insert(objects, Brick:new{x = 300+i*20, y=300})
    table.insert(objects, Brick:new{x = 300+i*20, y=100})
  end
end


keys = {
  left  = {x = -1, y =  0},
  right = {x =  1, y =  0},
  up    = {x =  0, y = -1},
  down  = {x =  0, y =  1},
}

time = 0

function love.update(dt)
  time = time + dt
  if time < 0.08 then return end
  time = 0
  -- set snake direction
  for key, dir in pairs(keys) do
    if love.keyboard.isDown(key) then
      snake.direction = dir
      break
    end
  end

  can_move = true
  next_step = snake:next_step()
  -- check if we will collide with some object on the next step
  for i, obj in ipairs(objects) do
    if obj.__index == Food and collision(next_step, obj, obj.size) then
      objects[i] = Food:new()
      snake:grow(next_step)
      can_move = false
    elseif obj.__index == Brick and collision(next_step, obj, obj.size) then
      can_move = false
    end
  end

  if can_move then
    snake:move(next_step)
  end
end


function love.draw()
  for i, obj in ipairs(objects) do
    obj:draw()
  end
end


function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
