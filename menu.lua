----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

require "gui"

--Scene for intro and menu
MenuScene = Class(UIScene)
function MenuScene:init()
	UIScene.init(self)	
	self.ui = self:startUI()
	
	local images = {}
	self.emitters = {}
	for i, name in ipairs({"blue", "lime", "lightBlue", "orange", "green", "purple", "red"}) do
		table.insert(images, love.graphics.newImage("assets/"..name..".png"))
	end
	self.backTop = love.graphics.newImage("assets/back_top.png")
	self.backBottom = love.graphics.newImage("assets/back_bottom.png")
	self.title = love.graphics.newImage("assets/title.png")	
	
	--Particle system for falling blocks
	for n=3,1,-1 do -- 3 different layers to create depth illusion
		for _, piece in ipairs(images) do
			local p = love.graphics.newParticleSystem(piece, 30)
			p:setEmissionRate(1)
			p:setSpeed(100/n, 200/n)
			p:setSizes(1/n,1/n,1/n)
			p:setColors(255, 255, 255, 255/n, 255, 255, 255, 255/n)
			p:setLifetime(-1)
			p:setParticleLife(20)
			p:setDirection(math.pi/2)
			p:setSpread(0)	
			p:setSpin( math.pi*0.1, math.pi*0.2, math.pi*0.05)
			table.insert(self.emitters, p)		
		end
	end
	
	love.audio.play(music["default"], 0)
	
	--Particle sytem for fire wall 
	local p = love.graphics.newParticleSystem(love.graphics.newImage("assets/part1.png"), 300)
	p:setEmissionRate(200)
	p:setSpeed(250, 350)
	p:setSizes(1, 2)
	p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
	p:setPosition(400, 300)
	p:setLifetime(-1)
	p:setParticleLife(0.4)
	p:setSpread(0)
	p:setDirection(-math.pi/2)
	
	p:setTangentialAcceleration(100)
	p:setRadialAcceleration(-200)

	self.firewall = p
end

--Start ui
function MenuScene:startUI()
	local ui = {}
	local x, y = windowWidth/2, windowHeight/2 + 100 
	ui["start"] = Button:create("Start", x, y)
	ui["score"] = Button:create("Highscores", x, y+40)
	ui["settings"] = Button:create("Difficulty", x, y+75)	
	return ui
end

--Setting ui
function MenuScene:settingsUI()
	local ui = {}
	local x, y = windowWidth/2, windowHeight/2 + 100
	ui["setEasy"] = Button:create("Easy", x, y)
	ui["setNormal"] = Button:create("Normal", x, y+35)
	ui["setHard"] = Button:create("Hard", x, y+65)
	local names = {"setEasy", "setNormal", "setHard"}	
	ui[names[settings.difficulty]].normalColor = {255, 0, 0, 255}
	return ui
end

--Top score list ui
function MenuScene:scoreUI()
	local x, y = windowWidth/2, windowHeight/2 + 80
	local ui = {}
	ui["title"] = Label:create("Hall of fame", x, y)
	for i=1,5 do 
		y = y + 35	
		ui[i] = Label:create(scoreboard[i].name.." - "..scoreboard[i].score, x, y)		
	end
	ui["menu"] = Button:create("Back", x, y+35)
	return ui
end

function MenuScene:update(dt)	
	UIScene.update(self, dt)
	for i, emitter in ipairs(self.emitters) do
		emitter:setPosition(math.random()*windowWidth, -100)
		emitter:update(dt)
	end			
	self.firewall:update(dt)
	self.firewall:setPosition(math.random()*windowWidth, 500)	
end

function MenuScene:draw()	
	love.graphics.draw(self.backTop)
	for i, emitter in ipairs(self.emitters) do			
		love.graphics.draw(emitter)
	end						
	
	local colorMode = love.graphics.getColorMode()
	local blendMode = love.graphics.getBlendMode()
	love.graphics.setColorMode("modulate")
	love.graphics.setBlendMode("additive")
	love.graphics.draw(self.firewall)	
	love.graphics.setColorMode(colorMode)
	love.graphics.setBlendMode(blendMode)		
	
	love.graphics.draw(self.backBottom)
	love.graphics.draw(self.title)	
	
	UIScene.draw(self)
end

--Receive and process button click event
function MenuScene:buttonClick(button)
	if button == "start" then
		love.audio.stop(music["default"])
		game:setState(GameScene:create())		
	elseif button == "settings" then
		self.ui = self:settingsUI()
	elseif button == "menu" then
		self.ui = self:startUI()		
	elseif button == "score" then
		self.ui = self:scoreUI()
	elseif button == "setEasy" then	
		settings.difficulty = 1
		self.ui = self:startUI()
	elseif button == "setNormal" then	
		settings.difficulty = 2
		self.ui = self:startUI()
	elseif button == "setHard" then	
		settings.difficulty = 3
		self.ui = self:startUI()
	end
end

ScoreScene = Class(UIScene)
function ScoreScene:init()
	self.super.init(self)
	table.insert(self.ui, Button:create("Done", 100, 100))
end