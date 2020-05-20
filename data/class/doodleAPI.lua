_FUNCTIONS = {
	"clear", "mode", "circle", "rect", "line", "noLoop", "loadFile", "size", "randomColor", "color", "background", "normal",
	"lerp", "clamp", "dist", "floor", "ceil", "sin", "cos", "tan", "random", "noise", "angle"
}

--Shortcuts
width = love.graphics.getWidth()
height = love.graphics.getHeight()
floor = math.floor
ceil = math.ceil
sin = math.sin
cos = math.cos
tan = math.tan
--circle = love.graphics.circle
--rect = love.graphics.rectangle
random = math.random
noise = love.math.noise
PI = math.pi
TWO_PI = math.pi * 2

--drawing settings
mainCanvas = lg.newCanvas()
drawMode = "fill"
useLoop = true

--Drawing
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

function line(x, y, x1, y1)
	love.graphics.line(x, y, x1, y1)
end

function noLoop()
	useLoop = false
end

--Setup
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
function randomColor(alpha)
	alpha = alpha or 1
	return {math.random(), math.random(), math.random(), 1}
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
	if not g and not b and not a then
		love.graphics.setColor(r, r, r, 1)
	else
		love.graphics.setColor(r, g, b, a)
	end
	lg.rectangle("fill", 0, 0, mainCanvas:getWidth(), mainCanvas:getHeight())
	--lg.setCanvas()
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