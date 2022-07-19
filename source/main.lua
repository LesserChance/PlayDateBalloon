import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "scenes/manager"

local function initialize()
    SceneManager.load(SceneManager.SCENE_INTRO)
end

initialize()
