local Physics = require 'lib.windfield.windfield'
local Camera = require 'lib.hump.camera'

local EntitySystem = require 'scripts.entitysystem'

local Player = require 'scripts.entities.player'

local Game = {}

function Game:init()
  print('Loading Gamestate \'Game\'')
  self.entities = EntitySystem()

  self.world = Physics.newWorld(0, 0, true)
  self.world:addCollisionClass('friendly', {ignores = {'friendly'}})
  self.world:addCollisionClass('enemy', {ignores = {'enemy'}})

  local player = self:instantiate(Player({x = 50, y = 50}))

  self.camera = Camera()
  self.canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

  love.graphics.setBackgroundColor(0.13, 0.13, 0.13, 1)
end

function Game:enter()
  print('Entering Gamestate \'Game\'')
end

function Game:update(dt)
  self.world:update(dt)
  self.entities:loop('update', dt)
end

function Game:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  self.camera:attach()

  self.entities:loop('draw')

  if DEBUG then self.world:draw() end

  self.camera:detach()

  love.graphics.setCanvas()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw(self.canvas, 0, 0, 0, SCALE_X, SCALE_Y)
  love.graphics.setBlendMode('alpha')
end

function Game:instantiate(obj)
  obj.game = self
  return self.entities:add(obj)
end

function Game:destroy(obj)
  self.entities:remove(obj)
  obj:destroy()
end

return Game
