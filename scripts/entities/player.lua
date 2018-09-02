local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Explosion = require 'scripts.entities.explosion'

local Base = require 'scripts.entities.ship'

local Player = Class {__includes = Base}

function Player:init(properties)
  properties.team = 'player'

  Base.init(self, properties)

  self.speed = 500

  self.maxHp = 2
  self.hp = 3
  self.chargeTime = 5
  self.shieldReady = false
  self.shieldPercentage = 0
  self.invincibleTime = 3
  self.hideShield = false
  self.score = 0

  self:startShieldCharge()

  local ghostSize = 3
  self.lastPositions = {}
  for i=1, ghostSize do
    table.insert(self.lastPositions, self.position:clone())
  end

  self.timer:every(0.05, function()
    table.remove(self.lastPositions, 1)
    table.insert(self.lastPositions, self.position:clone())
  end)

  self.bubbleImg = love.graphics.newImage('art/bubble.png')
  self.shieldImg = love.graphics.newImage('art/shield.png')
  self.emptyShieldImg = love.graphics.newImage('art/empty_shield.png')
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

  self.body:applyForce((delta:normalized() * self.speed):unpack())

  if love.keyboard.isDown('space') then
    self:useShield()
  end
end

function Player:draw()
  for k, pos in pairs(self.lastPositions) do
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.draw(self.img, pos.x, pos.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)

  if self.invincible and not self.hideShield then
    love.graphics.draw(self.bubbleImg, self.position.x, self.position.y, 0, 1, 1, self.bubbleImg:getWidth() / 2, self.bubbleImg:getHeight() / 2)
  end

  -- Health
  for i=0, self.hp - 1 do
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.shieldImg, i * self.shieldImg:getWidth() * 3 / 4)
  end

  for i=self.hp, self.maxHp - 1 do
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.emptyShieldImg, i * self.emptyShieldImg:getWidth() * 3 / 4)
  end

  -- Shield charge value
  love.graphics.setColor(199/255, 214/255, 205/255, 1)
  love.graphics.arc('fill', GAME_WIDTH / 2, GAME_HEIGHT - 5, 5, -math.pi / 2, (math.pi * 2) * self.shieldPercentage - math.pi / 2)
end

function Player:damage()
  if self.invincible then
    local sound = love.audio.newSource('sounds/shield_hit.wav', 'static')
    sound:setVolume(0.75)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()

    return true
  end

  self.hp = self.hp - 1

  if self.hp <= 0 then
    Game.over = true
    Game:destroy(self)
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y, size = 8}))

    local sound = love.audio.newSource('sounds/explosion.wav', 'static')
    sound:setVolume(0.75)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()
  end

  return false
end

function Player:startShieldCharge()
  self.timer:tween(self.chargeTime, self, {shieldPercentage = 1}, 'linear', function()
    self.shieldReady = true

    local sound = love.audio.newSource('sounds/bloop.wav', 'static')
    sound:setVolume(0.75)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()
  end)
end

function Player:useShield()
  if not self.shieldReady then return end

  self.shieldPercentage = 0

  self.shieldReady = false
  self.invincible = true
  self.hideShield = false

  self.combo = 1

  do
    local sound = love.audio.newSource('sounds/powerup.wav', 'static')
    sound:setVolume(0.75)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()
  end

  local flashTimer = nil
  self.timer:after(self.invincibleTime - 0.5, function()
    self.hideShield = true
    flashTimer = self.timer:every(0.075, function()
      self.hideShield = not self.hideShield
    end)

    local sound = love.audio.newSource('sounds/shield_low.wav', 'static')
    sound:setVolume(0.75)
    sound:setPitch((love.math.random() - 0.5) * 0.1 + 1)
    sound:play()
  end)

  self.timer:after(self.invincibleTime, function()
    self.invincible = false
    self:startShieldCharge()
    self.timer:cancel(flashTimer)
  end)

  self.bubbleOpacity = 1
  self.timer:tween(self.invincibleTime, self, {bubbleOpacity = 0}, 'in-bounce')
end

return Player
