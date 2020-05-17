function help()
	local h = {
		{f = "new([name])", e = "Creates a new doodle and takes you to the code editor", c = 'new("Mydoodle")'},
		{f = "load(name)", e = "Loads a doodle", c = 'load("Mydoodle")'},
		{f = "rename(name)", e = "Renames the current doodle", c = 'rename("AmazingDoodle34")'},
		{f = "delete(name)", e = "PERMANENTLY deletes a doodle.", c = 'delete("f**k this doodle")', w = "THIS IS IRREVERSABLE."},
		{f = "run(name)", e = "Runs a doodle", c = 'run("Mydoodle")'},
		{f = "ls()", e = "Lists all doodles", c = 'ls()'},
		{f = "showDoodles()", e = "Opens the doodles folder in your OS", c = 'showDoodles()'}
	}

	console:print("")
	console:print("Here's some basic functions", "con")
	console:print("Any argument with [square brackets] around it is optional", "altInfo")
	for i,v in ipairs(h) do
		console:print("'"..v.f.."': "..v.e, "info")
		console:print("Example: "..v.c, "altInfo")
		if v.w then
			console:print("WARNING: "..v.w, "error")
		end
		console:print("")
	end

	console:print("The full documentation is available online somewhere (:", "altInfo")
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
		state:setState("console")
		console:print("Doodle '"..name.."' created!", "con")
		console:print("Press 'ctrl + e' to enter the editor", "con")
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

			fs.remove(projectFolder.."/"..name.."/main.lua")
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
	console:print("Doodles:", "con")
	for i,v in ipairs(fs.getDirectoryItems("Doodles")) do
		if v ~= ".DS_Store" then
			console:print(v, "info")
		end
	end
end

function showDoodles()
	love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/"..projectFolder)
end

function export()
--compressedData = love.data.compress( container, format, rawstring, level )
	local fdata = fs.newFileData(projectFolder.."/"..currentDoodle.."/main.lua")
	local d = love.data.compress("string", "zlib", fdata, -1)
	fs.write("test.zip", d)
end

function editor()
	state:setState("editor")
end