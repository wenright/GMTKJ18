local Physics = require 'lib.windfield.windfield'
local Camera = require 'lib.hump.camera'

local EntitySystem = require 'scripts.entitysystem'

local Player = require 'scripts.entities.player'
local Enemy = require 'scripts.entities.enemy'

local Game = {}

function Game:init()
  print('Loading Gamestate \'Game\'')
  self.entities = EntitySystem()

  self.world = Physics.newWorld(0, 0, true)
  self.world:addCollisionClass('player', {ignores = {'player'}})
  self.world:addCollisionClass('enemy', {ignores = {'enemy'}})

  self.player = self:instantiate(Player {x = 50, y = 50})
  local enemy = self:instantiate(Enemy {x = 50, y = 0})

  self.camera = Camera()
  self.canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

  love.graphics.setBackgroundColor(0.13, 0.13, 0.13, 1)

  self.shieldImg = love.graphics.newImage('art/shield.png')
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

  -- This stuff is for the UI, probably should be moved to a UI class

  -- Game over
  if self.over then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Game over!', 0, GAME_HEIGHT / 2 - 10, 100, 'center')
  end

  -- Player health
  for i=0, self.player.hp - 1 do
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.shieldImg, i * self.shieldImg:getWidth() * 3 / 4)
  end

  -- Player shield charge value
  love.graphics.setColor(199/255, 214/255, 205/255, 1)
  love.graphics.arc('fill', GAME_WIDTH / 2, GAME_HEIGHT - 5, 5, -math.pi / 2, (math.pi * 2) * self.player.shieldPercentage - math.pi / 2)


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
