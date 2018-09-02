local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Explosion = require 'scripts.entities.explosion'

local Base = require 'scripts.entities.ship'

local Player = Class {__includes = Base}

function Player:init(properties)
  properties.team = 'player'

  Base.init(self, properties)

  self.speed = 250000

  self.hp = 3
  self.chargeTime = 5
  self.shieldReady = false
  self.shieldPercentage = 0
  self.invincibleTime = 3
  self.hideShield = false

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

  if love.keyboard.isDown('space') then
    self:useShield()
  end

  self.body:applyForce((delta:normalized() * self.speed * dt):unpack())
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
end

function Player:damage()
  if self.invincible then return end

  self.hp = self.hp - 1

  if self.hp <= 0 then
    Game.over = true
    Game:destroy(self)
    Game:instantiate(Explosion({x = self.position.x, y = self.position.y}))
  end
end

function Player:startShieldCharge()
  self.timer:tween(self.chargeTime, self, {shieldPercentage = 1}, 'linear', function()
    self.shieldReady = true
  end)
end

function Player:useShield()
  if not self.shieldReady then return end

  self.shieldPercentage = 0

  self.shieldReady = false
  self.invincible = true
  self.hideShield = false

  local flashTimer = nil
  self.timer:after(self.invincibleTime - 0.75, function()
    self.hideShield = true
    flashTimer = self.timer:every(0.075, function()
      self.hideShield = not self.hideShield
    end)
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
