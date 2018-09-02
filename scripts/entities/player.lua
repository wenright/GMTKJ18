local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

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
  -- for k, pos in pairs(self.lastPositions) do
  --   love.graphics.setColor(1, 1, 1, 0.4)
  --   love.graphics.draw(self.img, pos.x, pos.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
  -- end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

function Player:damage()
  self.hp = self.hp - 1

  if self.hp <= 0 then
    Game.over = true
    Game:destroy(self)
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

  self.timer:after(self.invincibleTime, function()
    self.invincible = false
    self:startShieldCharge()
  end)
end

return Player
