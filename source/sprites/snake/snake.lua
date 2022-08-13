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

local SNAKE_SPRITE = {}
SNAKE_SPRITE.TAIL_A = 1
SNAKE_SPRITE.BODY_A = 2
SNAKE_SPRITE.HEAD_A = 3
SNAKE_SPRITE.TAIL_B = 4
SNAKE_SPRITE.BODY_B = 5
SNAKE_SPRITE.HEAD_B = 6
SNAKE_SPRITE.CURVE_A = 7
SNAKE_SPRITE.CURVE_B = 8

class("Snake", {}, SpriteSnake).extends()

local spriteSize = 20

function Snake:init(grid)
    self.speed = 30 -- how many ms between movement ticks
    self.bodySpeed = 200 -- how many ms between movement sprite ticks

    self.grid = grid
    self.hasEaten = false

    -- position goes from head [1] to tail [length]
    self.positions = {{x = 3, y = 1},{x = 2, y = 1},{x = 1, y = 1}}
    self.direction = SNAKE_DIRECTION.RIGHT
    self.nextDirection = self.direction
    
    self.grid = grid
    self.xSize = grid.columnWidth
    self.ySize = grid.rowHeight

    self.spriteState = 0
    self.spritesheet = gfx.imagetable.new("assets/Snake")
end

function Snake:load()
    self:loadInputHandlers()

    self.moveTimer = playdate.timer.new(self.speed, function()
        self:move()
    end)
    self.bodyTimer = playdate.timer.new(self.bodySpeed, function()
        self:changeBody()
    end)
end

function Snake:unload()
    playdate.inputHandlers.pop()
    
    if self.moveTimer then
        self.moveTimer:remove()
    end
    if self.bodyTimer then
        self.bodyTimer:remove()
    end
end

function Snake:loadInputHandlers()
    playdate.inputHandlers.push({
        upButtonDown = function()
            if (self.direction == self.nextDirection) then
                self.nextDirection = SNAKE_DIRECTION.UP
            end
        end,
        downButtonDown = function()
            if (self.direction == self.nextDirection) then
                self.nextDirection = SNAKE_DIRECTION.DOWN
            end
        end,
        leftButtonDown = function()
            if (self.direction == self.nextDirection) then
                self.nextDirection = SNAKE_DIRECTION.LEFT
            end
        end,
        rightButtonDown = function()
            if (self.direction == self.nextDirection) then
                self.nextDirection = SNAKE_DIRECTION.RIGHT
            end
        end
    })
end

function Snake:changeBody()
    if self.spriteState == 0 then
        self.spriteState = 1
    else
        self.spriteState = 0
    end
    self.bodyTimer = playdate.timer.new(self.bodySpeed, function()
        self:changeBody()
    end)
end

function Snake:move()
    if (self.direction ~= self.nextDirection) then
        self.direction = self.nextDirection
    end

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

    self.moveTimer = playdate.timer.new(self.speed, function()
        self:move()
    end)
end

