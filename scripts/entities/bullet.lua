local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.rigidbody'

local Bullet = Class {__includes = Base}

function Bullet:init(properties)
  properties.team = 'enemy'
  properties.drag = 0

  Base.init(self, properties)

  self.speed = 250000

  self.img = love.graphics.newImage('art/bullet.png')
end

function Bullet:update(dt)
  Base.update(self, dt)
end

function Bullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Bullet
