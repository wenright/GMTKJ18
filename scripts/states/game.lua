local Physics = require 'lib.windfield.windfield'
local Camera = require 'lib.hump.camera'
local Timer = require 'lib.hump.timer'
local Vector = require 'lib.hump.vector'

local EntitySystem = require 'scripts.entitysystem'

local Player = require 'scripts.entities.player'
local Enemy = require 'scripts.entities.enemy'

local Game = {}

-- RED: r = 218/255, g = 100/255, b = 115/255
-- whiteish: r = 250/255, g = 221/255, b = 215/255

function Game:init()
  print('Loading Gamestate \'Game\'')
  self.entities = EntitySystem()

  self.world = Physics.newWorld(0, 0, true)
  self.world:addCollisionClass('player', {ignores = {'player'}})
  self.world:addCollisionClass('enemy', {ignores = {'enemy'}})

  self.player = self:instantiate(Player {x = 50, y = 50})

  self.timer = Timer.new()
  self.timer:every(2, function()
    local x = love.math.random() * GAME_WIDTH
    local enemy = self:instantiate(Enemy {x = x, y = 0})
  end)

  self.camera = Camera()
  self.cameraStart = Vector(self.camera.x, self.camera.y)
  self.canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

  love.graphics.setBackgroundColor(0.13, 0.13, 0.13, 1)

  self.shieldImg = love.graphics.newImage('art/shield.png')
end

function Game:enter()
  print('Entering Gamestate \'Game\'')
end

function Game:update(dt)
  self.timer:update(dt)
  self.world:update(dt)
  self.entities:loop('update', dt)
end

function Game:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  self.camera:attach()

  self.entities:loop('draw')

  if DEBUG then self.world:draw() end

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
  self.timer:after(0, function()
    self.entities:remove(obj)
    obj:destroy()
  end)
end

function Game:shakeScreen()
  local intensity = 2.3

  local shakeTimer = self.timer:every(0.06, function()
    self.camera.x = self.cameraStart.x + (love.math.random() - 0.5) * intensity
    self.camera.y = self.cameraStart.y + (love.math.random() - 0.5) * intensity
  end)

  self.timer:after(0.4, function()
    self.timer:cancel(shakeTimer)
    self.camera.x, self.camera.y = self.cameraStart:unpack()
  end)
end

return Game
