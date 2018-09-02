local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Bullet = require 'scripts.entities.bullet'
local Explosion = require 'scripts.entities.explosion'
local Text = require 'scripts.entities.text'

local Base = require 'scripts.entities.ship'

local Enemy = Class {__includes = Base}

function Enemy:init(properties)
  properties.team = 'enemy'

  Base.init(self, properties)

  self.speed = 200

  self.img = love.graphics.newImage('art/enemy.png')

  self:loopFire()

  self.timer:after(5, function()
    Game:destroy(self)
  end)
end

function Enemy:update(dt)
  Base.update(self, dt)

  self.body:applyForce(0, self.speed)

  if self.body:enter('player') then
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, size = 6}))
    -- Game:instantiate(Text({x = self.position.x, y = self.position.y, text = '100'}))

    local sound = love.audio.newSource('sounds/hit.wav', 'static')
    sound:setVolume(0.6)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()

    local collision = self.body:getEnterCollisionData('player')
    local player = collision.collider:getObject()
    player:damage()
    Game:destroy(self)
  end

  if self.position.y > GAME_HEIGHT then
    Game:destroy(self)
  end
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

function Enemy:loopFire()
  self.timer:after(love.math.random() + 0.5, function()
    local bullet = Game:instantiate(Bullet {x = self.position.x, y = self.position.y})
    bullet.body:applyLinearImpulse(0, 1)

    self:loopFire()
  end)
end

return Enemy
