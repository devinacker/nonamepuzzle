
anims = {}

function updateAnim(df)
	for anim = #anims, 0, -1 do
		if anims[anim] and not anims[anim]:update(df) then
			table.remove(anims, anim)
		end
	end
end

function drawAnim()
	for anim = #anims, 0, -1 do
		if anims[anim] then
			anims[anim]:draw()
		end
	end
end

function newColorChangeAnim(x, y, color)
	table.insert(anims, {
	frame = 0,
	
	update = function(self, df)
		self.frame = self.frame + df
		
		return self.frame < 64
	end,
	
	draw = function(self)
		local animColor = {color[1],
		                   color[2],
		                   color[3]}
		local l = 32 * board.l
		local w = 32 * board.w
		
		for i = 1, 3 do
			animColor[i] = math.min(color[i] + self.frame * 2, 255)
		end
		animColor[4] = 255 - self.frame * 4
		
		love.graphics.setColor(255, 255, 255, animColor[4] * .75)
		love.graphics.rectangle("fill", x, y, 32, 32)
		love.graphics.setColor(animColor)
		love.graphics.rectangle("fill", x + (self.frame / 4), y - self.frame * 2 + (self.frame / 4), 
		                        32 - (self.frame / 2), 32 - (self.frame / 2))
	end
	
	})
end

function newStaticText(x, y, text, color, life)
	table.insert(anims, {
	frame = 0,
	
	update = function(self, df)
		self.frame = self.frame + df
		
		return self.frame < life
	end,
	
	draw = function(self)
		love.graphics.setColor(color)
		love.graphics.print(text, x, y)
		
		return true
	end
	
	})
end