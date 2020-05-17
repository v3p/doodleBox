local consoleState = {}

function consoleState:load()
	self.con = console
	self.con:init(0, 0, width, height, true, mainFont)


	self.con:print("Welcome to "..NAME.."!", "con")
	self.con:print("This is the console, It runs lua code. If you're not sure what to do, Type 'help()'", "info")
end

function consoleState:update(dt)
	self.con:update(dt)
end

function consoleState:draw()
	self.con:draw()
end

function consoleState:keypressed(key)
	self.con:keypressed(key)
end

function consoleState:textinput(t)
	self.con:textinput(t)
end

function consoleState:resize(w, h)
	self.con:resize(w, h)
end

return consoleState