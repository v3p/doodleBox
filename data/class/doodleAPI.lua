_FUNCTIONS = {
	"clear", "mode", "circle", "rect", "polygon", "line", "noLoop", "loadFile", "size", "randomColor", "color", "background", "normal",
	"lerp", "clamp", "dist", "floor", "ceil", "sin", "cos", "tan", "random", "noise", "angle", "newCanvas", "setCanvas", "print", "text",
	"textf", "keyDown", "setup", "update", "draw", "keypressed", "keyreleased"
}

_GLOBALS = {
	"PI", "TWOPI", "width", "height", "mouseX", "mouseY"
}

--Shortcuts
width = love.graphics.getWidth()
height = love.graphics.getHeight()
floor = math.floor
ceil = math.ceil
sin = math.sin
cos = math.cos
tan = math.tan
random = math.random
draw = love.graphics.draw
text = love.graphics.print
textf = love.graphics.printf
noise = love.math.noise
PI = math.pi
TWO_PI = math.pi * 2

--these are for my lazy ass not the user
lg = love.graphics
fs = love.filesystem
kb = love.keyboard

--drawing settings
mainCanvas = lg.newCanvas()
drawMode = "fill"
useLoop = true

--GRAPHICS
function clear()
	love.graphics.clear()
end

function mode(m)
	if m == "fill" or m == "line" then
		drawMode = m
	else
		error("Invalid draw mode! Use 'fill' or 'line'")
	end
end

function circle(x, y, radius, segments)
	love.graphics.circle(drawMode, x, y, radius, segments)
end

function rect(x, y, width, height)
	love.graphics.rectangle(drawMode, x, y, width, height)
end

function polygon(v)
	love.graphics.polygon(drawMode, v)
end

function line(x, y, x1, y1)
	love.graphics.line(x, y, x1, y1)
end

function noLoop()
	useLoop = false
end

--Color
function randomColor()
	return {math.random(), math.random(), math.random()}
end

function color(r, g, b, a)
	if not g and not b and not a then
		love.graphics.setColor(r, r, r, 1)
	else
		love.graphics.setColor(r, g, b, a)
	end
end

function background(r, g, b, a)
	--lg.setCanvas(mainCanvas)
	local _r, _g, _b, _a = love.graphics.getColor()
	if not g and not b and not a then
		lg.setColor(r, r, r, 1)
	else
		lg.setColor(r, g, b, a)
	end
	lg.rectangle("fill", 0, 0, mainCanvas:getWidth(), mainCanvas:getHeight())
	
	lg.setColor(_r, _g, _b, _a)
end

--DEBUG
function print(t)
	console:print(currentDoodle..": "..t, "run")
end

--Setup
function loadFile(file)
	local f = file
	if getFileType(file) ~= ".lua" then
		f = file..".lua"
	end
	return fs.load(projectFolder.."/"..currentDoodle.."/"..f)()
end

function size(_width, _height)
	local w, h, flags = love.window.getMode()

	love.window.setMode(_width, _height, flags)
	love.window.setTitle(currentDoodle)
	width = _width
	height = _height
end

function newCanvas(w, h)
	return lg.newCanvas(w, h)
end

function setCanvas(c)
	if c then
		lg.setCanvas(c)
	else
		lg.setCanvas(mainCanvas)
	end
end

--Math
function normal(val, min, max)
	return (val - min) / (max - min)
end

function lerp(val, min, max)
	return (max - min) * val + min
end

function clamp(val, min, max)
	return math.max(min, math.min(val, max))
end

function dist(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function angle(x1, y1, x2, y2)
	return math.atan2(y2-y1, x2-x1)
end

--Pixel functions
function getPixels()
	local can = lg.getCanvas()
	lg.setCanvas()
	local data = mainCanvas:newImageData()
	local t = {}
	for y=1, data:getHeight() do
		t[y] = {}
		for x=1, data:getWidth() do
			local r, g, b, a = data:getPixel(x-1, y-1)
			t[y][x] = {r = r, g = g, b = b, a = a}
		end
	end

	lg.setCanvas(can)
	return t
end

function setPixels(t)
	local data = love.image.newImageData(#t[1], #t)
	for y=1, data:getHeight() do
		for x=1, data:getWidth() do
			local pixel = t[y][x]
			t[y][x] = data:setPixel(x - 1, y - 1, pixel.r, pixel.g, pixel.b, pixel.a)
		end
	end

	local img = lg.newImage(data)
	lg.setColor(1, 1, 1, 1)
	lg.draw(img)
end

--INPUT
function keyDown(key)
	return love.keyboard.isDown(key)
end

--CALLBACKS (for exporting)
function updateGlobals()
	mouseX = love.mouse.getX()
	mouseY = love.mouse.getY()
end
















