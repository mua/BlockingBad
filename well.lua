----------------------------
-- Author: M. Utku Altinkaya
-- utkualtinkaya@gmail.com
----------------------------

------------------------------------------------------------------------
--This class represents state of the board and contains AI logic
Well = {width = 10, height = 22}

function Well.create(cls)
	local instance = {blocks = {}, score=0, stackHeight = 0}
	setmetatable(instance, {__index = cls})
	instance:init()
	return instance
end

function Well:init()
	for x=1,self.width do
		self.blocks[x] = {}
	end
	self.offsets = {}
	self.animated = false
end

function Well.insertLines(self, count)
	for x=1,count do
		table.insert(self.blocks[x], 1, nil)
	end	
end

--Collision detection is done by just finding if any blocks share the same space
function Well.doesCollide(self, shape)
	local ox, oy = math.ceil(shape.x), math.ceil(shape.y)
	local tetra = shape.tetra[shape.rotation]
	for y=1,table.getn(tetra) do		
		for x=1,table.getn(tetra[y]) do
			local x1, y1 = x+ox-1, y+oy-1
			if tetra[y][x] then
				if x1<1 or x1>self.width or y1<1 or y1>self.height then return true end
				if self.blocks[x1] and self.blocks[x1][y1] then return true end
			end
		end
	end	
end

function Well.draw(self)	
	for x=1,self.width do	
		for y=1,self.height do			
			if self.blocks[x] and self.blocks[x][y] then 
				drawBlock('fill', x, y + (self.offsets[y] or 0), self.blocks[x][y])				
			end
		end
	end
end

function Well.update(self, dt)
	for y=1,self.height do	
		if self.offsets[y] then 
			-- falling effect by decrasing offset over time
			-- using y as speed factor to have cool different speed per line effect
			self.offsets[y] = math.min(self.offsets[y] + dt*y/3, 0) 
		end
	end
end

--Returns list of completed lines
function Well.lines(self)
	local lines = {}
	for y=1,self.height do
		local found = true
		for x=1,self.width do
			if not self.blocks[x][y] then 
				found = false
				break
			end
		end
		if found then
			table.insert(lines, y)
		end
	end
	return lines
end

function Well.removeLine(self, nr)
	self.stackHeight = self.stackHeight - 1
	if self.animated then
		-- initializing offsets for falling lines effect 
		for y=nr,2,-1 do
			self.offsets[y] = (self.offsets[y-1] or 0) - 1
		end
	end
	for x=1,self.width do
		for y=nr,2,-1 do
			self.blocks[x][y] = self.blocks[x][y-1]
		end
		self.blocks[x][1] = nil
	end	
end

-- appends shape to the well
function Well.move(self, shape)
	for x, y, c in shape:blocks(true) do
		self.blocks[x][y] = c
		self.stackHeight = math.max(self.stackHeight, self.height - y)
	end
end

--adds the shape but also clears completed lines
function Well.add(self, shape)
	self:move(shape)
	local lines = self:lines()
	for i, y in ipairs(lines) do
		self:removeLine(y)
		self.score = self.score + 1
	end
	return table.getn(lines)
end

--Returns all possible positions of a shape
--Then I am iterating these positions to find out best
--possible outcome
function Well.project(self, shape)
	local start = self.height - self.stackHeight
	local proj = {}
	for r=1,4 do
		shape:rotate()
		for x=0,10 do
			shape.x = x
			shape.y = 1
			if not self:doesCollide(shape) then
				repeat 
					shape.y = shape.y+1
				until self:doesCollide(shape) or shape.y > 25
				table.insert(proj, {shape.x, shape.y-1, shape.rotation})				
			end
		end
	end
	return proj	
end

--Valuate the well state, to find out how good it is
--I simply sum the top positions of the blocks, this is
--an approximation of stack height, higher the stack lower the score
function Well.stateScore(self)
	local total = 0
	for x=1,self.width do	
		for y=1,self.height do
			if self.blocks[x] and self.blocks[x][y] then 
				total = total + 22 - y
			end
		end
	end
	return -total
end

--Clone the well 
function Well.copy(self)
	local cc = Well:create()
	for y=1,self.height do
		for x=1,self.width do
			cc.blocks[x][y] = self.blocks[x][y]
		end
	end
	cc.stackHeight = self.stackHeight
	return cc
end

possible = 0

-- Finding the best possible move for a shape
-- by grading all possible placements for all shape orientations
function Well.bestMove(self, shape)	
	local bestScore, bestState = -10e6, nil
	for i, move in ipairs(self:project(shape)) do
		shape.x, shape.y, shape.rotation = move[1], move[2], move[3]
		local cpy = self:copy()
		cpy:add(shape)
		local score = cpy:stateScore()

		possible = possible + 1
		if score > bestScore then
			bestScore = score			
			bestState = cpy
		end
	end
	return bestState, bestScore
end

-- Find the worst possible shape by comparing best possible move can be done
-- using that shape
function Well.worstShape(self, depth)
	depth = depth == nil and 1 or depth	-- how deep we discover tree, default 1
	local worstScore, worstShape, worstState = 10e6, 1, nil
	for i=1,7 do
		local tmp = Shape:create(i)
		local state, score = self:bestMove(tmp)
		if depth > 1 then
			local subB, subScore = state:worstShape(depth-1) --branches have half effect on current state's grading
			score = score + subB * 0.5
		end
		score = score + math.random() -- this is just to break ties, does not change algorithm
		if score < worstScore then -- just keep the worst scored state
			worstScore = score
			worstShape = i
			worstState = state
		end
	end	
	if depth > 0 then 
		depth = depth - 1
		local state, score = worstState:worstShape(depth)
		worstScore = worstScore + score * .5
	end
	return worstShape, worstScore
end
