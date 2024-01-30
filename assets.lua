local assets = {}

local png = love.graphics.newImage("assets.png")
assets.batch = love.graphics.newSpriteBatch(png)

local function defineCell(x, y)
  return love.graphics.newQuad(x * 16, y * 16, 16, 16, png:getDimensions())
end

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
for i=1, 9 do
  table.insert(assets.segmented,
    love.graphics.newQuad(
      i * 12, 48,
      12, 23,
      png:getDimensions()))
end

return assets
