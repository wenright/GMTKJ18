local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.rigidbody'

local Debris = Class {__includes = Base}

function Debris:init(properties)
  properties.team = 'enemy'
  properties.drag = 0.7

  Base.init(self, properties)

  self.timer:after(1, function()
    Game:destroy(self)
  end)

  self.opacity = 1
  self.timer:tween(1, self, {opacity = 0}, 'in-quad')

  if love.math.random() > 0.5 then
    self.color = {r = 199/255, g = 214/255, b = 205/255}
  else
    self.color = {r = 124/255, g = 162/255, b = 152/255}
  end

  self.color = properties.color or self.color
end

function Debris:draw()
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.opacity)
  love.graphics.rectangle('fill', self.position.x, self.position.y, 1, 1)
end

return Debris
