Snake = {}
Snake.__index = Snake

function Snake:new()
  self = setmetatable({}, self)
  local head = {x = 0, y = 0}
  self.tail = {head}
  self.direction = {x = 1, y = 0}
  self.size = 20
  return self
end

function Snake:next_step()
  local head = self.tail[1]
  return {x = head.x + self.direction.x * self.size,
          y = head.y + self.direction.y * self.size}
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

return Snake
