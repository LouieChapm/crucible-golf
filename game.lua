local Class = require "class"
local Camera = require "camera"

local Game=Class:inherit()

function Game:init()
    camera=Camera:new()


    love.math.setRandomSeed(os.time())

    BACKGROUND_COL=12

    --self:generate_skyscraper()
    --self:generate_skyscraper({30,10,20},{5,4,2})


    for i=1,5 do
        self:generate_skyscraper({lm.random(100)-50,lm.random(20),lm.random(100)-50},{lm.random(10),4,lm.random(10)})
    end
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

function Game:generate_skyscraper(_position, _scale)
    local pos = _position or {0,0,0}
    local scale = _scale or {5,4,5}

    local start_height=pos[2]
    while start_height>-100 do
        table.insert(OBJECTS,camera:create_object(tube,{pos[1],start_height,pos[3]},scale))
        start_height = start_height - 8
    end

    table.insert(OBJECTS,camera:create_object(cube,{pos[1],pos[2]+3,pos[3]},{scale[1]+0.4,1,scale[3]+0.4}))
    
end

return Game