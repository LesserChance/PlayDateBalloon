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

    self.image = gfx.image.new(grid.columnWidth, grid.rowHeight)
    self:setImage(self.image)

    gfx.pushContext(self.image)
        gfx.drawCircleAtPoint(grid.columnWidth/2,grid.rowHeight/2,grid.columnWidth/2)
    gfx.popContext()

    self:add()
end

function Apple:load()
end

function Apple:unload()
    self:remove()
end

function Apple:update()
end

