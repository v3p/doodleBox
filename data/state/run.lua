local run = {}

function run:load()
	useLoop = true
	if type(setup) == "function" then
		local status, err = pcall(setup)
		if not status then
			state:setState("console")
			console:print("ERROR: "..err, "error")
		end
	end
end

function run:update(dt)
	if useLoop then
		if type(update) == "function" then
			local status, err = pcall(update, dt)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
	end
end

function run:draw()
	if useLoop then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setCanvas(mainCanvas)
		if type(draw) == "function" then
			local status, err = pcall(draw)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
		love.graphics.setCanvas()
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(mainCanvas)
end

function run:mousepressed(x, y, k)
	love.window.setMode(config.display.width, config.display.height, {resizable = true, fullscreen = config.display.fullscreen, display = config.display.display, usedpiscale = false})
	love.window.setTitle(config.display.windowTitle)
	state:setState("editor")
end

return run