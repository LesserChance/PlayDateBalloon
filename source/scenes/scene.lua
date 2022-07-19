import "CoreLibs/object"
import "CoreLibs/graphics"

class("Scene", {
	sceneType = 0
}).extends()

function Scene:init()
end

function Scene:load()
end

function Scene:unload()
	playdate.graphics.clear()
end

function Scene:update()
end