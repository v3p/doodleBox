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
	keyword = {0, 0.5, 1, 1},
	symbol = {1, 0.5, 0, 1},
	string = {1, 0, 1, 1},
	number = {1, 1, 0, 1},
	functions = {0.2, 1, 0.2, 1},
	comment = {0.3, 0.3, 0.3, 1}
}

local keywords = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", 
			      "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "pairs", "ipairs"}

local functions = {
	"width", "height", "floor", "ceil", "sin", "cos", "tan", "circle", "rect", "random", "noise", "size", "randomColor",
	"color", "background", "normal", "lerp", "clamp", "dist", "PI", "TWO_PI", "mouseX", "mouseY"
}


local symbols = {"+", "-", "*", "/", "%", "^", "#", "=", "==", "=>", "<=", "~", 
				 "<", ">", "(", ")", "{", "}", "[", "]", ";", ":", ",", "."}

--[[
local function utf8sub(s,i,j)
    i=utf8.offset(s,i)
    j=utf8.offset(s,j+1)-1
    return string.sub(s,i,j)
end
]]
local function isKeyword(w)
	local is = false
	for k,v in pairs(keywords) do
		if w == v then
			is = true
			break
		end
	end
	return is
end

local function isSymbol(w)
	local is = false
	for k,v in pairs(symbols) do
		if w == v then
			is = true
			break
		end
	end
	return is
end

