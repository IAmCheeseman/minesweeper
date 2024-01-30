---@diagnostic disable: duplicate-set-field
love.window.setTitle("Minesweeper")

love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
love.graphics.setDefaultFilter("nearest", "nearest")

cellWidth = 16
cellHeight = 16

local font = love.graphics.newFont(48)
love.graphics.setFont(font)

local mainMenu = require("mainmenu")
local Game = require("game")

gameState = "config"

-- Game state
-- Game loop

current = nil

local function playingOnKeyPressed(key)
  if key == "r" then
    current = Game(current.gridWidth, current.gridHeight, current.mineCount)
    gameState = "playing"
  end

  if key == "c" then
    cheating = not cheating
  end

  if key == "return" then
    gameState = "config"
    mainMenu.resetConfig()
  end
end

local gameStateCallbacks = {
  config = mainMenu,
  playing = {
    keypressed = playingOnKeyPressed,
    mousereleased = function(...)
      current:mousereleased(...)
    end,
    wheelmoved = function(_, y)
      current.zoom = current.zoom + y * 0.5
      if current.zoom > 5 then
        current.zoom = 5
      elseif current.zoom < 1 then
        current.zoom = 1
      end
    end,
    mousemoved = function(_, _, relx, rely)
      if love.mouse.isDown(1) then
        current.camerax = current.camerax - relx / current.zoom
        current.cameray = current.cameray - rely / current.zoom
        current.isPanning = true
      end
    end,
    update = function(dt)
      current:update(dt)
    end,
    draw = function()
      current:draw()
    end,
  },
  finish = {
    keypressed = playingOnKeyPressed,
    draw = function()
      current:draw()
    end,
  }
}

local function callCallback(name, ...)
  local fn = gameStateCallbacks[gameState][name]
  if fn then
    fn(...)
  end
end

function love.textinput(...)
  callCallback("textinput", ...)
end

function love.keypressed(...)
  callCallback("keypressed", ...)
end

function love.mousepressed(...)
  callCallback("mousepressed", ...)
end

function love.mousereleased(...)
  callCallback("mousereleased", ...)
end

function love.mousemoved(...)
  callCallback("mousemoved", ...)
end

function love.wheelmoved(...)
  callCallback("wheelmoved", ...)
end

function love.update(dt)
  callCallback("update", dt)
  if current then
    love.window.setTitle(
      ("Minesweeper - %dx%d - %d/%d"):format(
        current.gridWidth, current.gridHeight,
        current.flagCount, current.mineCount))
  end
end

function love.draw()
  callCallback("draw")
end
