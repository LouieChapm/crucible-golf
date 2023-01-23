local Class = require "class"
local Camera = require "camera"

local Game=Class:inherit()

function Game:init()
    camera=Camera:new()


    love.math.setRandomSeed(9)--os.time())

    BACKGROUND_COL=12

    self:generate_skyscraper()
end

function Game:update()
    camera:update(fdt)


    local debug_pos={tonumber(string.format("%.1f", cam.position[1])),tonumber(string.format("%.1f", cam.position[2])),tonumber(string.format("%.1f", cam.position[3]))}
    --debug = table.concat(debug_pos,",")
end

function Game:draw()
    camera:draw()
end


-- generatation code -- 

function Game:generate_skyscraper(_spawn_position)
    local pos = _spawn_position or {0,0,0}

    local start_height=pos[2]
    while start_height>-100 do
        table.insert(OBJECTS,camera:create_object(tube,{pos[1],start_height,pos[3]},{5,4,5}))
        start_height = start_height - 8
    end

    table.insert(OBJECTS,camera:create_object(cube,{pos[1],pos[2]+3,pos[3]},{5.2,1,5.2}))
    
end

return Game