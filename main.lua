----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

require "support"

require "scene"
require "game"
require "menu"

--The Game Singleton, manages scenes and transitions
game = {}
function game:init()
	self.state = nil
	self.transition = nil
end

function game:draw()
	if self.transition ~= 0 then --if transition taking place
		if self.oldState then
			effect:send("opacity", self.transition)
			self.oldState:draw()
		end
		effect:send("opacity", 1-self.transition)
	end	
	self.state:draw()
end

function game:update(dt)
	self.state:update(dt)
	if self.transition ~= 0 then -- update transition state
		self.transition = math.max(self.transition-dt/1, 0)		
		if self.transition == 0 then
			self.oldState = nil
			effect:send("opacity", 1)
		end
	end
end

-- change current scene by initiating fade transition
function game:setState(newState)	
	self.transition = 1
	self.oldState = self.state
	self.state = newState
end

function game:keypressed( key, unicode )
	self.state:keypressed( key, unicode )
end

function game:keyreleased( key, unicode )
	self.state:keyreleased( key, unicode )
end

function game:mousepressed( x, y, button )
	self.state:mousepressed( x, y, button )
end

------------------------------------------------------------------------

function love.load()
	-- initialize game singleton
	game:init()
	
	-- define few globals and load resources
	-- a resource loader and configuration can be useful but this was enough
	-- for my purposes
	font = {	default = love.graphics.newFont(24),
				large = love.graphics.newFont(28)}
	color =	 {	
				main = {63,193,255},
				text = {91,102,63},
				gameOver = {0,0,0,255},
				overlay = {255,255,255,235} }	
	sound = {
		click = love.audio.newSource("assets/click.ogg", "static"),
		fail = love.audio.newSource("assets/fail.ogg", "static")}
	music =	{
		default = love.audio.newSource("assets/tetris.mod")}
	settings = {
		difficulty = 3}
	scoreboard = table.load("scores.dat") or 
				{	{name="utku", score=100}, 
					{name="utku", score=200},
					{name="utku", score=300},
					{name="utku", score=400},
					{name="utku", score=500}}	
	offX = 64
	offY = 32
	scoreForLines = {40, 100, 300, 1200}
	windowWidth = 1024
	windowHeight = 768
	
	-- load block images for falling particles
	blocks = {}	
	for i, name in ipairs({"blue", "lime", "lightBlue", "orange", "green", "purple", "red"}) do
		table.insert(blocks, love.graphics.newImage("assets/"..name.."_blok.png"))
	end
	
	--game:setState(GameScene:create())
	game:setState(MenuScene:create())
	--game:setState(GameOverScene:create(190))
				
	love.keyboard.setKeyRepeat(true)
	love.graphics.setBackgroundColor(30, 30, 30)
	
	-- I created this shader to have opacity control over entire scene, fade in transitions are 
	-- handled this way
    effect = love.graphics.newPixelEffect [[
        extern number opacity;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
			vec4 pcolor = color * Texel(texture, texture_coords);
			pcolor.a *= opacity;
            return pcolor;
        }
    ]]
	love.graphics.setPixelEffect(effect)
end

function love.draw()		
	game:draw()
	-- love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function love.update(dt)    
	game:update(dt)	        
end

function love.keypressed( key, unicode )
	game:keypressed( key, unicode )
end

function love.keyreleased( key, unicode )
	game:keyreleased( key, unicode )
end

function love.mousepressed( x, y, button )
	game:mousepressed( x, y, button )
end

function love.quit()
	-- store highscores
	table.save(scoreboard, "scores.dat")
end