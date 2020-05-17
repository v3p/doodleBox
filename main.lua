NAME = "DoodleBox"
VERSION = "0.1"

lg = love.graphics
fs = love.filesystem
kb = love.keyboard

--GLOBALS
projectFolder = "Doodles"

function love.load()
	fs.setIdentity(NAME)
	kb.setKeyRepeat(true)

	require("data.class.util")

	--Setting up / Loading config file
	local w, h = 800, 600
	if platform == "mobile" then
		w, h = love.window.getDesktopDimensions()
	end
	config = {
		display = {
			width = w,
			height = h,
			fullscreen = false,
			windowTitle = NAME.." ["..VERSION.."]",
		}
	}

	--fs.remove("config.lua")

	--Creating config file
	if love.filesystem.getInfo("config.lua") then
		config = fs.load("config.lua")()
	else
		saveConfig()
	end

	--Creating doodle directory
	if not fs.getInfo("Doodles") then
		fs.createDirectory("Doodles")
	end

	--Creating Window
	local resize = true
	if love.system.getOS() == "android" then
		resize = false
	end

	love.window.setMode(config.display.width, config.display.height, {resizable = resize, fullscreen = config.display.fullscreen, display = config.display.display, usedpiscale = false})
	love.window.setTitle(config.display.windowTitle)

	modKey = {"lctrl", "rctrl"}
	if love.system.getOS() == "OS X" then
		modKey = {"lgui", "rgui"}
	end

	--Fonts
	mainFont = lg.newFont("data/font/VCR_OSD_MONO.ttf", love.graphics.getWidth() * 0.026)

	--Loading classes
	requireFolder("data/class")

	--Loading states
	state:loadStates("data/state")

	state:setState("console")

	currentDoodle = false
end

function love.update(dt)
	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()
	state:update(dt)
end

function love.draw()
	state:draw()
end

function love.resize(w, h)
	state:resize(w, h)
end

function love.keypressed(key)
	state:keypressed(key)

	--Quick close
	if key == "escape" then
		if kb.isDown("lshift") then
			love.event.push("quit")
		end

		if state.stateName == "run" then
			--Creating Window
			love.window.setMode(config.display.width, config.display.height, {resizable = true, fullscreen = config.display.fullscreen, display = config.display.display, usedpiscale = false})
			love.window.setTitle(config.display.windowTitle)
			state:setState("editor")
		end
	end

	--Navigation
	if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
		if key == "e" then
			if currentDoodle then
				state:setState("editor")
			else
				console:print("ERROR: No doodle loaded!", "error")
			end
		end
	end
end

function love.textinput(t)
	state:textinput(t)
end

function love.touchpressed(x, y)
	love.keyboard.setTextInput(not love.keyboard.hasTextInput())
end

function love.quit()
	state:quit()
	saveConfig()
end

function saveConfig()
	fs.write("config.lua", tableToString(config))
end
