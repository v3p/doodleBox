local run = {}

function run:load()
	if type(setup) == "function" then
		local status, err = pcall(setup)
		if not status then
			state:setState("console")
			console:print("ERROR: "..err, "error")
		end
	end
end

function run:update(dt)
	if type(update) == "function" then
		local status, err = pcall(update, dt)
		if not status then
			state:setState("console")
			console:print("ERROR: "..err, "error")
		end
	end
end

function run:draw()
	if type(draw) == "function" then
		local status, err = pcall(draw)
		if not status then
			state:setState("console")
			console:print("ERROR: "..err, "error")
		end
	end
end

return run