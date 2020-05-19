local editor = {}

function editor:load()
	self.tab = {}
	self.currentTab = 1

	self.height = lg.getHeight()
	if platform == "mobile" then
		self.height = self.height * 0.6
	end
	self.code = codeEditor.new(0, 0, width, self.height)
	self.code:setFont(mainFont)

	self.runBotton = {
		x = 0,
		y = self.height,
		width = lg.getWidth() / 2,
		height = self.height * 0.2
	}
end

function editor:loadFile(name)
	if fs.getInfo(projectFolder.."/"..currentDoodle.."/"..name) then
		self.tab[#self.tab + 1] = {code = codeEditor.new(0, 0, width, self.height), name = name}
		self.tab[#self.tab].code:setFont(mainFont)
		self.tab[#self.tab].code:loadFile(projectFolder.."/"..currentDoodle.."/"..name)
	else
		console:print("ERROR: File '"..name.."' does not exists!", "error")
	end
end

function editor:loadDoodle(name)
	for i, file in ipairs(fs.getDirectoryItems(projectFolder.."/"..name)) do
		if getFileType(file) == ".lua" then
			self.tab[i] = {code = codeEditor.new(0, 0, width, self.height), name = file}
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

	if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
		lg.setColor(0, 0, 0, 0.8)
		lg.rectangle("fill", 0, 0, lg.getWidth(), lg.getHeight())
		lg.setColor(0, 0.5, 1, 1)

		for i,v in ipairs(self.tab) do
			if i == self.currentTab then
				lg.setColor(0, 1, 0, 1)
			else
				lg.setColor(1, 1, 1, 1)
			end
			lg.printf("["..i.."]"..self.tab[i].code.file, lg.getWidth() * 0.01, lg.getHeight() * 0.01 + (self.tab[i].code.fontHeight * i), lg.getWidth(), "left")
		end
	end

	if platform == "mobile" then
		lg.setColor(1, 1, 1, 1)
		lg.rectangle("line", self.runBotton.x, self.runBotton.y, self.runBotton.width, self.runBotton.height)
		lg.printf("RUN", self.runBotton.x, self.runBotton.y, self.runBotton.width, "center")
	end

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

function editor:mousepressed(x, y)
	if pointInRect(x, y, self.runBotton.x, self.runBotton.y, self.runBotton.width, self.runBotton.height) then
		self:saveDoodle()
		local status , ret = testCall(fs.load, projectFolder.."/"..currentDoodle.."/main.lua")
		if status then
			ret()
			state:setState("run")
		end
	end
end

function editor:quit()
	--self:saveDoodle()
end

return editor