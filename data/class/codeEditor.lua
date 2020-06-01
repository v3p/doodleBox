local utf8 = require("utf8")

local lg = love.graphics
local fs = love.filesystem

local codeEditor = {}
local codeEditor_meta = {__index = codeEditor}	

local default_style = {
	color = {
		background = {0.1, 0.1, 0.1, 1},
		panel = {0.2, 0.2, 0.2, 1},
		text = {1, 1, 1, 1},
		cursor = {1, 1, 1, 1},
		lineNumberBackground = {0.04, 0.04, 0.04, 1},
		lineNumber = {0.4, 0.4, 0.4, 1}
	},
	font = lg.newFont(14),
	sideMargin = 24,
	topMargin = 24
}

local syntaxColor = {
	text = {0.9, 0.9, 0.9, 1},
	keyword = convertColor(0, 211, 100, 255),
	symbol = {0.9, 0.9, 0.9, 1},
	string = convertColor(245, 43, 162, 255),
	number = convertColor(227, 173, 57, 255),
	functions = convertColor(58, 190, 254, 255),
	globals = convertColor(224, 91, 91, 255),
	comment = {0, 1, 1, 1}
}

local _LUA_FUNCTIONS = {
	
}

function codeEditor:init()
	self.keywords = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", 
				      "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "pairs", "ipairs", "self"}

	self.functions = _FUNCTIONS
	self.globals = _GLOBALS


	self.symbols = {"+", "-", "*", "/", "%", "^", "#", "=", "==", "=>", "<=", "~", 
					 "<", ">", "(", ")", "{", "}", "[", "]", ";", ":", ",", "."}
end

--Various helper functions
--STRING FUNCTIONS	
local function getCharBytes(string, char)
	char = char or 1
	local b = string.byte(string, char)
	b = b or 0
	local bytes = 1
	if b > 0 and b <= 127 then
      bytes = 1
   elseif b >= 194 and b <= 223 then
      bytes = 2
   elseif b >= 224 and b <= 239 then
      bytes = 3
   elseif b >= 240 and b <= 244 then
      bytes = 4
   end
	return bytes
end

local function utf8len(str)
	local pos = 1
	local len = 0
	while pos <= #str do
		len = len + 1
		pos = pos + getCharBytes(str, pos)
	end
	return len
end

local function utf8sub(str, s, e)
	s = s or 1
	e = e or console.len(str)

	if s < 1 then s = 1 end
	if e < 1 then e = console.len(str) + e + 1 end
	if e > utf8len(str) then e = utf8len(str) end

	if s > e then return "" end

	local sByte = 0
	local eByte = 1

	local pos = 1
	local i = 0
	while pos <= #str do
		i = i + 1
		if i == s then
			sByte = pos
		end
		pos = pos + getCharBytes(str, pos)
		if i == e then
			eByte = pos - 1
			break
		end
	end

	return string.sub(str, sByte, eByte)
end

--Syntax highligting helpers
function codeEditor:isKeyword(w)
	local is = false
	for k,v in pairs(self.keywords) do
		if w == v then
			is = true
			break
		end
	end
	return is
end

function codeEditor:isGlobal(w)
	local is = false
	for k,v in pairs(self.globals) do
		if w == v then
			is = true
			break
		end
	end
	return is
end

function codeEditor:isSymbol(w)
	local is = false
	for k,v in pairs(self.symbols) do
		if w == v then
			is = true
			break
		end
	end
	return is
end

function codeEditor:isFunction(w)
	local is = false
	for k,v in pairs(self.functions) do
		if w == v then
			is = true
			break
		end
	end
	return is
end 

function codeEditor:stitch()
	local out = ""
	for i,v in ipairs(self.linesRaw) do
		out = out..v.."\n"
	end

	return out
end

function codeEditor.new(x, y, width, height, style)
	style = style or default_style

	local e = {
		x = x,
		y = y,
		--These refer to where the cursor is drawn!
		cursorX = 0,
		cursorY = 0,
		width = width,
		height = height,
		style = style,

		linesRaw = {""},
		linesHighlight = {},

		currentLine = 1,
		currentLinePosition = 0,

		cursor = {
			--These are for editing text 
			line = 1,
			position = 0,
			--These are for drawing
			x = 0,
			y = 0,
			width = style.font:getWidth("a")
		},

		scroll = {
			x = 1,
			y = 1
		},

		file = "untitled"
	}
	e.fontHeight = e.style.font:getAscent() - e.style.font:getDescent()
	e.style.margin = e.style.font:getWidth("9999")
	e.visibleLines = math.floor((height - (e.style.margin * 2)) / (style.font:getAscent() - style.font:getDescent()) ) - 1

	return setmetatable(e, codeEditor_meta)
