local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Explosion = require 'scripts.entities.explosion'

local Base = require 'scripts.entities.rigidbody'

local Bullet = Class {__includes = Base}

function Bullet:init(properties)
  properties.team = 'enemy'
  properties.drag = 0

  Base.init(self, properties)

  self.speed = 250000

  self.img = love.graphics.newImage('art/bullet.png')

  self.timer:after(1, function()
    Game:destroy(self)
  end)
end

function Bullet:update(dt)
  Base.update(self, dt)

  if self.body:enter('player') then
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, amount = 3, color = {r = 250/255, g = 221/255, b = 215/255}}))
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, amount = 6}))

    local collision = self.body:getEnterCollisionData('player')
    local player = collision.collider:getObject()
    player:damage()
    Game:destroy(self)
  end
end

function Bullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Bullet
