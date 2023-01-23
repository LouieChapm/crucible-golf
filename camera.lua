local Class = require "class"
local Shapes = require "shapes"

local Camera=Class:inherit()

-- file that contains all scripts required to run a 3d camera

palette = {
	{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15},
	{0, 1, 2, 3, 2, 5, 6, 7, 8, 4, 9, 11, 12, 13, 14, 9},
	{0, 1, 1, 3, 2, 1, 13, 6, 2, 3, 4, 3, 13, 5, 4, 4},
	{0, 0, 1, 1, 1, 1, 5, 13, 2, 2, 2, 3, 5, 1, 2, 2},
}

function Camera:init()
    cursor_lock=lock
    love.mouse.setVisible(not cursor_lock)

    mouse_x_sensitivity=1
    mouse_y_sensitivity=1
    love.mouse.setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5) -- set cursor to center of screen

    OBJECTS={}
    light={0,10,10}
    cam={
        position={0,20,0},
        dir={0,0,0},

        pitch=0.7,
        yaw=0,
    }
    move_speed=0.2

    mult=CANVAS_WIDTH/2
end

function Camera:update()
    if cursor_lock then 
        self:camera_control()
    else
        local dist=30
        cam.position[1]=sin(t)*dist
        cam.position[3]=cos(t)*dist
        cam.yaw=-sin(t)
    end 

    

    self:update_engine()
end

function love.keypressed(key)
    if key == "tab" then
       cursor_lock = not cursor_lock
       love.mouse.setVisible(not cursor_lock)
    end
 end

