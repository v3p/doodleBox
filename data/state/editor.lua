local editor = {}

function editor:load()
	self.tab = {}
	self.currentTab = 1

	self.code = codeEditor.new(0, 0, width, height)
	self.code:setFont(mainFont)
end

function editor:loadFile(name)
	if fs.getInfo(projectFolder.."/"..currentDoodle.."/"..name) then
		self.tab[#self.tab + 1] = {code = codeEditor.new(0, 0, width, height), name = name}
		self.tab[#self.tab].code:setFont(mainFont)
		self.tab[#self.tab].code:loadFile(projectFolder.."/"..currentDoodle.."/"..name)
	else
		console:print("ERROR: File '"..name.."' does not exists!", "error")
	end
end

function editor:loadDoodle(name)
	for i, file in ipairs(fs.getDirectoryItems(projectFolder.."/"..name)) do
		if getFileType(file) == ".lua" then
			self.tab[i] = {code = codeEditor.new(0, 0, width, height), name = file}
			self.tab[i].code:setFont(mainFont)
			self.tab[i].code:loadFile(projectFolder.."/"..name.."/"..file)
		end
	end
	self.currentTab = 1
	currentDoodle = name
end

function editor:saveDoodle()
	if currentDoodle then
		for i,v in ipairs(self.tab) do
			local ok = fs.write(projectFolder.."/"..currentDoodle.."/"..v.name, v.code:stitch())
			if ok then

			else
				console:print("ERROR: Couldn't save file '"..v.name.."'!", "error")
			end
		end
	end
end

function editor:update()
	self.tab[self.currentTab].code:update()
end

function editor:draw()
	self.tab[self.currentTab].code:draw()
end

function editor:keypressed(key)
	self.tab[self.currentTab].code:keypressed(key)

	if key == "escape" then
		state:setState("console")
	end

	if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
		if key == "s" then
			self:saveDoodle()
		elseif key == "r" then
			self:saveDoodle()
			local status , ret = testCall(fs.load, projectFolder.."/"..currentDoodle.."/main.lua")
			if status then
				ret()
				state:setState("run")
			end
		end

		--TAb switching
		if tonumber(key) then
			if self.tab[tonumber(key)] then
				self.currentTab = tonumber(key)
			end
		end
	end
end

function editor:textinput(t)
	self.tab[self.currentTab].code:textinput(t)
end

function editor:resize(w, h)
	self.tab[self.currentTab].code:resize(w, h)
end

function editor:quit()
	self:saveDoodle()
end

return editor