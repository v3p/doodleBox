NAME = "DoodleBox"
VERSION = "0.1"
--DEbugging
FORCE_MOBILE = false 
IGNORE_CONFIG = false

--Shortcuts cause i'm lazy
lg = love.graphics
fs = love.filesystem
kb = love.keyboard

--GLOBALS
projectFolder = "Projects"
exportFolder = "Export"
docsURL = "https://github.com/v3p/doodleBox/wiki"


platform = "pc"
if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
	platform = "mobile"
end

if FORCE_MOBILE then
	platform = "mobile"
end

function love.load()
	fs.setIdentity(NAME)
	kb.setKeyRepeat(true)
	lg.setDefaultFilter("nearest", "nearest")

	modKey = {"lctrl", "rctrl"}
	modKeyName = "ctrl"
	if love.system.getOS() == "OS X" then
		modKey = {"lgui", "rgui"}
		modKeyName = "cmd"
	end

	require("data.class.util")

	--Setting up / Loading config file
	local w, h = 649, 460

	--Flipping width and height for mobile so it goes portrait
	if platform == "mobile" then
		local _w = w
		w = h
		h = _w
	end

	config = {
		display = {
			width = w,
			height = h,
			fullscreen = false,
			windowTitle = NAME.." ["..VERSION.."]",
			safeHeight = math.floor(h * 0.5)
		},
		font = {
			face = "basis33.ttf",
			size = 24
		}
	}

	if IGNORE_CONFIG then
		fs.remove("config.lua")
	end
	--Creating config file
	if love.filesystem.getInfo("config.lua") then
		config = fs.load("config.lua")()
	else
		saveConfig()
	end

	--Creating project directory
	if not fs.getInfo(projectFolder) then
		fs.createDirectory(projectFolder)
	end
	--Creating project directory
	if not fs.getInfo(exportFolder) then
		fs.createDirectory(exportFolder)
	end

	--Creating Window
	local resize = true
	if platform == "mobile" then
		resize = false
	end

	love.window.setMode(config.display.width, config.display.height, {resizable = resize, fullscreen = config.display.fullscreen, display = config.display.display, usedpiscale = false})
	love.window.setTitle(config.display.windowTitle)

	--Fonts
	mainFont = lg.newFont("data/font/"..config.font.face, config.font.size)
	mainFont:setFilter("nearest", "nearest")

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
	config.display.width = w
	config.display.height = h
	width = config.display.width
	height = config.display.height
	mainCanvas = lg.newCanvas(config.display.width, config.display.height)
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

end

function love.textinput(t)
	state:textinput(t)
end

function love.mousepressed(x, y, k)
	state:mousepressed(x, y, k)
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
