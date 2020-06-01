local button = {
	list =  {}	
}

function button:new(func, text, x, y, width, height)
	self.list[#self.list + 1] = {
		func = func,
		text = text,
		x = x,
		y = y,
		width = width,
		height = height
	}
end

function button:clear()
	self.list = {}
end

function button:draw()
	for i,v in ipairs(self.list) do
		lg.setColor(1, 1, 1, 1)
		lg.rectangle("fill", v.x, v.y, v.width, v.height)

		local textHeight = mainFont:getAscent() - mainFont:getDescent()
		lg.setColor(0, 0, 0, 1)
		lg.rectangle("line", v.x, v.y, v.width, v.height)
		lg.printf(v.text, v.x, v.y + (v.height / 2) - (textHeight / 2), v.width, "center")
	end
end

function button:press(x, y)
	local p = false
	for i,v in ipairs(self.list) do
		if pointInRect(x, y, v.x, v.y, v.width, v.height) then
			if type(v.func) == "function" then
				v.func(v)
				p = true
			end
		end
	end
	return p
end


return button