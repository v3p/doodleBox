local vec = {}
local vm = {__index = vec}

function vec.new(x, y)
	x = x or 0
	y = y or 0
	local v = {
		x = x,
		y = y
	}
	return setmetatable(v, vm)
end

function vec:set(x, y)
	x = x or 0
	y = y or 0
	self.x = x
	self.y = y
end

function vec:setX(x)
	self.x = x
end

function vec:getX()
	return self.x
end

function vec:setY(y)
	self.y = y
end

function vec:getY()
	return self.y
end

function vec:setAngle(angle)
	local l = self:getLength()
	self.x = math.cos(angle) * l
	self.y = math.sin(angle) * l
end

function vec:getAngle()
	return math.atan2(self.y, self.x)
end

function vec:setLength(length)
	local a = self:getAngle()
	self.x = math.cos(a) * length
	self.y = math.sin(a) * length
end

function vec:getLength()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec:add(v2, dt)
	dt = dt or 1
	self.x = self.x + v2.x
	self.y = self.y + v2.y
end

function vec:sub(v2, dt)
	dt = dt or 1
	self.x = self.x - v2.x
	self.y = self.y - v2.y
end

function vec:mult(v)
	self.x = self.x * v
	self.y = self.y * v
end

function vec:div(v)
	self.x = self.x / v
	self.y = self.y / v
end

function vec.getNormal(v2)
	local l = v2:getLength()
	if l > 0 then
		return vec.new(v2.x / l, v2.y / l)
	else
		return vec.new(0, 0)
	end
end


return vec












