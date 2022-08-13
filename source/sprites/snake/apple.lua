import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

class("Apple", {}, SpriteSnake).extends(gfx.sprite)

function Apple:init(grid, x, y)
    Apple.super.init(self)

    self.gridX = x
    self.gridY = y

    self.clear = false

    local position = grid:getCellBounds(x,y)

    self:setSize(grid.columnWidth, grid.rowHeight)
    self:moveTo(position.x + grid.columnWidth/2, position.y + grid.rowHeight/2)

    self:setZIndex(1)

    self.image = gfx.image.new("assets/Apple")
    self:setImage(self.image, 0, math.min(grid.columnWidth, grid.rowHeight)/20)

    self:add()
end

function Apple:unload()
    self:remove()
end
