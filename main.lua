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
  love.graphics.setNewFont('art/fonts/kenney_future.ttf')

  Gamestate.registerEvents()
  Gamestate.switch(Game)
end

function love.update(dt)
  mainTimer:update(dt)

  if DEBUG then Lovebird.update(dt) end
end

function love.draw()
  if DEBUG then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS() .. ' FPS', love.graphics.getWidth() - 60)
    love.graphics.print(memoryUsage .. ' KB', love.graphics.getWidth() - 60, 20)
  end
end

function love.keypressed(button)
  if button == 'escape' then
    love.event.quit()
  end
end
