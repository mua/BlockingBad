-- Tetramino templates are used to create tetraminos and their rotated forms
tetraTemplates = {
	{
		"    ",
		"xxxx",
		"    ",
		"    "
	},
	{
		"    ",
		" xx ",
		" xx ",
		"    "
	},
	{
		"xx ",
		" xx",
		"   "
	},
	{
		" xx",
		"xx ",
		"   "
	},
	{
		"xxx",
		"x  ",
		"   "
	},
	{
		"xxx",
		"  x",
		"   "
	},
	{
		" x ",
		"xxx",
		"   "
	}
}

function rotateTetra(tetra)
	local d, t = table.getn(tetra), {};
	for i, r in ipairs(tetra) do
		t[i] = {}
	end
	for y, row in ipairs(tetra) do
		for x, v in ipairs(row) do
			t[x][d-y+1] = v
		end
	end
	return t
end

-- fill tetramino table
tetraminos = {}
for i, tetra in ipairs(tetraTemplates) do
	newTetra = {}	
	for r, str in ipairs(tetra) do
		newTetra[r] = {}
		for n=1, #str do
			newTetra[r][n] = str:sub(n,n) == "x"
		end
	end
	tetraminos[i] = {newTetra}
	for k=2,4 do
		tetraminos[i][k] = rotateTetra(tetraminos[i][k-1])
	end
end

-----------------------------------------------------------

--Block position to actual screen coordinate
function blockCoord(x, y)
	return offX+(x-1)*32, offY+(y-1)*32
end

--Draws a tetramino block
function drawBlock(mode, x, y, color)
	local tx, ty =  offX+(x-1)*32, offY+(y-1)*32
	if color then
		--love.graphics.setColor(color[1], color[2], color[3], 255)
		love.graphics.draw(blocks[color], tx, ty)
	else
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle(mode, tx, ty, 30, 30)
	end	
end

-- This class is used to represent a tetramino in the game
Shape = {}
function Shape.draw(self, mode)
	for x, y in self:blocks() do
		drawBlock(mode or 'fill', x+self.x, y+self.y, self.color)
	end
end

function Shape.create(cls, kind, color)
	local instance = {x = 5, y = 1, rotation = 1, tetra = tetraminos[kind], gravity = 2, color = kind, kind=kind}
	setmetatable(instance, {__index = cls})
	return instance
end

--Rotates shape
function Shape.rotate(self)
	self.rotation = self.rotation % 4 + 1
end

--Center of tetramino, need this to spawn it in right place
function Shape.center(self)
	cx, cy, i = 0, 0, 0
	for bx, by in self:blocks() do
		i, cx, cy = i + 1, cx + bx, cy + by
	end
	return blockCoord(self.x+cx/i+0.5, self.y+cy/i+0.5)
end

--Iterator for blocks, used especially by collision detection
function Shape.blocks(self, global)
	local i=-1
	local tetra = self.tetra[self.rotation]
	local dim = table.getn(tetra)
	local ox, oy = global and math.ceil(self.x) or 0, global and math.ceil(self.y) or 0
	return	function ()				
				while i<(dim^2-1) do
					i = i + 1
					local y, x = math.floor(i/dim), i%dim
					if tetra[y+1][x+1] then
						return x+ox, y+oy, self.color
					end
				end
			end
end