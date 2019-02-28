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

return Brick
