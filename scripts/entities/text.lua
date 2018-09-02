local Class = require 'lib.hump.class'
local Vector = require 'lib.hump.vector'

local Debris = require 'scripts.entities.debris'

local Base = require 'scripts.entities.entity'

local Text = Class {__includes = Base}

function Text:init(properties)
  Base.init(self, properties)

  self.timer:after(1, function()
    Game:destroy(self)
  end)

  self.text = properties.text or ''
end

function Text:draw()
  love.graphics.setColor(250/255, 221/255, 215/255)
  love.graphics.print(self.text, self.position.x, self.position.y)
end

return Text
