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
  self.r = 0
  self.t = love.math.random() * math.pi * 2
  self.s = love.math.random() / 2 + 1
  self.ROF = properties.ROF

  self.img = love.graphics.newImage('art/enemy.png')

  self:loopFire()
end

function Enemy:update(dt)
  Base.update(self, dt)

  self.t = self.t + dt * self.s

  local vx, vy = self.body:getLinearVelocity()
  self.r = math.atan2(vy, vx) - math.pi / 2

  local v = Game.player.position - self.position
  if Game.player.invincible and v:len() < 95 then
    self.body:applyForce((v:normalized() * -self.speed / 2):unpack())
  elseif self.t < 7 then
    self.body:applyForce((v:normalized() * self.speed):unpack())
  else
    self.body:applyForce(self.speed * math.cos(self.t * 2), self.speed)
  end

  if self.body:enter('player') then
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, size = 6}))

    local sound = love.audio.newSource('sounds/hit.wav', 'static')
    sound:setVolume(0.6)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()

    local collision = self.body:getEnterCollisionData('player')
    local player = collision.collider:getObject()

    local wasInvincible = player:damage()
    if wasInvincible then
      local score = 5 * player.combo
      player.combo = player.combo + 1
      Game:instantiate(Text({x = self.position.x, y = self.position.y, text = '' .. score}))
      player.score = player.score + score

      if player.hp < player.maxHp then
        player.hp = player.hp + 1
      end
    end

    Game:destroy(self)
  end

  if self.position.y > GAME_HEIGHT then
    Game:destroy(self)
  end
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, self.r, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

function Enemy:loopFire()
  local speed = 0.75

  self.timer:after(love.math.random() / 2 + self.ROF, function()
    local bullet = Game:instantiate(Bullet {x = self.position.x, y = self.position.y})
    local v = Game.player.position - self.position
    bullet.body:applyLinearImpulse((v:normalized() * speed):unpack())

    self:loopFire()
  end)
end

return Enemy
