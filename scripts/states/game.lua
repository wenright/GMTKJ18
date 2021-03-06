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
  self.hitstop = false

  self.entities = EntitySystem()

  self.world = Physics.newWorld(0, 0, true)
  self.world:addCollisionClass('player', {ignores = {'player'}})
  self.world:addCollisionClass('enemy', {ignores = {'enemy'}})

  self.player = self:instantiate(Player {x = GAME_WIDTH/2, y = GAME_HEIGHT/2})

  self.timer = Timer.new()

  self.numEnemies = 2
  self.timer:every(6, function()
    self:spawnEnemies()
  end)

  self:spawnEnemies()

  self.camera = Camera()
  self.cameraStart = Vector(self.camera.x, self.camera.y)
  self.canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)

  self.over = false

  self.defaultBg = {0.13, 0.13, 0.13, 1}
  self.hitBg = {0.18, 0.18, 0.18, 1}
  self.bg = {0.13, 0.13, 0.13, 1}

  -- Walls for player collision
  local wallLeft = self.world:newRectangleCollider(-20, 0, 20, GAME_HEIGHT)
  wallLeft:setType('static')
  wallLeft:setCollisionClass('enemy')

  local wallRight = self.world:newRectangleCollider(GAME_WIDTH, 0, 20, GAME_HEIGHT)
  wallRight:setType('static')
  wallRight:setCollisionClass('enemy')

  local wallUp = self.world:newRectangleCollider(0, -20, GAME_WIDTH, 20)
  wallUp:setType('static')
  wallUp:setCollisionClass('enemy')

  local wallDown = self.world:newRectangleCollider(0, GAME_HEIGHT, GAME_WIDTH, 20)
  wallDown:setType('static')
  wallDown:setCollisionClass('enemy')
end

function Game:enter()
  print('Entering Gamestate \'Game\'')
end

function Game:update(dt)
  self.timer:update(dt)

  if self.hitstop then return end

  self.world:update(dt)
  self.entities:loop('update', dt)

  -- The r looks like an a w/ this font
  if self.over and love.keyboard.isDown('r', 'a') then
    self:init()
  end
end

function Game:draw()
  love.graphics.setBackgroundColor(self.bg)

  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()

  self.camera:attach()

  self.entities:loop('draw')

  if DEBUG then self.world:draw() end

  -- Game over
  if self.over then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Game over!', 0, GAME_HEIGHT / 2 - 10, GAME_WIDTH, 'center')
    love.graphics.printf('r to retry', 0, GAME_HEIGHT / 2 + 10, GAME_WIDTH, 'center')
  end

  love.graphics.print(self.player.score, 0, GAME_HEIGHT - 12)

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

function Game:spawnEnemies()
  for i=1, self.numEnemies do
    self.timer:after(love.math.random() * 2 + 1, function()
      local x = love.math.random() * (GAME_WIDTH - 20) + 10
      local enemy = self:instantiate(Enemy {x = x, y = 0, ROF = 0.4 - self.numEnemies / 50})
    end)
  end

  self.numEnemies = math.max(self.numEnemies + math.max(math.floor((love.math.random() - 0.25) * 2.5), -1), 1)

  if self.player.maxHp < self.player.maxMaxHp then
    self.player.maxHp = self.player.maxHp + 1
  end
end

return Game