function Camera:draw()
    for _,obj in ipairs(OBJECTS) do
        for _,tri in ipairs(obj.render_triangles) do
			-- create new triangles at offset

			local nt = {}
			nt[1] = add_vec(tri[1], obj.position)
			nt[2] = add_vec(tri[2], obj.position)
			nt[3] = add_vec(tri[3], obj.position)

            local t1,t2,t3=self:multiply_view_matrix(nt[1]),self:multiply_view_matrix(nt[2]),self:multiply_view_matrix(nt[3])

            if t1[3] > 0.1 and t2[3] > 0.1 and t3[3] > 0.1 then
                local x1,y1=self:project(t1)
                local x2,y2=self:project(t2)
                local x3,y3=self:project(t3)

                -- backface culling
                if self:shoelace_culling(x1,y1,x2,y2,x3,y3)<=0 then

                    local c=7
                    local dark_level,a = self:calculate_light(nt, light, c)
                    a=(#palette-1)*a

                    -- depth shading
                    if obj.position[2] < -30 then fillp(0) end
                    if obj.position[2] < -40 then fillp(1) end
                    if obj.position[2] < -48 then fillp(2) end
                    if obj.position[2] < -54 then fillp(3) end
                    if obj.position[2] < -60 then fillp(4) end

                    lg.setColour(pal(palette[dark_level][c+1]))
                    lg.polygon("fill",x1,y1,x2,y2,x3,y3)


                    if a%1<0.5 and dark_level<#palette then 
                        fillp(1) 

                        lg.setColour(pal(palette[dark_level+1][c+1]))
                        lg.polygon("fill",x1,y1,x2,y2,x3,y3)
                    end


                    fillp()
                end
            end
		end
    end
end


-- functions --

-- allows the player to control the camera using wasd
function Camera:camera_control()
    local speed=0.2

    local move_dir={0,0,0}
    if love.keyboard.isDown("w") then
        move_dir[3]=1
    end
    if love.keyboard.isDown("s") then
        move_dir[3]=-1
    end

    if love.keyboard.isDown("a") then
        move_dir[1]=1
    end
    if love.keyboard.isDown("d") then
        move_dir[1]=-1
    end
    self:move_camera(move_dir)


    if love.keyboard.isDown("space") and cursor_lock then
        cam.position[2]=cam.position[2]+speed
    end
    if love.keyboard.isDown("lshift") and cursor_lock then
        cam.position[2]=cam.position[2]-speed
    end

    if cursor_lock then
        local setX,setY=SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5

        local dx=love.mouse.getX()-setX
        local dy=love.mouse.getY()-setY

        cam.yaw=cam.yaw-(dx*0.001*mouse_x_sensitivity)
        cam.pitch=cam.pitch+(dy*0.001*mouse_y_sensitivity)

        love.mouse.setPosition(setX,setY)
    end
end

-- create object and appent it to the list
function Camera:create_object(_shape, _position, _scale, _rotation)
    local obj={}

    -- default positions
    obj.position=_position or {0,0,0}
    obj.scale=_scale or {1,1,1}
    obj.rotation=_rotation or {0,0,0}

    obj.triangles={}
    for _,tri in ipairs(_shape) do


        local new_tri={}
        for i=1,3 do
            table.insert(new_tri,{tri[i][1],tri[i][2],tri[i][3]})
        end
        table.insert(obj.triangles,new_tri)
    end

    obj.render_triangles={}

    return obj
end

function Camera:update_engine()
    for _,obj in ipairs(OBJECTS) do
        self:create_render_object(obj)
        self:rotate_shape(obj)
    end

    self:drawing_order(OBJECTS)
    self:calculate_view_matrix()
end

function Camera:create_render_object(_obj)
    local new_object={}

	for _,tri in ipairs(_obj.triangles) do	-- get every triangle in original object

		local nt={} -- new triangle
		for i=1,3 do	-- scale them by _obj.scale
		
			local np=self:scale_vectors(tri[i],_obj.scale)		-- this doesn't :///////
			table.insert(nt,np)
		end

		-- rotate them by _obj.rot
		table.insert(new_object,nt)
	end

	_obj.render_triangles=new_object
end

function Camera:drawing_order(_object)
	for _,obj in ipairs(OBJECTS) do
		local tri = obj.render_triangles
		local _x,_y,_z = 0,0,0		
		for i=1,#tri do
			tri[i].b={(tri[i][1][1]+tri[i][2][1]+tri[i][3][1]+3*obj.position[1])/3,
					  (tri[i][1][2]+tri[i][2][2]+tri[i][3][2]+3*obj.position[2])/3,
					  (tri[i][1][3]+tri[i][2][3]+tri[i][3][3]+3*obj.position[3])/3}
			_x,_y,_z=_x+tri[i].b[1],_y+tri[i].b[2],_z+tri[i].b[3]
		end
		_x,_y,_z=_x/#tri,_y/#tri,_z/#tri		
		tri = insertion_sort(tri)
		obj.b = {_x,_y,_z}
	end

	OBJECTS = insertion_sort(OBJECTS)
end

-- backface culling
-- negative area means the triangle is facing away from camera
-- coincidentally also calculates area
function Camera:shoelace_culling(x1,y1,x2,y2,x3,y3)
    return (x1*y2-y1*x2)+(x2*y3-y2*x3)+(x3*y1-y3*x1) -- this is blowing my mind tbh
end 

-- sorts objects by distance to camera
-- not a great way of doing it though
function insertion_sort(a)
	local j=0
	for i=1,#a do
		local e = a[i]
		j = i-1

		while j>=1 and dist_3d(e.b,cam.position) > dist_3d(a[j].b,cam.position) do
			a[j+1]=a[j]
			j = j-1
		end
		if j ~= i-1 then
			a[j+1] = e
		end
	end

	return a
end

function dist_3d(p1,p2)
	return math.sqrt((p1[1]-p2[1])*(p1[1]-p2[1]) + (p1[2]-p2[2])*(p1[2]-p2[2]) + (p1[3]-p2[3])*(p1[3]-p2[3]))
end

function Camera:calculate_view_matrix()
    local pitch,yaw=cam.pitch,cam.yaw
    local eye=cam.position
    
    local cosp,sinp,cosy,siny=
            cos(pitch),sin(pitch),
            cos(yaw),sin(yaw)

    local x,y,z = {cosy,0,-siny},
                    {siny*sinp,cosp,cosy*sinp},
                    {siny*cosp,-sinp,cosp*cosy}

    view_matrix = {
        {x[1],y[1],z[1],0},
        {x[2],y[2],z[2],0},
        {x[3],y[3],z[3],0},
        {-dot_product(x,eye),-dot_product(y,eye),-dot_product(z,eye),1}}
end

function Camera:move_camera(_d)
	local dir = _d
	local pdir = cam.dir	

    self:rotate_point(dir,"x",cam.pitch)
	self:rotate_point(dir,"y",cam.yaw)
	dir=normalize(dir)
    dir=mul_vec(dir,move_speed)

	cam.position = add_vec(cam.position,dir)
	cam.dir=pdir
end

--[[
    t = tri
    l = light source
    c = colour
]]--
function Camera:calculate_light(t, l, c)
    local l=mul_vec(l,-1)

	local v1,v2 = sub_vec(t[2], t[1]),sub_vec(t[3], t[1])
	local n = normalize(cross_product(v1, v2))
	local nl = normalize({-l[1], -l[2], -l[3]})
	local angle = dot_product(nl,n) / (length_vec(n) * length_vec(nl))

	angle = angle + 1
	angle = angle / 2
	angle = math.abs(angle)


    --return palette[#palette - math.floor((#palette-1)*angle)][c+1],angle
    return #palette - math.floor((#palette-1)*angle),angle
end


        -- VECTOR MATHEMATICS SECTION --
    -- TODO MAYBE MOVE THIS TO A NEW FILE ?? -- 

function Camera:multiply_view_matrix(_vector3)
    local v=_vector3

	return {
	v[1]*view_matrix[1][1] + v[2]*view_matrix[2][1] + v[3]*view_matrix[3][1] + view_matrix[4][1],
	v[1]*view_matrix[1][2] + v[2]*view_matrix[2][2] + v[3]*view_matrix[3][2] + view_matrix[4][2],
	v[1]*view_matrix[1][3] + v[2]*view_matrix[2][3] + v[3]*view_matrix[3][3] + view_matrix[4][3],
	v[1]*view_matrix[1][4] + v[2]*view_matrix[2][4] + v[3]*view_matrix[3][4] + view_matrix[4][4],
	}
end

--[[
	-- point
	-- angle "x", "y", or "z"
	-- rotation amount
	-- center (ignore largely)
]]--
function Camera:rotate_point(p,a,r,c)
	if c then
	  p[1]=p[1]-c[1]
	  p[2]=p[2]-c[2]
	  p[3]=p[3]-c[3]
	end
	local x,y,z=1,2,3

	if 		a=="z" then x,y,z=1,2,3
	elseif 	a=="y" then x,y,z=3,1,2
	elseif 	a=="x" then x,y,z=2,3,1
	end
  -- figure out which axis we're rotating on
  local _x = cos(r)*(p[x]) - sin(r) * (p[y]) -- calculate the new x location
  local _y = sin(r)*(p[x]) + cos(r) * (p[y]) -- calculate the new y location

  p[x] = _x
  p[y] = _y
  p[z] = p[z]

  if c then
	  p[1]=p[1]+c[1]
	  p[2]=p[2]+c[2]
	  p[3]=p[3]+c[3]
  end
end

-- figure out how this works
function Camera:project(p)
    local x,y=0,0

    if math.abs(p[3])<=0.1 then
        x=0
    else
        x=-mult*(p[1])/(p[3])+CANVAS_WIDTH/2
    end

    if math.abs(p[3])<=0.1 then
        y=0
    else
        y=-mult*(p[2])/(p[3])+CANVAS_HEIGHT/2
    end

	return x,y
end

function dot_product(_v1,_v2)
    return _v1[1]*_v2[1] + _v1[2]*_v2[2] + _v1[3]*_v2[3]
end

function cross_product(v1, v2)
	return {v1[2]*v2[3] - v1[3]*v2[2],
			v1[3]*v2[1] - v1[1]*v2[3],
			v1[1]*v2[2] - v1[2]*v2[1]}
end

-- multiple a vector by a vector
function Camera:scale_vectors(v1, v2)
	return {v1[1]*math.abs(v2[1]),v1[2]*math.abs(v2[2]),v1[3]*math.abs(v2[3])}
end


function Camera:rotate_shape(_o)
	local directions=split"x,y,z"

	for d=1,3 do
		local dir=directions[d]
		for _,t in ipairs(_o.render_triangles) do
			for p=1,3 do
				self:rotate_point(t[p],dir,_o.rotation[d])
			end
		end
	end
end

-- add two vectors together
function add_vec(v1, v2)
	return {v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]}
end

-- multiple a vector by a float
function mul_vec(v, a)
	return {v[1]*a,v[2]*a,v[3]*a}
end

function sub_vec(v1, v2)
	return {v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]}
end

function normalize(v)
	local l = length_vec(v) -- get the average scale of each three vectors
	return l == 0 and {0,0,0} or {v[1]/l,v[2]/l,v[3]/l} -- divide x,y,z by the "l" to set max scale to one :)
end

-- gets the length that the vector is on average , in total
-- combined with normalizing
function length_vec(v)
	return math.sqrt(v[1]*v[1] + v[2]*v[2] + v[3]*v[3])
end

return Camera