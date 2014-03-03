----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

------------------------------------------------------------------------
--Basic ui item able to process events and have a position
UIItem = {}

function UIItem:init(x, y)
	self.x = x
	self.y = y
end

function UIItem:update(dt)	
end

function UIItem:mousepressed(x, y, button)	
end

function UIItem:keypressed( key, unicode )
end

------------------------------------------------------------------------
--UI Item that can display text
Label = Class(UIItem)
function Label:init(text, x, y)
	UIItem.init(self, x, y)
	self.font = font["large"]	
	self.color = color["text"]
	self:setText(text)
	self.normalColor = color["text"]	
end

function Label:drawText(text)
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setFont(self.font)
	love.graphics.setColor(unpack(self.color))
	left, top = self:topLeft()
	love.graphics.print(text, left, top)
	love.graphics.setColor(r,g,b,a)
end

function Label:draw()	
	self:drawText(self.text)
end

function Label:setText(text)
	self.text = text
	self.width = self.font:getWidth(text)
	self.height = self.font:getHeight()	
end

function Label:topLeft()
	return self.x - (self.width / 2), self.y - self.height
end

------------------------------------------------------------------------
--UI Item that process clicks
Button = Class(Label)

function Button:init(text, x, y)
	Label.init(self, text, x, y)
end

function Button:update(dt)
	self.hover = false	
	local x = love.mouse.getX()
	local y = love.mouse.getY()	
	left, top = self:topLeft()
	if x > left
		and x < left + self.width
		and y > top 
		and y < top + self.height then
		self.hover = true
		self.color = color["overlay"]
	else
		self.color = self.normalColor
	end	
end

function Button:mousepressed(x, y, button)	
	if self.hover then
		love.audio.play(sound["click"])
		return true
	end	
	return false	
end

------------------------------------------------------------------------
--Basic text input item
Input = Class(Label)
function Input:keypressed( key, unicode )
    if unicode > 31 and unicode < 127 then
		self:setText(self.text..string.char(unicode))
	end
	if key == "backspace" then
		self:setText(string.sub(self.text, 1, string.len(self.text)-1))
	end
end

function Input:draw()	
	self:drawText(self.text.."_")
end
