local Game = require("game")

local mainMenu = {}

local font = love.graphics.getFont()
local fontHeight = font:getHeight()

local config = {
  width = "",
  height = "",
  mines = "",
}
local presets = {
  "easy", "medium", "hard", "catman",
  easy = {width="8", height="8", mines="10"},
  medium = {width="11", height="11", mines="30"},
  hard = {width="16", height="16", mines="80"},
  catman = {width="50", height="50", mines="999"}
}
local fields = {"width", "height", "mines"}
local currentField = 1
local configErr = ""

function mainMenu.resetConfig()
  config.width = ""
  config.height = ""
  config.mines = ""
  configErr = ""
  currentField = 1
end

function mainMenu.textinput(text)
  local field = fields[currentField]
  config[field] = config[field] .. text
end

function mainMenu.keypressed(key)
  if key == "backspace" then
    local field = fields[currentField]
    config[field] = config[field]:sub(1, -2)
  end

  if key == "tab" then
    local newInput, v = next(fields, currentField)
    currentField = newInput
    if not v then
      currentField = 1
    end
  end
end

function mainMenu.mousepressed(_, my)
  local button = function(y)
    return my > y and my < y + fontHeight
  end

  for i, _ in ipairs(fields) do
    local y = fontHeight * (i - 1)
    if button(y) then
      currentField = i
      break
    end
  end

  for i, name in ipairs(presets) do
    local y = fontHeight * (i + #fields) + 10
    if button(y) then
      local preset = presets[name]
      config.width = preset.width
      config.height = preset.height
      config.mines = preset.mines
    end
  end

  if button(love.graphics.getHeight() - fontHeight) then
    local width = tonumber(config.width)
    local height = tonumber(config.height)
    local mines = tonumber(config.mines)

    if type(width) ~= "number" or type(height) ~= "number" or type(mines) ~= "number" then
      configErr = "malformed input"
      return
    end

    gameState = "playing"

    current = Game(width, height, mines)
  end
end

function mainMenu.draw()
  local _, my = love.mouse.getPosition()

  local button = function(text, y)
    local selected = my > y and my < y + fontHeight
    if selected then
      love.graphics.setColor(0.25, 0.25, 0.25)
      love.graphics.rectangle("fill", 0, y, love.graphics.getWidth(), fontHeight)
    end

    love.graphics.setColor(1, 0, 0)
    love.graphics.print(text, 0, y)
  end

  for i, input in ipairs(fields) do
    local text = ("%s: %s"):format(input, config[input])
    local y = fontHeight * (i - 1)
    button(text, y)

    if i == currentField then
      local x = font:getWidth(text)
      love.graphics.line(x, y, x, y + fontHeight)
    end
  end

  for i, name in ipairs(presets) do
    local preset = presets[name]
    local text = ("%s: %sx%s - %s"):format(name, preset.width, preset.height, preset.mines)
    local y = fontHeight * (i + #fields) + 10
    button(text, y)
  end

  local y = love.graphics.getHeight() - fontHeight
  button("done", y)
  love.graphics.print(configErr, 0, y - fontHeight)
end

return mainMenu
