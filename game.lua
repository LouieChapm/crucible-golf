local Class = require "class"
local Camera = require "camera"

local Game=Class:inherit()

function Game:init()
    camera=Camera:new()

    love.math.setRandomSeed(9)--os.time())

    BACKGROUND_COL=12
end

function Game:update()
    camera:update(fdt)
end

function Game:draw()
    camera:draw()
end


return Game