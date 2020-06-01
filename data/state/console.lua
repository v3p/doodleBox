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

	self.height = config.display.height

	self.con:init(0, 0, lg.getWidth(), height, true, mainFont)


	self.con:print("Welcome to "..NAME.."!", "con")
	self.con:print("This is the console, It runs lua code. If you're not sure what to do, Type 'help()'", "info")

	self:switch()
end

function consoleState:switch()
	self:resize(config.display.width, config.display.height)
	self:ui()
end

function consoleState:ui()
	if platform == "mobile" then
		button:clear()
		button:new(bfunc , "EDITOR", 0, config.display.safeHeight, config.display.width, lg.getHeight() * 0.05)
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

	if key == "escape" then
		if currentDoodle then
			state:setState("editor")
		else
			console:print("ERROR: No doodle loaded!", "error")
		end
	end
end

function consoleState:textinput(t)
	self.con:textinput(t)
end

function consoleState:resize(w, h)
	if platform == "mobile" then
		self.height = config.display.safeHeight
	else
		self.height = h
	end
	self.con:resize(w, self.height)
end

function consoleState:mousepressed(x, y, k)
	local bp = button:press(x, y)
	if not bp then
		love.keyboard.setTextInput(not love.keyboard.hasTextInput())
	end
end

return consoleState