local assets = require("assets")

local game = {}
game.__index = game

local font = love.graphics.getFont()
local fontHeight = font:getHeight()

function game:update(dt)
  self.timer = self.timer + dt

  local ix, iy = 0, 0
  if love.keyboard.isDown("w") then iy = iy - 1 end
  if love.keyboard.isDown("a") then ix = ix - 1 end
  if love.keyboard.isDown("s") then iy = iy + 1 end
  if love.keyboard.isDown("d") then ix = ix + 1 end

  local ilen = math.sqrt(ix^2 + iy^2)
  if ilen ~= 0 then
    ix = ix / ilen
    iy = iy / ilen
  end

  local speed = 200
  if love.keyboard.isDown("lshift") then
    speed = 400
  end

  self.camerax = self.camerax + ix * speed * dt
  self.cameray = self.cameray + iy * speed * dt

  if love.keyboard.isDown("=") or love.keyboard.isDown("e") then
    self.zoom = self.zoom + dt
  end
  if love.keyboard.isDown("-") or love.keyboard.isDown("q") then
    self.zoom = self.zoom - dt
  end

  if self.zoom > 5 then
    self.zoom = 5
  elseif self.zoom < 1 then
    self.zoom = 1
  end
end

function game:draw()
  love.graphics.scale(self.zoom)
  local ww, wh = love.graphics.getDimensions()

  local cx, cy = self:getCameraPosition()
  love.graphics.translate(-cx, -cy)

  assets.batch:clear()

  love.graphics.setColor(1, 1, 1)
  for x=0, self.gridWidth-1 do
    for y=0, self.gridHeight-1 do
      local cell = self:getCell(x, y)
      local dx, dy = x * cellWidth, y * cellHeight

      if self:isCellShown(x, y) or self.cheating then
        assets.batch:add(assets.shown, dx, dy)

        if cell == -1 then
          local asset = assets.mine
          if x == self.lastClickX and y == self.lastClickY then
            asset = assets.mineHit
          end
          assets.batch:add(asset, dx, dy)
        elseif cell > 0 then
          assets.batch:add(assets.numbers[cell], dx, dy)
        end
      else
        assets.batch:add(assets.hidden, dx, dy)
        if self.outcome == "lose" and cell == -1 then
          assets.batch:add(assets.mine, dx, dy)
        end
        if self:isFlagged(x, y) then
          local asset = assets.flag
          if self.outcome == "lose" and cell ~= -1 then
            asset = assets.flagWrong
          end
          assets.batch:add(asset, dx, dy)
        end
      end
    end
  end

  love.graphics.draw(assets.batch, 0, 0)

  love.graphics.origin()

  love.graphics.setColor(0.75, 0.75, 0.75)
  love.graphics.rectangle("fill", 0, 0, ww, 26 * 3)
  assets.drawSegmented(self.mineCount - self.flagCount, 0, 0)
  assets.drawSegmented(math.floor(self.timer), ww - 41 * 3, 0)

  if self.outcome == "lose" then
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("You lose!", 0, wh / 2 - fontHeight / 2, ww, "center")
  elseif self.outcome == "win" then
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("You win!", 0, wh / 2 - fontHeight / 2, ww, "center")
  end
end

function game:mousereleased(x, y, button)
  if self.isPanning then
    self.isPanning = false
    return
  end

  local cx, cy = self:getCameraPosition()

  x = cx + math.floor(x / self.zoom)
  y = cy + math.floor(y / self.zoom)

  local cellx, celly = math.floor(x / cellWidth), math.floor(y / cellHeight)
  if button == 1 then
    self:floodFill(cellx, celly)
    self.lastClickX = cellx
    self.lastClickY = celly
  elseif button == 2 then
    self:toggleFlag(cellx, celly)
  end
end

function game:getCellIndex(x, y)
  local r = (y * self.gridHeight) + x + 1
  return r
end

function game:getCell(x, y)
  return self.grid[self:getCellIndex(x, y)].number
end

function game:setCell(x, y, v)
  self.grid[self:getCellIndex(x, y)].number = v
end

