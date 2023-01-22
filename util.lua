lg=love.graphics
lm=love.math  

sin=math.sin
cos=math.cos
lg.setColour=lg.setColor    -- i refuse ! 


-- returns rgb colour at _index of the supplied palette
-- TODO : i want to make a function that uses .hex files
function pal(_index, _opacity)
    local _opacity = _opacity or 1
    return hex_to_rgb(PALLETE[1+(_index)%#PALLETE], _opacity)
end

-- converts a hexdecimal colour into an rgb colour , it's brutal and not good but works I hate you
function hex_to_rgb(_hex, _opacity)
    local _opacity = _opacity or 1
    return tonumber(_hex:sub(1,2),16)/255,tonumber(_hex:sub(3,4),16)/255,tonumber(_hex:sub(5,6),16)/255, _opacity
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




-- a black/white mask image: black pixels will mask, white pixels will pass.
local dither_0x = lg.newImage("/textures/0x_grid.png")
local dither_1x = lg.newImage("/textures/1x_grid.png")
local dither_2x = lg.newImage("/textures/2x_grid.png")
local dither_4x = lg.newImage("/textures/4x_grid.png")
local dither_8x = lg.newImage("/textures/8x_grid.png")

shader_dither = love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
        // a discarded pixel wont be applied as the stencil.
        discard;
    }
    return vec4(1.0);
}
]]

function function_0x_dither()
    lg.setShader(shader_dither)
    local img_width,img_height=dither_0x:getWidth(),dither_0x:getHeight()
    for x=0,CANVAS_WIDTH,img_width do
        for y=0,CANVAS_HEIGHT,img_height do
            lg.draw(dither_0x, x, y)
        end
    end
    lg.setShader()
end

function function_1x_dither()
    lg.setShader(shader_dither)
    local img_width,img_height=dither_1x:getWidth(),dither_1x:getHeight()
    for x=0,CANVAS_WIDTH,img_width do
        for y=0,CANVAS_HEIGHT,img_height do
            lg.draw(dither_1x, x, y)
        end
    end
    lg.setShader()
end

function function_2x_dither()
    lg.setShader(shader_dither)
    local img_width,img_height=dither_2x:getWidth(),dither_2x:getHeight()
    for x=0,CANVAS_WIDTH,img_width do
        for y=0,CANVAS_HEIGHT,img_height do
            lg.draw(dither_2x, x, y)
        end
    end
    lg.setShader()
end

function function_4x_dither()
    lg.setShader(shader_dither)
    local img_width,img_height=dither_4x:getWidth(),dither_4x:getHeight()
    for x=0,CANVAS_WIDTH,img_width do
        for y=0,CANVAS_HEIGHT,img_height do
            lg.draw(dither_4x, x, y)
        end
    end
    lg.setShader()
end

function function_8x_dither()
    lg.setShader(shader_dither)
    local img_width,img_height=dither_8x:getWidth(),dither_8x:getHeight()
    for x=0,CANVAS_WIDTH,img_width do
        for y=0,CANVAS_HEIGHT,img_height do
            lg.draw(dither_8x, x, y)
        end
    end
    lg.setShader()
end

function fillp(_type)
    if _type==nil then
        lg.setStencilTest()
    elseif _type==0 then
        lg.stencil(function_0x_dither, "replace", 1, false)
        lg.setStencilTest("greater", 0)
    elseif _type==1 then
        lg.stencil(function_1x_dither, "replace", 1, false)
        lg.setStencilTest("greater", 0)
    elseif _type==2 then 
        lg.stencil(function_2x_dither, "replace", 1, false)
        lg.setStencilTest("greater", 0)
    elseif _type==3 then 
        lg.stencil(function_4x_dither, "replace", 1, false)
        lg.setStencilTest("greater", 0)
    elseif _type==4 then 
        lg.stencil(function_8x_dither, "replace", 1, false)
        lg.setStencilTest("greater", 0)
    
    end
end