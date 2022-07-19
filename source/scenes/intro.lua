import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scenes/scene"
import "scenes/manager"

class("SceneIntro", {
    sceneType = SceneManager.SCENE_INTRO,
}).extends(Scene)

function SceneIntro:load()
    playdate.graphics.clear()
    playdate.graphics.drawTextAligned("Press A or B to play", 200, 120, kTextAlignment.center)
end

function SceneIntro:update()
    if playdate.buttonJustReleased(playdate.kButtonA) or
        playdate.buttonJustReleased(playdate.kButtonB) then
        SceneManager.load(SceneManager.SCENE_BALLOON)
    end
end
