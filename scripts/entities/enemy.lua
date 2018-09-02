local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Bullet = require 'scripts.entities.bullet'

local Base = require 'scripts.entities.ship'

local Enemy = Class {__includes = Base}

function Enemy:init(properties)
  properties.team = 'enemy'

  Base.init(self, properties)

  self.speed = 250000

  self.img = love.graphics.newImage('art/enemy.png')

  self.timer:every(1, function()
    local bullet = Game:instantiate(Bullet {x = self.position.x, y = self.position.y})
    bullet.body:applyLinearImpulse(0, 1)
  end)
end

function Enemy:update(dt)
  Base.update(self, dt)
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Enemy
