local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.rigidbody'

local Ship = Class {__includes = Base}

function Ship:init(properties)
	properties.r = 5

  Base.init(self, properties)

  self.img = love.graphics.newImage('art/ship.png')
end


function Ship:update(dt)
  Base.update(self, dt)
end

function Ship:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, self.position.x, self.position.y, 0, 1, 1, self.img:getWidth() / 2, self.img:getHeight() / 2)
end

return Ship
