--Shortcuts
width = love.graphics.getWidth()
height = love.graphics.getHeight()
floor = math.floor
ceil = math.ceil
sin = math.sin
cos = math.cos
tan = math.tan
circle = love.graphics.circle
rect = love.graphics.rectangle
random = math.random
noise = love.math.noise
PI = math.pi
TWO_PI = math.pi * 2

--Shape

function loadFile(file)
	local f = file
	if getFileType(file) ~= ".lua" then
		f = file..".lua"
	end
	return fs.load(projectFolder.."/"..currentDoodle.."/"..f)()
end

function size(width, height)

	local w, h, flags = love.window.getMode()

	love.window.setMode(width, height, flags)
	love.window.setTitle(currentDoodle)
	width = width
	height = height
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
	if not g and not b and not a then
		love.graphics.setBackgroundColor(r, r, r, 1)
	else
		love.graphics.setBackgroundColor(r, g, b, a)
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