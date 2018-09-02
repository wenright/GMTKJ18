local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.ship'

local Player = Class {__includes = Base}

function Player:init(properties)
  properties.team = 'player'

  Base.init(self, properties)

  self.speed = 250000

  self.hp = 3
  self.shieldImg = love.graphics.newImage('art/shield.png')
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

  for i=0,self.hp - 1 do
    love.graphics.draw(self.shieldImg, i * self.shieldImg:getWidth())
  end
end

function Player:damage()
  self.hp = self.hp - 1

  if self.hp <= 0 then
    Game.over = true
    Game:destroy(self)
  end
end

return Player
