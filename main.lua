local Game = require "game"

game=nil


function love.load()
    game=Game:new()
end

t=0
fdt = 1/30
frm = 0
function love.update(dt)
    t = t + dt

    game:update(fdt)
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(pal(BACKGROUND_COL))
    love.graphics.translate(0, 0)

    game:draw()

    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.scale(1, 1)
    love.graphics.draw(canvas, 0, 0, 0, RENDER_SCALE, RENDER_SCALE)
end






-- returns rgb colour at _index of the supplied palette
-- TODO : i want to make a function that uses .hex files
function pal(_index, _opacity)
    local _opacity = _opacity or 1
    return hex_to_rgb(PALLETE[1+(_index)%#PALLETE], _opacity)
end

-- converts a hexdecimal colour into an rgb colour , it's brutal and not good but works I hate you
function hex_to_rgb(_hex, _opacity)
    local _opacity = _opacity or 1
    return unpack{tonumber(_hex:sub(1,2),16)/255,tonumber(_hex:sub(3,4),16)/255,tonumber(_hex:sub(5,6),16)/255, _opacity}
end

-- returns an array based on a string , splits between "," but also other things- it's enigmatic.. like me o_O
-- NOTES : 
    -- doesn't work with negative numbers :(
function split(_str, _delimiter)
    local _delimiter = _delimiter or ","
    result = {}
    for match in string.gmatch(_str,"[^".._delimiter.."]+") do
        table.insert(result,match)
    end
    return result
end