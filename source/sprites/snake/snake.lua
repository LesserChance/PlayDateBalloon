import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx = playdate.graphics

local SNAKE_DIRECTION = {}
SNAKE_DIRECTION.UP = 1
SNAKE_DIRECTION.DOWN = 2
SNAKE_DIRECTION.LEFT = 3
SNAKE_DIRECTION.RIGHT = 4

class("Snake", {}, SpriteSnake).extends(gfx.sprite)

function Snake:init(grid)
    Snake.super.init(self)

    self.speed = 30 -- how many ms between movement ticks

    self.grid = grid
    self.hasEaten = false

    -- position goes from head [1] to tail [length]
    self.positions = {{x = 1, y = 1}}
    self.direction = SNAKE_DIRECTION.RIGHT
    
    self.grid = grid
    self.xSize = grid.columnWidth
    self.ySize = grid.rowHeight
    
    -- the image sze for the snake is the entire grid, moveTo moves the center
    self:setSize(grid.gridWidth, grid.gridHeight)
    self:moveTo(
        grid.colStart + (grid.gridWidth / 2),
        grid.rowStart + (grid.gridHeight / 2)
    )
    self:setZIndex(1)

    self.image = gfx.image.new(self.grid.gridWidth, self.grid.gridHeight)
    self:setImage(self.image)

    self:add()
end

function Snake:load()
    playdate.inputHandlers.push({
        upButtonDown = function()
            self.direction = SNAKE_DIRECTION.UP
        end,
        downButtonDown = function()
            self.direction = SNAKE_DIRECTION.DOWN
        end,
        leftButtonDown = function()
            self.direction = SNAKE_DIRECTION.LEFT
        end,
        rightButtonDown = function()
            self.direction = SNAKE_DIRECTION.RIGHT
        end,
        AButtonUp = function()
            self:eat()
        end,
        BButtonUp = function()
            self:eat()
        end,
    })

    playdate.timer.new(self.speed, function()
        self:move()
    end)
end

function Snake:move()
    -- store the tail position for any eating
    local lastTailPosition = {x = self.positions[#self.positions].x, y = self.positions[#self.positions].y}
    
    -- move all positions forward
    for i = #self.positions, 2, -1 do
        self.positions[i].x = self.positions[i - 1].x
        self.positions[i].y = self.positions[i - 1].y
    end

    -- add a new position at the tail
    if (self.hasEaten) then
        self.positions[#self.positions+1] = {x = lastTailPosition.x, y = lastTailPosition.y}
        self.hasEaten = false
    end
    
    -- move the head position
    if (self.direction == SNAKE_DIRECTION.UP) then
        self.positions[1].y -= 1
        if (self.positions[1].y < 1) then
            self.positions[1].y = self.grid.rows
        end
    elseif (self.direction == SNAKE_DIRECTION.DOWN) then
        self.positions[1].y += 1
        if (self.positions[1].y > self.grid.rows) then
            self.positions[1].y = 1
        end
    elseif (self.direction == SNAKE_DIRECTION.LEFT) then
        self.positions[1].x -= 1
        if (self.positions[1].x < 1) then
            self.positions[1].x = self.grid.columns
        end
    elseif (self.direction == SNAKE_DIRECTION.RIGHT) then
        self.positions[1].x += 1
        if (self.positions[1].x > self.grid.columns) then
            self.positions[1].x = 1
        end
    end

    playdate.timer.new(self.speed, function()
        self:move()
    end)
end

function Snake:eat()
    self.hasEaten = true
end

function Snake:unload()
    playdate.inputHandlers.pop()
end

function Snake:update()
    -- detect personal collisions
    local collision = false
    for i = 2, #self.positions do
        if (self.positions[i].x == self.positions[1].x and self.positions[i].y == self.positions[1].y) then
            collision = true
        end
    end
    
    if (collision) then
        self.grid:handleCollision()
        return
    end

    -- detect apple collisions
    local eatApple = 0
    for i = 1, #self.grid.apples do
        if (self.grid.apples[i].gridX == self.positions[1].x and self.grid.apples[i].gridY == self.positions[1].y) then
            eatApple = i
        end
    end

    if (eatApple > 0) then
        self:eat()
        self.grid:removeApple(eatApple)
    end

    gfx.pushContext(self.image)
        gfx.clear()
        for i = 1, #self.positions do
            gfx.fillRect(
                (self.positions[i].x - 1) * self.xSize,
                (self.positions[i].y - 1) * self.ySize,
                self.xSize,
                self.ySize
            )
        end
    gfx.popContext()
end
