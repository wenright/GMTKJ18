local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Base = require 'scripts.entities.entity'

local Rigidbody = Class {__includes = Base}

function Rigidbody:init(properties)
  Base.init(self, properties)

  self.r = properties.r or 1

  self.drag = properties.drag or 25

  self.team = properties.team or 'enemy'

  self.body = Game.world:newCircleCollider(self.position.x, self.position.y, self.r)
  self.body:setLinearDamping(self.drag)
  self.body:setCollisionClass(self.team)
  self.body:setObject(self)
end

function Rigidbody:update(dt)
  Base.update(self, dt)

  local x, y = self.body:getPosition()
  self.position = Vector(x, y)
end

function Rigidbody:addForce(fx, fy)
	assert(fx and fy, 'Invalid parameters to function addForce')

  self.body:applyLinearImpulse(fx, fy)
end

function Rigidbody:destroy()
  self.body:destroy()
end

return Rigidbody
