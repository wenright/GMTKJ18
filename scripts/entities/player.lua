local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.ship'

local Player = Class {__includes = Base}

function Player:init(properties)
  properties.team = 'friendly'

  Base.init(self, properties)

  self.speed = 250000
end

function Player:update(dt)
  Base.update(self, dt)

  local delta = Vector(0, 0)

  if love.keyboard.isDown('a', 'left') then
    delta.x = -1
  elseif love.keyboard.isDown('d', 'right') then
    delta.x = 1
  end

  if love.keyboard.isDown('w', 'up') then
    delta.y = -1
  elseif love.keyboard.isDown('s', 'down') then
    delta.y = 1
  end

  self.body:applyForce((delta:normalized() * self.speed * dt):unpack())
end

function Player:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Player
