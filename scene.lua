----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

--Base class for all scenes
Scene = {}
function Scene:init()	
end
function Scene:draw()
end
function Scene:update(dt)
end
function Scene:keypressed( key, unicode )
end
function Scene:keyreleased( key, unicode )
end
function Scene:mousepressed( x, y, button )
end

--Class of UI container scenes, manages ui elements
UIScene = Class(Scene)
function UIScene:init()
	Scene.init(self)
	self.ui = {}
end

--draw all ui elements
function UIScene:draw()
	for i, ui in pairs(self.ui) do
		ui:draw()
	end
end

function UIScene:update(dt)
	for i, ui in pairs(self.ui) do
		ui:update(dt)
	end
end

--pass mouse press event to memeber ui elements
function UIScene:mousepressed(x, y, button )
	for name, ui in pairs(self.ui) do
		if ui:mousepressed(x,y,button) then
			self:buttonClick(name)
		end
	end	
end

--pass mouse keypress event to memeber ui elements
function UIScene:keypressed( key, unicode )
	for name, ui in pairs(self.ui) do
		ui:keypressed(key, unicode)
	end
end

--set color of ui elements
function UIScene:setColor(color)
	for _,ui in pairs(self.ui) do
		ui.color = color
		ui.normalColor = color
	end
end