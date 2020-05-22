function help()
	local h = {
		{f = "new([name])", e = "Start a new project"},
		{f = "load(name)", e = "Loads a project"},
		{f = "rename(name)", e = "Renames the current project"},
		{f = "delete(name)", e = "PERMANENTLY deletes a project."},
		{f = "ls()", e = "Lists all projects"},
		{f = "openProjectFolder()", e = "Opens the projects folder in your OS"},
		{f = "docs()", e = "Opens your web browser and takes you to the full documentation (Hosted on github)"}
	}

	console:print("Here's some basic functions to get you started!", "con")
	for i,v in ipairs(h) do
		console:print(v.f..": "..v.e, "info")
		if v.w then
			console:print("WARNING: "..v.w, "error")
		end
	end
end

function fontSize(s)
	config.font.size = s
	mainFont = lg.newFont("data/font/"..config.font.face, config.font.size)
	state:getState().con:setFont(mainFont)
	state:getState().con:resize()

	if currentDoodle then
		state:setState("editor")
		state:getState():resize()
		state:setState("console")
	end

	console:print("Font size changed to "..s, "con")
	saveConfig()
end

function safeHeight(height)
	config.display.safeHeight = height
	saveConfig()
	love.event.quit("restart")
end

function listFunctions()
	local line = ""
	local perLine = 5
	local curLine = 0
	console:print("Doodle functions:", "con")
	for i,v in ipairs(_FUNCTIONS) do
		line = line..v.."(), "
		curLine = curLine + 1
		if curLine > perLine then
			console:print(line, "info")
			line = ""
			curLine = 0
		end
	end
end

function reload()
	love.event.quit("restart")
end

function new(name)
	local name = name or "Doodle_"..os.time()
	if fs.getInfo(projectFolder.."/"..name) then
		console:print("ERROR: Doodle '"..name.."' already exists!", "error")
	else
		fs.createDirectory(projectFolder.."/"..name)
		copyFile("data/doodle/main.lua", projectFolder.."/"..name.."/main.lua")
		state:setState("editor")
		state:getState():loadDoodle(name)
	end
end


function renameDoodle(name)
	if currentDoodle then
		if fs.getInfo(projectFolder.."/"..name) then
			console:print("'"..name.."' already exists!")
		else
			fs.createDirectory(projectFolder.."/"..name)
			copyFile(projectFolder.."/"..currentDoodle.."/main.lua", projectFolder.."/"..name.."/main.lua")

			fs.remove(projectFolder.."/"..currentDoodle)

			currentDoodle = name
		end
	end
end

function newFile(name)
	if getFileType(name) ~= ".lua" then
		name = name..".lua"
	end

	if currentDoodle then
		if fs.getInfo(projectFolder.."/"..currentDoodle.."/"..name) then
			console:print("ERROR: File '"..name.."' already exists!", "error")
		else
			local ok = fs.write(projectFolder.."/"..currentDoodle.."/"..name, "")
			if ok then
				console:print("File '"..name.."' created!", "con")
				state:setState("editor")
				state:getState():loadFile(name)
			else
				console:print("ERROR: Couldn't create file!", "error")
			end
		end
	else
		console:print("ERROR: No doodle loaded!", "error")
	end
end

function load(name)
	if name then
		if fs.getInfo(projectFolder.."/"..name)then
			state:setState("editor")
			state:getState():loadDoodle(name)
		else
			console:print("ERROR: Doodle '"..name.."' Does not exist!", "error")
		end
	else
		console:print("ERROR: Doodle '"..tostring(name).."' Does not exist!", "error")
	end
end

function rename(name)
	if currentDoodle then
		if fs.getInfo(projectFolder.."/"..name) then
			console:print("ERROR: '"..name.."' already exists!", "error")
		else
			fs.createDirectory(projectFolder.."/"..name)
			copyFile(projectFolder.."/"..currentDoodle.."/main.lua", projectFolder.."/"..name.."/main.lua")

			fs.remove(projectFolder.."/"..currentDoodle.."/main.lua")
			fs.remove(projectFolder.."/"..currentDoodle)

			currentDoodle = name
			console:print("Doodle renamed to '"..name.."'", "con")
		end
	else
		console:print("ERROR: No doodle loaded!", "error")
	end
end

function delete(name)
	if name then
		if fs.getInfo(projectFolder.."/"..name) then

			for i,v in ipairs(fs.getDirectoryItems(projectFolder.."/"..name)) do
				fs.remove(projectFolder.."/"..name.."/"..v)
			end
			fs.remove(projectFolder.."/"..name)

			console:print("Doodle '"..name.."' permanently deleted", "con")
		else
			console:print("ERROR: '"..name.."' already exists!", "error")
		end
	else
		console:print("ERROR: Doodle '"..tostring(name).."' Does not exist!", "error")
	end
end

function ls()
	console:print("Projects:", "con")
	for i,v in ipairs(fs.getDirectoryItems(projectFolder)) do
		if v ~= ".DS_Store" then
			console:print(v, "info")
		end
	end
end

function openProjectFolder()
	love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/"..projectFolder)
end

function docs()
	love.system.openURL(docsURL)
end

function export()
	if currentDoodle then

		if fs.getInfo(exportFolder.."/"..currentDoodle) then
			--Delete the export if it already exists
			for i,v in ipairs(fs.getDirectoryItems(exportFolder.."/"..currentDoodle)) do
				fs.remove(exportFolder.."/"..currentDoodle.."/"..v)
			end
			fs.remove(exportFolder.."/"..currentDoodle)
		end

		--Embeddin
		--Copying files and such
		fs.createDirectory(exportFolder.."/"..currentDoodle)

		--Copying the doodle API Class
		copyFile("data/class/doodleAPI.lua", exportFolder.."/"..currentDoodle.."/doodleAPI.lua")

		for i,file in ipairs(fs.getDirectoryItems(projectFolder.."/"..currentDoodle)) do
			copyFile(projectFolder.."/"..currentDoodle.."/"..file, exportFolder.."/"..currentDoodle.."/"..file)
		end
		--Modifying main.lua to work with vanilla love
		local main = fs.read(exportFolder.."/"..currentDoodle.."/main.lua")
		--main = 'require("doodleAPI")\n'..main

		main = "currentDoodle = '"..currentDoodle.."'\n"..main
		main = main:gsub("function setup%(%)", "function love.load()\n	require('doodleAPI')")
		main = main:gsub("function update%(dt%)", "function love.update(dt)\n	mouseX, mouseY = love.mouse.getPosition()")
		main = main:gsub("function draw%(%)", "function love.draw()")

		fs.write(exportFolder.."/"..currentDoodle.."/main.lua", main)

		console:print("Exported project '"..currentDoodle.."'", "con")
		love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/"..exportFolder)
	else
		console:print("ERROR: No doodle loaded!", "error")
	end
end
















