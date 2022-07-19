import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scenes/scene"
import "scenes/manager"

local gfx = playdate.graphics

class("SceneBalloon", {
	sceneType = SceneManager.SCENE_BALLOON,
}).extends(Scene)

function SceneBalloon:init()
	self.popped = false
	self.radius = 10
	self.pumpRate = 2
	self.popRadius = math.random(63, 67)
	self.endSceneTimeout = 5

	self.startTime = nil
	self.playTime = nil
end

function SceneBalloon:load()
	self.startTime = playdate.getCurrentTimeMilliseconds()

	playdate.inputHandlers.push({
		cranked = function(change, acceleratedChange)
			self:cranked(change, acceleratedChange)
		end,
	})
end

function SceneBalloon:unload()
	playdate.inputHandlers.pop()
end

function SceneBalloon:update()
	gfx.clear()

	if self.popped then
		-- Draw popped text
		gfx.drawTextAligned("*BLAM!!!!!*", 200, 120, kTextAlignment.center)

		-- Draw result text
		gfx.drawTextAligned("You took " .. self.playTime .. " seconds", 200, 220, kTextAlignment.center)
	else
		-- Draw the balloon
		gfx.drawArc(200, 210 - self.radius, self.radius, 200, 160)
	
		-- Draw help text
		gfx.drawTextAligned("CRANK IT!", 200, 220, kTextAlignment.center)
	end

	playdate.timer.updateTimers()
end

function SceneBalloon:cranked(change, acceleratedChange)
	if not self.popped then
		if change > 0 then
			self.radius += (change / 360) * self.pumpRate
		end

		if (self.radius >= self.popRadius) then
			self:popBalloon()
		end
	end
end

function SceneBalloon:popBalloon()
	self.popped = true
	self.playTime = (playdate.getCurrentTimeMilliseconds() - self.startTime) / 1000;

	playdate.timer.new(self.endSceneTimeout * 1000, function ()
		self:endScene()
	end)
end

function SceneBalloon:endScene()
	SceneManager.endScene()
end