end

function codeEditor:highlight()
	self.linesHighlight = {}
	local to = self.visibleLines + self.scroll.y
	if #self.linesRaw < to then
		to = #self.linesRaw
	end
	for i=self.scroll.y, to do--for i,v in ipairs(self.linesRaw) do
		line = self.linesRaw[i]
		local list = {}
		local currentWord = ""
		local lastChar = ""
		for i=1, utf8len(line) do
			local currentChar = utf8sub(line, i, i)
			if currentChar:match("%w") or comment then
				currentWord = currentWord..currentChar
			else
				list[#list + 1] = currentWord
				list[#list + 1] = currentChar
				currentWord = ""
			end
			if i == utf8.len(line) then
				if #currentWord > 0 then
					list[#list + 1] = currentWord
				end
			end
			lastChar = currentChar
		end

		local textList = {}
		local last = ""
		local isString = false
		local isComment = false
		for i,v in ipairs(list) do
			if self:isKeyword(v) and not isString then
				textList[#textList + 1] = syntaxColor.keyword
				textList[#textList + 1] = v
			elseif self:isSymbol(v) and not isString then
				textList[#textList + 1] = syntaxColor.symbol
				textList[#textList + 1] = v
			elseif self:isFunction(v) and not isString then
				textList[#textList + 1] = syntaxColor.functions
				textList[#textList + 1] = v
			elseif self:isGlobal(v) and not isString then
				textList[#textList + 1] = syntaxColor.globals
				textList[#textList + 1] = v
			elseif tonumber(v) and not isString then
				textList[#textList + 1] = syntaxColor.number
				textList[#textList + 1] = v
			elseif last == '"' then
				textList[#textList + 1] = syntaxColor.string
				textList[#textList + 1] = v
				isString = not isString
			elseif isString then
				textList[#textList + 1] = syntaxColor.string
				textList[#textList + 1] = v
			elseif v == '"' or v == "'" or v == "[" or v == "]" then
				textList[#textList + 1] = syntaxColor.string
				textList[#textList + 1] = v
			else
				textList[#textList + 1] = syntaxColor.text
				textList[#textList + 1] = v
			end


			last = v
		end
		self.linesHighlight[#self.linesHighlight + 1] = lg.newText(self.style.font, textList)
	end
end

function codeEditor:loadFile(path)
	self.linesRaw = {}
	if fs.getInfo(path) then
		local lc = 0
		for line in fs.lines(path) do
			if #line < 1 then
				line = ""
			end
			self.linesRaw[#self.linesRaw + 1] = line
			lc = lc + 1
		end
		if lc < 1 then
			self.linesRaw[1] = ""
		end
		self.file = path:match("%w+.lua")
		self:updateCursor()
	else
		error("'"..path.."' does not exists.")
	end
end

function codeEditor:setFont(font)
	self.style.font = font
	self.fontHeight = self.style.font:getAscent() - self.style.font:getDescent()
	self.cursorWidth = self.style.font:getWidth("a")
	self.style.sideMargin = self.style.font:getWidth("9999")
	self.style.topMargin = self.fontHeight * 1.5
	self.visibleLines = math.floor((self.height - (self.style.topMargin * 2)) / (self.style.font:getAscent() - self.style.font:getDescent()) ) - 1

end

function codeEditor:updateCursor()
	local line = self.linesRaw[self.cursor.line]
	local lineStart = utf8sub(line, 0, self.cursor.position)
	local lineEnd = utf8sub(line, self.cursor.position+1, #line)

	if self.style.font:getWidth(lineStart) > self.width - self.style.sideMargin then
		self.scroll.x = (self.width - self.style.sideMargin) - self.style.font:getWidth(lineStart) - self.cursor.width
	else
		self.scroll.x = 0
	end

	
	if self.cursor.line - (self.scroll.y) >= self.visibleLines then
		self.scroll.y = self.cursor.line - (self.visibleLines)
	elseif self.cursor.line - (self.scroll.y) < 0 then
		self.scroll.y = self.cursor.line
	end


	self.cursor.x = self.x + self.scroll.x + self.style.sideMargin + self.style.font:getWidth(utf8sub(self.linesRaw[self.cursor.line], 1, self.cursor.position))
	self.cursor.y = self.y + self.style.topMargin + (self.fontHeight * (self.cursor.line - self.scroll.y))

	if self.cursor.position == 0 then
		self.cursor.x = self.x + self.scroll.x + self.style.sideMargin
	end
end

function codeEditor:update(dt)
	self:highlight()
end

function codeEditor:draw()
	lg.setScissor(self.x, self.y, self.width, self.height)
	--Bacgkround
	lg.setColor(self.style.color.background)
	lg.rectangle("fill", self.x, self.y, self.width, self.height)

	--Side Panel
	lg.setColor(self.style.color.lineNumberBackground)
	lg.rectangle("fill", self.x, self.y, self.style.sideMargin, self.height)

	--Top Panel
	lg.setColor(self.style.color.panel)
	lg.rectangle("fill", self.x, self.y, self.width, self.style.topMargin)

	--Bottom Panel
	lg.setColor(self.style.color.panel)
	lg.rectangle("fill", self.x, self.y + self.height - self.style.topMargin, self.width, self.style.topMargin)

	--Info
	lg.setColor(1, 1, 1, 1)
	lg.printf(self.currentLine.."/"..#self.linesRaw, 0, self.y + self.height - self.style.topMargin + (self.style.topMargin / 2) - (self.fontHeight / 2), self.width, "left")

	--Info
	lg.printf(self.file, 0, self.height - self.style.topMargin, self.width, "center")

	--Cursor
	lg.setColor(self.style.color.cursor)
	lg.rectangle("fill", self.cursor.x, self.cursor.y, self.cursor.width, self.fontHeight)

	--Lines
	lg.setColor(self.style.color.text)
	lg.setFont(self.style.font)
	local lineY 
	if #self.linesHighlight > 0 then
		--for i=self.scroll.y, self.visibleLines + self.scroll.y do
		for i,v in ipairs(self.linesHighlight) do
			--v = self.linesHighlight[i]
			lineY = self.y + self.style.topMargin + (self.fontHeight * ((i - 1)))
			--lg.print(v, self.x + self.style.margin, lineY)
			if v then 
				lg.setColor(1, 1, 1, 1)
				lg.setScissor(self.x + self.style.sideMargin, self.y, self.width - (self.style.sideMargin), self.height)
				lg.draw(v, self.x + self.scroll.x + self.style.sideMargin, lineY) 
			end

			lg.setScissor(self.x, self.y, self.width, self.height)
			lg.setColor(self.style.color.lineNumber)
			lg.printf(i + self.scroll.y - 1, self.x - 8, lineY, self.style.sideMargin, "right")
		end
	end

	lg.setScissor()
end

function codeEditor:keypressed(key)
	local line = self.linesRaw[self.cursor.line]
	if key == "return" then
		local lineStart = utf8sub(line, 0, self.cursor.position)
		local lineEnd = utf8sub(line, self.cursor.position+1, #line)

		if self.cursor.position == 0 then
			lineStart = ""
		end

		self.linesRaw[self.cursor.line] = lineStart

		local indent = self:countIndent(lineStart)
		for i=1, indent do
			lineEnd = "	"..lineEnd
		end

		table.insert(self.linesRaw, self.cursor.line + 1, lineEnd)
		self.cursor.line = self.cursor.line + 1
		self.cursor.position = indent


		self:updateCursor()
	elseif key == "backspace" then

		local lineStart = utf8sub(line, 0, self.cursor.position)
		local lineEnd = utf8sub(line, self.cursor.position+1, #line)
		local clearLine = false

		if self.cursor.position == 0 then
			lineStart = ""
		end

		if kb.isDown("lshift") or kb.isDown("rshift") then
			lineStart = ""
			clearLine = true
		else
			lineStart = utf8sub(lineStart, 1, -2)
		end

		if self.cursor.position < 1 then
			if self.cursor.line > 1 then
				table.remove(self.linesRaw, self.cursor.line)
				self.cursor.line = self.cursor.line - 1
				self.cursor.position = utf8len(self.linesRaw[self.cursor.line])
				self.linesRaw[self.cursor.line] = self.linesRaw[self.cursor.line]..line
			end
		else
			self.linesRaw[self.cursor.line] = lineStart..lineEnd
			if clearLine then
				self.cursor.position = 0
			else
				self.cursor.position = self.cursor.position - getCharBytes(line, #line)
			end
		end



		self:updateCursor()
	elseif key == "down" then
		if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
			if self.cursor.line < #self.linesRaw then
				local nextLine = self.linesRaw[self.cursor.line + 1]
				self.linesRaw[self.cursor.line + 1] = self.linesRaw[self.cursor.line]
				self.linesRaw[self.cursor.line ] = nextLine
				self.cursor.line = self.cursor.line + 1
			end
		else
			local step = 1
			if kb.isDown("lshift") or kb.isDown("rshift") then
				step = self.visibleLines
			end
			self.cursor.line = self.cursor.line + step
			if self.cursor.line > #self.linesRaw then
				self.cursor.line = #self.linesRaw
			end

			local len = utf8len(self.linesRaw[self.cursor.line])
			if len < self.cursor.position then
				self.cursor.position = len
			end
		end

		self:updateCursor()
	elseif key == "up" then
		if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
			if self.cursor.line > 1 then
				local nextLine = self.linesRaw[self.cursor.line - 1]
				self.linesRaw[self.cursor.line - 1] = self.linesRaw[self.cursor.line]
				self.linesRaw[self.cursor.line ] = nextLine
				self.cursor.line = self.cursor.line - 1
			end
		else
			local step = 1
			if kb.isDown("lshift") or kb.isDown("rshift") then
				step = self.visibleLines
			end
			self.cursor.line = self.cursor.line - step
			if self.cursor.line < 1 then
				self.cursor.line = 1
			end

			local len = utf8len(self.linesRaw[self.cursor.line])
			if len < self.cursor.position then
				self.cursor.position = len
			end
		end

		self:updateCursor()
	elseif key == "right" then
		if kb.isDown("lshift") or kb.isDown("rshift") then
			self.cursor.position = utf8len(line)
		else
			self.cursor.position = self.cursor.position + getCharBytes(line, #line)
		end
		if self.cursor.position > utf8len(line) then
			self.cursor.position = utf8len(line)
		end

		self:updateCursor()
	elseif key == "left" then
		if kb.isDown("lshift") or kb.isDown("rshift") then
			self.cursor.position = 0
		else
			self.cursor.position = self.cursor.position - getCharBytes(line, #line)
		end
		if self.cursor.position < 0 then
			self.cursor.position = 0
		end

		self:updateCursor()
	elseif key == "tab" then
		self:insertText("	")
	elseif key == "d" then
		if kb.isDown(modKey[1]) or kb.isDown(modKey[2]) then
			table.insert(self.linesRaw, self.cursor.line, self.linesRaw[self.cursor.line])
		end
	end
end

function codeEditor:resize(w, h)
	w = w or self.width
	h = h or self.height
	
	self.style.font = mainFont
	self.fontHeight = self.style.font:getAscent() - self.style.font:getDescent()
	self.width = w
	self.height = h
	self.style.sideMargin = self.style.font:getWidth("9999")
	self.style.topMargin = self.fontHeight
	self.visibleLines = math.floor((self.height - (self.style.topMargin * 2)) / (self.style.font:getAscent() - self.style.font:getDescent())) - 1
end

function codeEditor:insertText(text)
	local line = self.linesRaw[self.cursor.line]
	local lineStart = utf8sub(line, 0, self.cursor.position)
	local lineEnd = utf8sub(line, self.cursor.position+1, #line)

	if self.cursor.position == 0 then
		lineStart = ""
	end

	self.linesRaw[self.cursor.line] = lineStart..text..lineEnd

	self.cursor.position = self.cursor.position + utf8len(text)

	self:highlight()
	self:updateCursor()
end

function codeEditor:countIndent(line)
	local i = 0
	line:gsub("(	)", function() i = i + 1 end)
	return i
end

function codeEditor:textinput(t)
	self:insertText(t)
end

return codeEditor