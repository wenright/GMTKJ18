local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Explosion = require 'scripts.entities.explosion'
local Text = require 'scripts.entities.text'

local Base = require 'scripts.entities.rigidbody'

local Bullet = Class {__includes = Base}

function Bullet:init(properties)
  properties.team = 'enemy'
  properties.drag = 0

  Base.init(self, properties)

  self.r = 0
  self.t = 0

  self.img = love.graphics.newImage('art/bullet.png')

  self.timer:after(5, function()
    Game:destroy(self)
  end)

  local sound = love.audio.newSource('sounds/laser2.wav', 'static')
  sound:setVolume(0.6)
  sound:setPitch((love.math.random() - 0.5) * 0.3 + 1)
  sound:play()
end

function Bullet:update(dt)
  Base.update(self, dt)

  self.t = self.t + dt

  local vx, vy = self.body:getLinearVelocity()
  self.r = math.atan2(vy, vx) - math.pi / 2

  if self.body:enter('player') then
    -- Dont do damage if too close to player
    if self.t < 0.075 then
      Game:destroy(self)
      return
    end

    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, amount = 3, color = {250/255, 221/255, 215/255}, stop = false}))
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, amount = 6, size = 2, stop = false}))

    local sound = love.audio.newSource('sounds/laser_hit.wav', 'static')
    sound:setVolume(0.4)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()

    local collision = self.body:getEnterCollisionData('player')
    local player = collision.collider:getObject()

    local wasInvincible = player:damage()
    if wasInvincible then
      local score = 1 * player.combo
      player.combo = player.combo + 1
      Game:instantiate(Text({x = self.position.x, y = self.position.y, text = '' .. score}))
      player.score = player.score + score
    end

    Game:destroy(self)
  end

  if self.position.y > GAME_HEIGHT then
    Game:destroy(self)
  end
end

function Bullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, self.r, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Bullet
