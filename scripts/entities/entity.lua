local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'
local Timer = require 'lib.hump.timer'

local Entity = Class {}

function Entity:init(properties)
  properties = properties or {}

	self.position = Vector(
		properties.x or 0,
		properties.y or 0
	)

  self.timer = Timer.new()
end

function Entity:update(dt)
  self.timer:update(dt)
end

return Entity
