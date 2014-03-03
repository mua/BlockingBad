----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

require "well"
require "shapes"

-- Actual game play happens in this scene
GameScene = Class(Scene)

function GameScene:init()
	self.activeShape = nil
	self.well = Well:create() -- Main data structure for game state, where magic happens
	self.well.animated = true
	
	self.score = 0
	self.level = 0
	self.lines = 0	

	self:next()

	self.back = love.graphics.newImage("assets/bg.png")
	
	-- Particle system for trailing smoke
	local p = love.graphics.newParticleSystem(love.graphics.newImage("assets/part1.png"), 100)
	p:setEmissionRate(100)
	p:setSpeed(250, 350)
	p:setSizes(.5, 1)
	p:setColors(255, 255, 255, 255, 255, 255, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(-1)
	p:setParticleLife(.5)
	p:setSpread(.1)
	p:setDirection(-math.pi/2)	
	p:stop()
	self.trail = p		
end

function GameScene:gravity()
	return math.min(math.max(self.level, 10), 2) -- increase speed by level
end

function GameScene:draw()		
	love.graphics.draw(self.back)
	love.graphics.draw(self.trail)
	
	if self.activeShape then
		self.activeShape:draw()
	end
	self.well:draw()
	
	-- Draw scoreboard
	local x, y = 535, 50
	love.graphics.setFont(font["default"])
	love.graphics.print("Score", x, y)
	y = y + 30
	love.graphics.print(self.score, x, y)
	y = y + 40
	love.graphics.print("Lines", x, y)
	y = y + 30
	love.graphics.print(self.lines, x, y)	
	y = y + 40
	love.graphics.print("Level", x, y)
	y = y + 30
	love.graphics.print(self.level, x, y)
end

-- Push the piece into the well
function GameScene:place()
	local lc = self.well:add(self.activeShape)
	if lc > 0 then
		self.lines = self.lines + lc
		self.score = self.score + (self.level+1) * scoreForLines[lc]
	end
	self.activeShape = nil
	love.audio.play(sound["click"])
	self.trail:stop()
end

-- This is called to hand user a new shape
function GameScene:next()
	local i
	if settings.difficulty == 1 then -- easy difficulty, default tetris
		i = math.floor(math.random()*7) + 1
	elseif settings.difficulty == 2 then 
		-- normal difficulty:
		-- chances of getting a random shape instead of a calculated one 
		-- decreases by level and difficulty increases until 10th level, 
		-- after that, it is fixed 10%
		if math.random() > math.min(0.9, self.level/10) then
			i = math.floor(math.random()*7) + 1
		else
			i = self.well:worstShape() 
		end
	elseif settings.difficulty == 3 then -- hard difficulty, all shapes are calculated
		i = self.well:worstShape() 
	end
	self.activeShape = Shape:create(i)
	self.activeShape.gravity = self:gravity()
end

-- Sorry bro, it is over
function GameScene:gameOver()
	love.audio.play(sound["fail"])
	game:setState(GameOverScene:create(self.score))
end

function GameScene:update(dt)
	if not self.activeShape then -- new game or active shape is pushed 
		self:next()				 -- into the well, so we need a new one
		if self.well:doesCollide(self.activeShape) then -- no space left, it is over
			self:gameOver() 
		end
	end
	local target = self.activeShape.y + dt * self.activeShape.gravity
	x, y = self.activeShape:center()
	self.trail:setPosition(x, y)
	self.trail:update(dt)
	
	local y1, y2 = math.ceil(self.activeShape.y), math.ceil(target) --look for collisions while dropping
	for y=y1,y2 do
		self.activeShape.y = y
		if self.well:doesCollide(self.activeShape) then
			self.activeShape.y = y - 1
			self:place() -- add it to the well
			return
		end
	end
	self.activeShape.y = target
	if y2>y1 and self.activeShape.gravity == 50 then 
		self.score = self.score + 1 -- SNS Tetris standard, hand some points for soft drop
	end

	self.well:update(dt) -- well needs to be updated, so animations can be executed
	if self.lines >= self.level * 10 then
		self.level = self.level + 1
	end
end

-- Keyboard controls
function GameScene:keypressed( key, unicode )
	if not self.activeShape then return end
	local ox, orot = self.activeShape.x, self.activeShape.rotation	
	if key == "a" or key == "left" then
	  self.activeShape.x = self.activeShape.x - 1
	elseif key == "d" or key == "right" then
	  self.activeShape.x = self.activeShape.x + 1	  
	elseif key == "s" or key == "down" then
		self.activeShape.gravity = 50
		self.trail:start()
	elseif key == "w" or key == "up" then
		self.activeShape:rotate()
	end
	if self.well:doesCollide(self.activeShape) then
		self.activeShape.x = ox
		self.activeShape.rotation = orot
	end
end

function GameScene:keyreleased( key, unicode )
   if not self.activeShape then return end
   if key == "s" or key == "down" then
      self.activeShape.gravity = self:gravity()
	  self.trail:stop()
   end
   if key == "escape" then
	  self:gameOver()
   end
end

----------------------------------------------

-- Game Over Scene 
GameOverScene = Class(UIScene)
function GameOverScene:init(score)
	UIScene.init(self)
	-- Compare score to the previous highscore entries
	self.score = score
	local place = 6 --off the table
	for i, entry in ipairs(scoreboard) do
		if entry.score < score then
			place = i -- we have a place here
			break
		end
	end
	self.highscore = place < 6
	self.place = place
	
	local x, y = windowWidth/2, windowHeight/2
	self.back = love.graphics.newImage("assets/go.png")
	if self.highscore then
		self.ui["label1"] = Label:create("High Score #"..self.place.." !", x, y)
		self.ui["label2"] = Label:create("Enter name", x, y+40)
		self.ui["input"] = Input:create("", x, y+70)
	end
	self.ui["done"] = Button:create("Done", x, y+120)
	self:setColor(color["gameOver"])
end

function GameOverScene:draw()	
	love.graphics.draw(self.back)
	UIScene.draw(self)	
end

function GameOverScene:buttonClick(button)
	if button == "done" then
		if self.highscore then --  if we have a highscore, write it into the highscore table
			table.insert(scoreboard, self.place, {name = self.ui["input"].text, score=self.score})
			table.remove(scoreboard, 6)
		end
		game:setState(MenuScene:create())
	end
end
