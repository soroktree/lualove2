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

return Food
