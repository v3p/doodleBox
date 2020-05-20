local consoleState = {}

local function bfunc()
	if currentDoodle then
		state:setState("editor")
	else
		console:print("ERROR: No doodle loaded!", "error")
	end
end

function consoleState:load()
	self.con = console

	local height = love.graphics.getHeight()
	if platform == "mobile" then
		height = config.display.safeHeight
	end

	self.con:init(0, 0, lg.getWidth(), height, true, mainFont)


	self.con:print("Welcome to "..NAME.."!", "con")
	self.con:print("This is the console, It runs lua code. If you're not sure what to do, Type 'help()'", "info")

	self:ui()
end

function consoleState:ui()
	if platform == "mobile" then
		button:clear()
		button:new(bfunc , "EDITOR", 0, config.display.safeHeight, lg.getWidth() / 2, lg.getHeight() * 0.1)
	end
end

function consoleState:update(dt)
	self.con:update(dt)
end

function consoleState:draw()
	self.con:draw()

	button:draw()
end

function consoleState:keypressed(key)
	self.con:keypressed(key)
end

function consoleState:textinput(t)
	self.con:textinput(t)
end

function consoleState:resize(w, h)
	self.con:resize(w, h)
	if platform == "mobile" then
		self:load()
	end
end

function consoleState:mousepressed(x, y, k)
	button:press(x, y)
end

return consoleState