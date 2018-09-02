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

  Game:shakeScreen()

  Game.hitstop = true
  Game.timer:after(0.1, function()
    Game.hitstop = false
  end)
  Game.bg = Game.hitBg
  Game.timer:after(0.05, function()
    Game.bg = Game.defaultBg
  end)
end

return Explosion