local function isFunction(w)
	local is = false
	for k,v in pairs(functions) do
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

		scroll = {
			x = 1,
			y = 1
		},

		file = "untitled"
	}
	e.fontHeight = e.style.font:getAscent() - e.style.font:getDescent()
	e.cursorWidth = e.style.font:getWidth("a")
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
			if isKeyword(v) and not isString then
				textList[#textList + 1] = syntaxColor.keyword
				textList[#textList + 1] = v
			elseif isSymbol(v) and not isString then
				textList[#textList + 1] = syntaxColor.symbol
				textList[#textList + 1] = v
			elseif isFunction(v) and not isString then
				textList[#textList + 1] = syntaxColor.functions
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
			elseif v == '"' or v == "'" then
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
			self.linesRaw[#self.linesRaw + 1] = line
			lc = lc + 1
		end
		if lc < 1 then
			self.linesRaw[1] = ""
		end
		self.file = path
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

function codeEditor:update(dt)
	self:highlight()

	self.cursorX = self.x + self.scroll.x + self.style.sideMargin + self.style.font:getWidth(utf8sub(self.linesRaw[self.currentLine], 1, self.currentLinePosition))
	self.cursorY = self.y + self.style.topMargin + (self.fontHeight * (self.currentLine - self.scroll.y))

	if self.currentLinePosition == 0 then
		self.cursorX = self.x + self.scroll.x + self.style.sideMargin
	end

	if self.cursorX > self.width then
		self.scroll.x = self.scroll.x + self.width - self.cursorX - self.cursorWidth
	elseif self.cursorX < self.style.sideMargin then
		self.scroll.x = self.scroll.x - self.cursorX + self.cursorWidth + self.style.sideMargin
	end
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

	--Info
	lg.setColor(0, 1, 0, 1)
	lg.printf(self.file, 0, (self.style.topMargin / 2) - (self.fontHeight / 2), self.width, "center")

	--Bottom Panel
	lg.setColor(self.style.color.panel)
	lg.rectangle("fill", self.x, self.y + self.height - self.style.topMargin, self.width, self.style.topMargin)

	--Info
	lg.setColor(0, 1, 0, 1)
	lg.printf(self.currentLine.."/"..#self.linesRaw, 0, self.y + self.height - self.style.topMargin + (self.style.topMargin / 2) - (self.fontHeight / 2), self.width, "left")

		--Cursor
	lg.setColor(self.style.color.cursor)
	lg.rectangle("fill", self.cursorX, self.cursorY, self.cursorWidth, self.fontHeight)

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
	if key == "return" then
		local line = self.linesRaw[self.currentLine]

		local lineStart = self.linesRaw[self.currentLine]:sub(1, self.currentLinePosition)
		local lineEnd = self.linesRaw[self.currentLine]:sub(self.currentLinePosition+1)

		table.insert(self.linesRaw, self.currentLine + 1, lineEnd)
		self.linesRaw[self.currentLine] = lineStart
		self.currentLine = self.currentLine + 1
		self.currentLinePosition = 0

		if self.currentLine > self.visibleLines + self.scroll.y then
			self.scroll.y = self.currentLine - self.visibleLines
		end
	elseif key == "backspace" then
		local lineStart = utf8sub(self.linesRaw[self.currentLine], 1, self.currentLinePosition)
		local lineEnd = utf8sub(self.linesRaw[self.currentLine], self.currentLinePosition+1, #self.linesRaw[self.currentLine])

		if kb.isDown("lshift") or kb.isDown("rshift") then
			self.linesRaw[self.currentLine] = lineEnd
			self.currentLinePosition = 0
		else
			local byteoffset = utf8.offset(lineStart, -1)
	        if byteoffset then
	            self.linesRaw[self.currentLine] = string.sub(lineStart, 1, byteoffset - 1)..lineEnd
	            self.currentLinePosition = self.currentLinePosition - 1
	        else
	        	if #self.linesRaw > 1 then
	        		if self.currentLine > 1 then
		        		self.currentLine = self.currentLine - 1
		        		self.linesRaw[self.currentLine] = self.linesRaw[self.currentLine]..lineEnd
		        		table.remove(self.linesRaw, self.currentLine + 1)
		        		self.currentLinePosition = #self.linesRaw[self.currentLine] - #lineEnd
		        	end
	        	end
	        end
	    end
    elseif key == "tab" then
    	self:insertText("	")
	elseif key == "up" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.currentLine = self.currentLine - self.visibleLines
		elseif love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") then
			self.currentLine = self.currentLine - math.floor(self.visibleLines / 2)
		else
			self.currentLine = self.currentLine - 1
		end
		if self.currentLine < 1 then
			self.currentLine = 1
		end

		if #self.linesRaw[self.currentLine] < self.currentLinePosition then
			self.currentLinePosition = #self.linesRaw[self.currentLine]
		end

		if self.currentLine < self.scroll.y then
			self.scroll.y = self.currentLine
		end
	elseif key == "down" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.currentLine = self.currentLine + self.visibleLines
		elseif love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt") then
			self.currentLine = self.currentLine + math.floor(self.visibleLines / 2)
		else
			self.currentLine = self.currentLine + 1
		end
		if self.currentLine > #self.linesRaw then
			self.currentLine = #self.linesRaw
		end

		if #self.linesRaw[self.currentLine] < self.currentLinePosition then
			self.currentLinePosition = #self.linesRaw[self.currentLine]
		end

		if self.currentLine > self.visibleLines + self.scroll.y then
			self.scroll.y = self.currentLine - self.visibleLines
		end
	elseif key == "left" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.currentLinePosition = 0
		else
			self.currentLinePosition = self.currentLinePosition - 1
		end
		if self.currentLinePosition < 0 then
			self.currentLinePosition = 0
		end
	elseif key == "right" then
		if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
			self.currentLinePosition = utf8.len(self.linesRaw[self.currentLine])
		else
			self.currentLinePosition = self.currentLinePosition + 1
		end
		if self.currentLinePosition > #self.linesRaw[self.currentLine] then
			self.currentLinePosition = #self.linesRaw[self.currentLine]
		end
	end
end

function codeEditor:resize(w, h)
	self.width = w
	self.height = h
	self.visibleLines = math.floor((self.height - (self.style.topMargin * 2)) / (self.style.font:getAscent() - self.style.font:getDescent())) - 1
end

function codeEditor:insertText(text)
	local line = self.linesRaw[self.currentLine]
	self.linesRaw[self.currentLine] = line:sub(0, self.currentLinePosition)..text..line:sub(self.currentLinePosition + 1)
	self.currentLinePosition = self.currentLinePosition + #text

	self:highlight()
end

function codeEditor:textinput(t)
	self:insertText(t)
end

return codeEditor