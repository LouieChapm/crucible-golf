local Game = require "game"

require "util"

game=nil
debug="debug"


function love.load()
    -- init canvas
    CANVAS_WIDTH=320
    CANVAS_HEIGHT=180
    RENDER_SCALE=3

    -- Apparently web exports are a bit broken , refer back to clever leo for this one
    if OPERATING_SYSTEM == "Web" then
		-- ignore for now
	else
		-- Init window
		love.window.setMode(CANVAS_WIDTH * RENDER_SCALE, CANVAS_HEIGHT * RENDER_SCALE)
		SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
		love.window.setTitle("Test")	
        love.filesystem.setIdentity('screenshot_example');	
	end
    love.graphics.setDefaultFilter("nearest")
    love.graphics.setLineStyle("rough")

    -- set up canvas and palette
    canvas = love.graphics.newCanvas(CANVAS_WIDTH, CANVAS_HEIGHT)
    PALLETE=split("000000,1D2B53,7E2553,008751,AB5236,5F574F,C2C3C7,FFF1E8,FF004D,FFA300,FFEC27,00E436,29ADFF,83769C,FF77A8,FFCCAA")
    
    -- set up fonts
    FONT_MAIN = love.graphics.newFont("fonts/font_main.ttf",4)
    love.graphics.setFont(FONT_MAIN)


    game=Game:new()
end

t=0
fdt = 1/30
frm = 0
function love.update(dt)
    t = t + dt
    frm = frm+1

    game:update(fdt)
end

function love.draw()
    love.graphics.setCanvas( { canvas, stencil = true } )
    love.graphics.clear(pal(BACKGROUND_COL))
    love.graphics.translate(0, 0)

    game:draw()

    love.graphics.setColor(pal(7))
    love.graphics.print(debug,1,1)

    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.scale(1, 1)
    love.graphics.draw(canvas, 0, 0, 0, RENDER_SCALE, RENDER_SCALE)
end