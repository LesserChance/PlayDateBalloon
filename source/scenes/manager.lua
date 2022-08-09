import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local currentScene

SceneManager = {}
SceneManager.SCENE_INTRO = 1
SceneManager.SCENE_BALLOON = 2
SceneManager.SCENE_SNAKE = 3

import "scenes/intro"
import "scenes/balloon"
import "scenes/snake"

function SceneManager.load(newScene)
    if currentScene then
        currentScene:unload()
    end

    if newScene == SceneManager.SCENE_INTRO then
        currentScene = SceneIntro()
    elseif newScene == SceneManager.SCENE_BALLOON then
        currentScene = SceneBalloon()
    elseif newScene == SceneManager.SCENE_SNAKE then
        currentScene = SceneSnake()
    end

    if currentScene then
        currentScene:load()
    end
end

function SceneManager.endScene()
    if not currentScene then
        return
    end

    if currentScene.sceneType == SceneManager.SCENE_BALLOON then
        -- go back to the intro
        SceneManager.load(SceneManager.SCENE_INTRO)
    elseif currentScene.sceneType == SceneManager.SCENE_SNAKE then
        -- go back to the intro
        SceneManager.load(SceneManager.SCENE_INTRO)
    end
end

function playdate.update()
    currentScene:update()
end
