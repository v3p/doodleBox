local editor = {}

local function runButton()
	editor:saveDoodle()
	local status , ret = testCall(fs.load, projectFolder.."/"..currentDoodle.."/main.lua")
	if status then
		ret()
		state:setState("run")
	end
end

local function conButton()
	state:setState("console")
end

local function tabButton()
	editor.currentTab = editor.currentTab + 1
	if editor.currentTab > #editor.tab then
		editor.currentTab = 1
	end
end

function editor:load()
	self.tab = {}
	self.currentTab = 1
	

	self.height = config.display.height

	self:switch()
end

function editor:switch()
	self:resize(config.display.width, config.display.height)
	self:ui()
end

function editor:ui()
	if platform == "mobile" then
		button:clear()
		button:new(runButton , "RUN", 0, self.height, lg.getWidth() / 3, lg.getHeight() * 0.05)
		button:new(conButton , "CONSOLE", (lg.getWidth() / 3), self.height, lg.getWidth() / 3, lg.getHeight() * 0.05)
		button:new(tabButton , "TAB", (lg.getWidth() / 3) * 2, self.height, lg.getWidth() / 3, lg.getHeight() * 0.05)
	end
end

function editor:loadFile(name)
	if fs.getInfo(projectFolder.."/"..currentDoodle.."/"..name) then
		if getFileType(file) == ".lua" then
			self.tab[#self.tab + 1] = {code = codeEditor.new(0, 0, config.display.width, self.height), name = name}
			self.tab[#self.tab].code:init()
			self.tab[#self.tab].code:setFont(mainFont)
			self.tab[#self.tab].code:loadFile(projectFolder.."/"..currentDoodle.."/"..name)
		end
	else
		console:print("ERROR: File '"..name.."' does not exists!", "error")
	end

	if platform == "mobile" then
		self:resize()
	end
end

function editor:unloadFile(name)
	for i,v in ipairs(self.tab) do
		if v.name == name then
			table.remove(self.tab, i)
			if self.currentTab == i then
				self.currentTab = 1
			end
		end
	end
end

function editor:loadDoodle(name)
	self.tab = {}
	for i, file in ipairs(fs.getDirectoryItems(projectFolder.."/"..name)) do
		if getFileType(file) == ".lua" then
			self.tab[i] = {code = codeEditor.new(0, 0, config.display.width, self.height), name = file}
			self.tab[i].code:init()
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
	if #self.tab > 0 then
		self.tab[self.currentTab].code:update()
	end
end

function editor:draw()
	if #self.tab > 0 then
		self.tab[self.currentTab].code:draw()
	end

	if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
		lg.setColor(0, 0, 0, 0.8)
		lg.rectangle("fill", math.floor(config.display.width * 0.7), 0, math.floor(config.display.width / 2), config.display.height)
		lg.setColor(0, 0.5, 1, 1)

		for i,v in ipairs(self.tab) do
			if i == self.currentTab then
				lg.setColor(0, 1, 0, 1)
			else
				lg.setColor(1, 1, 1, 1)
			end
			lg.printf("["..i.."]"..self.tab[i].code.file, lg.getWidth() * 0.71, lg.getHeight() * 0.01 + (self.tab[i].code.fontHeight * i), lg.getWidth(), "left")
		end
	end

	if platform == "mobile" then
		button:draw()
	end

end

function editor:keypressed(key)
	if #self.tab > 0 then
		self.tab[self.currentTab].code:keypressed(key)
	end

	if key == "escape" then
		self:saveDoodle()
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
	if platform == "mobile" then
		self.height = config.display.safeHeight
	else
		self.height = h
	end

	for i,v in ipairs(self.tab) do
		self.tab[i].code:resize(w, self.height)
		self.tab[i].code:updateCursor()
	end
end

function editor:mousepressed(x, y)
	local bp = button:press(x, y)
	if not bp then
		love.keyboard.setTextInput(not love.keyboard.hasTextInput())
	end
end

function editor:quit()
	self:saveDoodle()
end

return editor