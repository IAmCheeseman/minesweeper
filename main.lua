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

game = nil

local function playingOnKeyPressed(key)
  if key == "r" then
    game = Game(game.gridWidth, game.gridHeight, game.mineCount)
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
      game:mousereleased(...)
    end,
    wheelmoved = function(_, y)
      game.zoom = game.zoom + y * 0.5
      if game.zoom > 5 then
        game.zoom = 5
      elseif game.zoom < 1 then
        game.zoom = 1
      end
    end,
    mousemoved = function(_, _, relx, rely)
      if love.mouse.isDown(1) then
        game.camerax = game.camerax - relx / game.zoom
        game.cameray = game.cameray - rely / game.zoom
        game.isPanning = true
      end
    end,
    update = function(dt)
      game:update(dt)
    end,
    draw = function()
      game:draw()
    end,
  },
  finish = {
    keypressed = playingOnKeyPressed,
    draw = function()
      game:draw()
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
  if game then
    love.window.setTitle(
      ("Minesweeper - %dx%d - %d/%d"):format(
        game.gridWidth, game.gridHeight,
        game.flagCount, game.mineCount))
  end
end

function love.draw()
  callCallback("draw")
end
