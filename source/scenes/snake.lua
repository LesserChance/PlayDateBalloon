import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scenes/scene"
import "scenes/manager"

import "sprites/snake/snake"
import "sprites/snake/apple"

local gfx = playdate.graphics

class("SceneSnake", {
    sceneType = SceneManager.SCENE_SNAKE,
}).extends(Scene)

function SceneSnake:init()
    -- display: 400 x 240
    self.columns = 20
    self.rows = 10
    self.appleSpeed = 1500
    self.score = 0
    self.endSceneTimeout = 5

    self.startTime = nil
    self.playTime = nil

    self.running = true

    local colPadding = 10
    local rowPadding = 40
    local maxGridWidth = (playdate.display.getWidth() - colPadding)
    local maxGridHeight = (playdate.display.getHeight() - rowPadding)

    self.columnWidth = math.floor(maxGridWidth / self.columns)
    self.rowHeight = math.floor(maxGridHeight / self.rows)

    self.gridWidth = (self.columnWidth * self.columns)
    self.gridHeight = (self.rowHeight * self.rows)
    
    self.colStart = (playdate.display.getWidth() - self.gridWidth) / 2
    self.rowStart = 10
    
    self.strokeWidth = 1

    self.snake = Snake(self)
    self.apples = {}

    self:createApple()
end

function SceneSnake:load()
    self.startTime = playdate.getCurrentTimeMilliseconds()
    self.snake:load()
end

function SceneSnake:unload()
    self.snake:unload()
    
    for i = 1, #self.apples do
        self.apples[i]:unload()
    end

    if self.appleTimer then
        self.appleTimer:remove()
    end
end

function SceneSnake:endScene()
    SceneManager.endScene()
end

function SceneSnake:handleCollision()
   self.running = false
   self.playTime = (playdate.getCurrentTimeMilliseconds() - self.startTime) / 1000;

   playdate.timer.new(self.endSceneTimeout * 1000, function()
       self:endScene()
   end)
end

function SceneSnake:createApple()
    local collision = true
    local attempts = 0
    local x, y

    while (collision) do
        x = math.random(1, self.columns)
        y = math.random(1, self.rows)

        collision = false

        -- check existing apples
        for i = 1, #self.apples do
            if (x == self.apples[i].gridX and y == self.apples[i].gridY) then
                collision = true
            end
        end

        -- check snakes
        for i = 1, #self.snake.positions do
            if (x == self.snake.positions[i].x and y == self.snake.positions[i].y) then
                collision = true
            end
        end

        if (collision and attempts >= 10) then
            collision = false
        end

        if (collision and attempts < 10) then
            attempts += 1
        end
    end

    table.insert(self.apples, Apple(self, x, y))

    self.appleTimer = playdate.timer.new(self.appleSpeed, function()
        self:createApple()
    end)
end

function SceneSnake:removeApple(apple)
    self.score += 1
    self.apples[apple]:unload()
    table.remove(self.apples, apple)
end

function SceneSnake:getCellBounds(x, y)
    return {
        x = self.colStart + ((x - 1) * self.columnWidth),
        y = self.rowStart + ((y - 1) * self.rowHeight),
        width = self.columnWidth,
        height = self.rowHeight
    }
end

function SceneSnake:update()
    if (not self.running) then
        gfx.clear()

        -- Draw popped text
        gfx.drawTextAligned("*BLAM!!!!!*", 200, 120, kTextAlignment.center)

        -- Draw result text
        gfx.drawTextAligned("You got " .. self.score .. " apples in ".. self.playTime .. " seconds", 200, 220, kTextAlignment.center)
        
        playdate.timer.updateTimers()
        return
    end

    -- update all sprites
    gfx.sprite.update()

    self.snake:update()
    
    -- draw text
    gfx.drawTextAligned("SNAKE IT!", 200, 220, kTextAlignment.center)
    
    -- draw a border
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.setLineWidth(self.strokeWidth)
    -- gfx.setStrokeLocation(gfx.kStrokeCentered)
    -- gfx.drawRect(self.colStart, self.rowStart, self.gridWidth, self.gridHeight)

    playdate.timer.updateTimers()
end