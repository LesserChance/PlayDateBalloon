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
    -- local spritesheet = playdate.graphics.imagetable.new("assets/Snake")
    -- -- spritesheet:drawImage(1, 20, 0) -- tail A
    -- -- spritesheet:drawImage(2, 40, 0) -- body A
    -- -- spritesheet:drawImage(3, 60, 0) -- head A
    -- -- spritesheet:drawImage(4, 80, 0) -- tail B
    -- -- spritesheet:drawImage(5, 100, 0) -- body B
    -- -- spritesheet:drawImage(6, 120, 0) -- head B
    -- -- spritesheet:drawImage(7, 140, 0) -- curve A
    -- -- spritesheet:drawImage(8, 160, 0) -- curve B
    
    -- spritesheet:drawImage(1, 20, 0) -- tail A
    -- spritesheet:drawImage(2, 40, 0) -- body A
    -- spritesheet:drawImage(5, 60, 0) -- body B
    -- spritesheet:drawImage(2, 80, 0) -- body A
    -- spritesheet:drawImage(3, 100, 0) -- head A

    if playdate.buttonJustReleased(playdate.kButtonA) then
        SceneManager.load(SceneManager.SCENE_BALLOON)
    elseif playdate.buttonJustReleased(playdate.kButtonB) then
        SceneManager.load(SceneManager.SCENE_SNAKE)
    end
end
