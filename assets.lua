local assets = {}

local png = love.graphics.newImage("assets.png")
assets.batch = love.graphics.newSpriteBatch(png)

local function defineCell(x, y)
  return love.graphics.newQuad(x * 16, y * 16, 16, 16, png:getDimensions())
end

local function defineFace(name, x, y)
  assets[name] = love.graphics.newQuad(
    x, y,
    26, 26,
    png:getDimensions())
end

defineFace("normal", 0, 71)
defineFace("scared", 27, 71)
defineFace("dead", 54, 71)
defineFace("cool", 81, 71)
defineFace("pressed", 108, 71)

assets.shown     = defineCell(0, 1)
assets.hidden    = defineCell(1, 1)
assets.flag      = defineCell(2, 1)
assets.flagWrong = defineCell(3, 1)
assets.mine      = defineCell(4, 1)
assets.mineHit   = defineCell(5, 1)
assets.numbers   = {}

for i=1, 8 do
  table.insert(assets.numbers, defineCell(i-1, 0))
end

assets.segmented = {}
for i=0, 9 do
  assets.segmented[i] = love.graphics.newQuad(
      i * 12, 48,
      12, 23,
      png:getDimensions())
end

assets.segmentedBg = {}
-- Each section is a different width 💀
local widths = {14, 13, 14}
local width = 0
for i=1, 3 do
  -- Track the current offset
  width = width + widths[i]
  assets.segmentedBg[i] = love.graphics.newQuad(
       -- For some reason need to subtract the quads width before 
       -- adding the total width if it is to be centred properly
      132 - widths[i] + width, 45,
      widths[i], 25, -- The width of the quad is the index in widths
      png:getDimensions())
end

function assets.drawSegmented(number, x, y)
  if number < 0 then
    number = 0
  end

  -- Use seperateDigits function to divide the number into a table of digits
  local digits = separateDigits(number)
  -- digits = padWithZeros(digits, 3) -- Ensure there is never less than 3 digits displayed

  -- Adjusting the x/y to display the characters in the right place
  x = x + 2 * 3
  y = y + 1 * 3

  -- If the segmented display on the right edge of the screen goes over 3 digits, move it left
  if x > 0 then
    x = x + (3 - #digits)*13*3
  end
  -- On the left edge, it must be moved in the opposite direction
  if x < 0 then
    x = x - (3 - #digits)*13*3
  end

  -- Similarily to the assets.segmentedBg = {} init code, we must track the width
  local width = 0
  for i=1, #digits do
    if i == 1 then -- The first segment
      love.graphics.draw(png, assets.segmentedBg[1], x - 2*3, y -3, 0, 3) -- Subtract the adjustment we made to display the characters correctly
      love.graphics.draw(png, assets.segmented[digits[i]], x, y, 0, 3)
      -- Because the first width is 14, we add 14 to the total width first
      width = 14
    elseif i < #digits then -- All of the middle segments
      -- This is the same as drawing the first segment, but adding `+ width * 3` (((please make the 3 a variable))
      love.graphics.draw(png, assets.segmentedBg[2], x + width * 3 - 2*3, y -3, 0, 3)
      -- Here we subtract 1*3 because the first character is actually 13 wide instead of 14 like the background
      love.graphics.draw(png, assets.segmented[digits[i]], x + width * 3 - 1*3, y, 0, 3)
      -- After the first segment, the following ones are 13 wide
      width = width + 13
    elseif i == #digits then -- The last segment
      love.graphics.draw(png, assets.segmentedBg[3], x + width * 3 - 2*3, y -3, 0, 3)
      love.graphics.draw(png, assets.segmented[digits[i]], x + width * 3 - 1*3, y, 0, 3)
      -- We dont need to update the total width because nothing comes after this
    end
  end
end

-- Written by yours truly, ChatGPT
function separateDigits(number)
    local digits = {}
    while number > 0 do
        local digit = number % 10
        table.insert(digits, 1, digit)
        number = math.floor(number / 10)
    end
    return digits
end

-- Also written by ChatGPT
function padWithZeros(digitTable, minLength)
    local currentLength = #digitTable
    if currentLength < minLength then
        local padding = minLength - currentLength
        for i = 1, padding do
            table.insert(digitTable, 1, 0)
        end
    end
    return digitTable
end

function assets.draw(quad, x, y, s)
  love.graphics.draw(png, quad, x, y, 0, s)
end

return assets
