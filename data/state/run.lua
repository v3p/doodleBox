local run = {}

function run:load()
	love.keyboard.setTextInput(false)
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

function run:keypressed(key)
	if useLoop then
		if type(keypress) == "function" then
			local status, err = pcall(keypress, key)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
	end
end

function run:keyreleased(key)
	if useLoop then
		if type(keyrelease) == "function" then
			local status, err = pcall(keyrelease, key)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
	end
end

function run:mousepressed(x, y, k)
	if useLoop then
		if type(mousepress) == "function" then
			local status, err = pcall(mousepress, x, y, k)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
	end

	if platform == "mobile" then
		love.window.setMode(config.display.width, config.display.height, {resizable = true, fullscreen = config.display.fullscreen, display = config.display.display, usedpiscale = false})
		love.window.setTitle(config.display.windowTitle)
		state:setState("editor")
	end
end

function run:mousereleased(x, y, k)
	if useLoop then
		if type(mouserelease) == "function" then
			local status, err = pcall(mouserelease, key)
			if not status then
				state:setState("console")
				console:print("ERROR: "..err, "error")
			end
		end
	end
end

return run