function Snake:eat()
    self.hasEaten = true
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

    for i = 1, #self.positions do
        -- create an image tile'
        local spriteIndex
        local spriteAngle = 0

        if (i == 1) then
            -- head
            if self.spriteState == 0 then
                spriteIndex = SNAKE_SPRITE.HEAD_A
            else
                spriteIndex = SNAKE_SPRITE.HEAD_B
            end

            if (self.direction == SNAKE_DIRECTION.UP) then
                spriteAngle = 270
            elseif (self.direction == SNAKE_DIRECTION.DOWN) then
                spriteAngle = 90
            elseif (self.direction == SNAKE_DIRECTION.LEFT) then
                spriteAngle = 180
            end
        elseif (i == #self.positions) then
            -- tail
            if self.spriteState == 0 then
                spriteIndex = SNAKE_SPRITE.TAIL_A
            else
                spriteIndex = SNAKE_SPRITE.TAIL_B
            end

            local lastPosDirection = self:getDirectionToPosition(self.positions[i], self.positions[i-1])

            if (lastPosDirection == SNAKE_DIRECTION.UP) then
                spriteAngle = 270
            elseif (lastPosDirection == SNAKE_DIRECTION.DOWN) then
                spriteAngle = 90
            elseif (lastPosDirection == SNAKE_DIRECTION.RIGHT) then
                spriteAngle = 0
            else
                spriteAngle = 180
            end
        else
            -- connecting body
            local lastPosDirection = self:getDirectionToPosition(self.positions[i], self.positions[i-1])
            local nextPosDirection = self:getDirectionToPosition(self.positions[i], self.positions[i+1])

            if (lastPosDirection == SNAKE_DIRECTION.UP) then
                if (nextPosDirection == SNAKE_DIRECTION.DOWN) then
                    -- print("UP, DOWN")
                    spriteIndex = SNAKE_SPRITE.BODY_A
                    spriteAngle = 90
                elseif (nextPosDirection == SNAKE_DIRECTION.RIGHT) then
                    -- print("UP, RIGHT")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 90 --no
                else
                    -- print("UP, LEFT")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 0
                end
            elseif (lastPosDirection == SNAKE_DIRECTION.DOWN) then
                if (nextPosDirection == SNAKE_DIRECTION.UP) then
                    -- print("DOWN, UP")
                    spriteIndex = SNAKE_SPRITE.BODY_A
                    spriteAngle = 90
                elseif (nextPosDirection == SNAKE_DIRECTION.RIGHT) then
                    -- print("DOWN, RIGHT")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 180
                else
                    -- print("DOWN, LEFT")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 270
                end
            elseif (lastPosDirection == SNAKE_DIRECTION.RIGHT) then
                if (nextPosDirection == SNAKE_DIRECTION.UP) then
                    -- print("RIGHT, UP")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 90
                elseif (nextPosDirection == SNAKE_DIRECTION.DOWN) then
                    -- print("RIGHT, DOWN")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 180
                else
                    -- print("RIGHT, LEFT")
                    spriteIndex = SNAKE_SPRITE.BODY_A
                    spriteAngle = 0
                end
            else
                if (nextPosDirection == SNAKE_DIRECTION.UP) then
                    -- print("LEFT, UP")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 0
                elseif (nextPosDirection == SNAKE_DIRECTION.DOWN) then
                    -- print("LEFT, DOWN")
                    spriteIndex = SNAKE_SPRITE.CURVE_A
                    spriteAngle = 270
                else
                    -- print("LEFT, RIGHT")
                    spriteIndex = SNAKE_SPRITE.BODY_A
                    spriteAngle = 0
                end
            end

            if (self.spriteState > 0) then
                if (spriteIndex == SNAKE_SPRITE.BODY_A) then
                    -- straight body
                    spriteIndex = SNAKE_SPRITE.BODY_B
                else
                    --curved body
                    spriteIndex = SNAKE_SPRITE.CURVE_B
                end
            end
        end

        local spriteImage = self.spritesheet:getImage(spriteIndex)
        spriteImage:drawRotated(
            self.grid.colStart + (self.positions[i].x - 1) * self.xSize + (spriteSize / 2),
            self.grid.rowStart + (self.positions[i].y - 1) * self.ySize + (spriteSize / 2),
            spriteAngle
        )
    end
end


function Snake:getDirectionToPosition(fromPosition, toPosition)
    if (fromPosition.x < toPosition.x) then
        if (toPosition.x - fromPosition.x == 1) then
            return SNAKE_DIRECTION.RIGHT
        else
            return SNAKE_DIRECTION.LEFT
        end
    elseif (fromPosition.x > toPosition.x) then
        if (fromPosition.x - toPosition.x == 1) then
            return SNAKE_DIRECTION.LEFT
        else
            return SNAKE_DIRECTION.RIGHT
        end
    else
        if (fromPosition.y < toPosition.y) then
            if (toPosition.y - fromPosition.y == 1) then
                return SNAKE_DIRECTION.DOWN
            else
                return SNAKE_DIRECTION.UP
            end
        else
            if (fromPosition.y - toPosition.y == 1) then
                return SNAKE_DIRECTION.UP
            else
                return SNAKE_DIRECTION.DOWN
            end
        end
    end
end