function game:showCell(x, y)
  self.grid[self:getCellIndex(x, y)].shown = true
  self.uncoveredCells = self.uncoveredCells - 1

  if self:getCell(x, y) == -1 then
    self.outcome = "lose"
    gameState = "finish"
  end

  if self.uncoveredCells == 0 then
    self.outcome = "win"
    gameState = "finish"
  end
end

function game:isCellShown(x, y)
  return self.grid[self:getCellIndex(x, y)].shown
end

function game:isFlagged(x, y)
  return self.grid[self:getCellIndex(x, y)].flagged
end

function game:toggleFlag(x, y)
  if x >= self.gridWidth or x < 0 then
    return
  end
  if y >= self.gridHeight or y < 0 then
    return
  end

  local flagged = self:isFlagged(x, y)
  self.grid[self:getCellIndex(x, y)].flagged = not flagged
  if flagged then
    self.flagCount = self.flagCount - 1
  else
    self.flagCount = self.flagCount + 1
  end
end

function game:incrementCell(x, y, by)
  if x >= self.gridWidth or x < 0 then
    return
  end
  if y >= self.gridHeight or y < 0 then
    return
  end
  local cell = self:getCell(x, y)
  if cell == -1 then
    return
  end

  if cell + 1 == 8 then
    -- There's no way to reliably tell if there's an 8, and that's unfair
    self:setCell(x, y, -1)
    self.flagCount = self.flagCount - 1
  else
    self:setCell(x, y, cell + by)
  end
end

function game:floodFill(x, y)
  if x >= self.gridWidth or x < 0 then
    return
  end
  if y >= self.gridHeight or y < 0 then
    return
  end

  if self:isCellShown(x, y) or self:isFlagged(x, y) then
    return
  end

  self:showCell(x, y)

  if self:getCell(x, y) ~= 0 then
    return
  end

  self:floodFill(x + 1, y)
  self:floodFill(x - 1, y)
  self:floodFill(x,     y + 1)
  self:floodFill(x,     y - 1)
  self:floodFill(x + 1, y + 1)
  self:floodFill(x - 1, y - 1)
  self:floodFill(x - 1, y + 1)
  self:floodFill(x + 1, y - 1)
end

function game:getCameraPosition()
  local ww, wh = love.graphics.getDimensions()
  local tx = self.camerax - ww * 0.5 / self.zoom
  local ty = self.cameray - wh * 0.5 / self.zoom
  return tx, ty
end

local function new(gridWidth, gridHeight, mineCount)
  local g = setmetatable({}, game)

  local gridPxWidth, gridPxHeight = gridWidth * cellWidth, gridHeight * cellHeight
  local camerax, cameray = gridPxWidth / 2, gridPxHeight / 2

  g.gridWidth = gridWidth
  g.gridHeight = gridHeight
  g.gridPxWidth = gridPxWidth
  g.gridPxHeight = gridPxHeight
  g.mineCount = mineCount
  g.uncoveredCells = gridWidth * gridHeight - mineCount
  g.flagCount = 0
  g.lastClickX = 0
  g.lastClickY = 0
  g.timer = 0
  g.camerax = camerax
  g.cameray = cameray
  g.isPanning = false
  g.zoom = 1
  g.outcome = nil
  g.grid = {}

  for _=1, gridWidth * gridHeight do
    table.insert(g.grid, {shown=false, flagged=false, number=0})
  end

  for _=1, mineCount do
    local x = love.math.random(0, gridWidth - 1)
    local y = love.math.random(0, gridHeight - 1)

    repeat
      x = love.math.random(0, gridWidth - 1)
      y = love.math.random(0, gridHeight - 1)
    until g:getCell(x, y) ~= -1

    g:setCell(x, y, -1)
    g:incrementCell(x + 1, y,     1)
    g:incrementCell(x - 1, y,     1)
    g:incrementCell(x,     y + 1, 1)
    g:incrementCell(x,     y - 1, 1)
    g:incrementCell(x + 1, y + 1, 1)
    g:incrementCell(x - 1, y - 1, 1)
    g:incrementCell(x - 1, y + 1, 1)
    g:incrementCell(x + 1, y - 1, 1)
  end

  while true do
    local x = love.math.random(0, gridWidth - 1)
    local y = love.math.random(0, gridHeight - 1)

    if g:getCell(x, y) == 0 then
      g:floodFill(x, y)
      break
    end
  end

  return g
end

return new
