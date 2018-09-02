local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Debris = require 'scripts.entities.debris'

local Base = require 'scripts.entities.entity'

local Explosion = Class {__includes = Base}

function Explosion:init(properties)
  Base.init(self, properties)

  local numParticles = properties.amount or 15
  for i=1, numParticles do
    local debris = Game:instantiate(Debris{x = self.position.x, y = self.position.y, color = properties.color})

    local force = 0.8
    debris.body:applyLinearImpulse((love.math.random() - 0.5) * force, (love.math.random() - 0.5) * force)
  end

  self.timer:after(2, function()
    Game:destroy(self)
  end)
end

return Explosion
