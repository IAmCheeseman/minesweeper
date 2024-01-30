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

assets.segmentedBg = love.graphics.newQuad(
  132, 45,
  41, 25,
  png:getDimensions())

function assets.drawSegmented(number, x, y)
  local ones, tens, hundreds
  hundreds = number >= 100 and math.floor(number / 100) or 0
  tens = number >= 10 and math.floor((number - hundreds * 100) / 10) or 0
  ones = number - hundreds * 100 - tens * 10

  love.graphics.draw(png, assets.segmentedBg, x, y, 0, 3)
  x = x + 2 * 3
  y = y + 1 * 3
  love.graphics.draw(png, assets.segmented[hundreds], x,          y, 0, 3)
  love.graphics.draw(png, assets.segmented[tens],     x + 13 * 3, y, 0, 3)
  love.graphics.draw(png, assets.segmented[ones],     x + 26 * 3, y, 0, 3)
end

function assets.draw(quad, x, y, s)
  love.graphics.draw(png, quad, x, y, 0, s)
end

return assets
