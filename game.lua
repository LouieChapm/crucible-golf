local Class = require "class"

local Game=Class:inherit()

function Game:init()
    CANVAS_WIDTH=320
    CANVAS_HEIGHT=180
    RENDER_SCALE=3

    love.math.setRandomSeed(9)--os.time())

    -- Apparently web exports are a bit broken , refer back to clever leo for this one
    if OPERATING_SYSTEM == "Web" then
		-- ignore
	else
		-- Init window
		love.window.setMode(CANVAS_WIDTH * RENDER_SCALE, CANVAS_HEIGHT * RENDER_SCALE)
		SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
		love.window.setTitle("Test")	
        love.filesystem.setIdentity('screenshot_example');	
	end
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")

    -- set up canvas
    canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    PALLETE=split("000000,1D2B53,7E2553,008751,AB5236,5F574F,C2C3C7,FFF1E8,FF004D,FFA300,FFEC27,00E436,29ADFF,83769C,FF77A8,FFCCAA")
    
    -- set up fonts
    FONT_MAIN = love.graphics.newFont("fonts/font_main.ttf",4)
    love.graphics.setFont(FONT_MAIN)
    
    BACKGROUND_COL=12

end

function Game:update()

end

function Game:draw()

end


return Game