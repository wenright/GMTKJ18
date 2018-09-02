local Gamestate = require 'lib.hump.gamestate'
local Timer = require 'lib.hump.timer'
local Lovebird = require 'lib.lovebird.lovebird'

-- Maybe don't use a global?
Game = require 'scripts.states.game'

local mainTimer
local memoryUsage = 0

DEBUG = false

function love.load()
  print('Love initialized!')

  mainTimer = Timer.new()
  mainTimer:every(1, function()
    memoryUsage = math.floor(collectgarbage('count'))
  end)

  love.graphics.setDefaultFilter('nearest', 'nearest')

  Gamestate.registerEvents()
  Gamestate.switch(Game)
end

function love.update(dt)
  mainTimer:update(dt)

  if DEBUG then Lovebird.update(dt) end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(love.timer.getFPS() .. ' FPS')
  love.graphics.print(memoryUsage .. ' KB', 0, 20)
end

function love.keypressed(button)
  if button == 'escape' then
    love.event.quit()
  end
end
