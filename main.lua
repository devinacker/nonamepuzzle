-- BAD CODE WARNING
-- this page is under construction!!!
-- plz don't look
--
-- <3, devin

require "anim"
require "boards"

game = {
	counter = 0,
	state = 0,
	
	changeTime = 0,
	changePoints = {},
	chainTime = 0,
	chainPoints = {},
}

colors = {
	{243, 120, 140, 255},
	{247, 177,  95, 255},
	{255, 255,  90, 255},
	{139, 221, 159, 255},
	{181, 241, 241, 255},
	{126, 160, 183, 255},
	{240, 204, 249, 255},
}

board = {}
win = {w = love.graphics.getWidth(), 
       h = love.graphics.getHeight()}

math.randomseed(os.time())
function randomize()
	game.changePoints = {}
	game.chainPoints = {}
	
	board.l = math.random(3, 10)
	board.w = math.random(3, 10)
	
	for y = 1, board.l do
		board[y] = {}
		for x = 1, board.w do
			board[y][x] = math.random(1, #colors)
		end
	end
	board.pieces = {}
	for i = 1, math.random(2, 5) do
		board.pieces[i] = {
			x     = math.random(1, board.w),
			y     = math.random(1, board.l),
			color = math.random(3, #colors - 2)
		}
	end
	
	boardx, boardy = win.w/2 - (32 * board.w / 2), win.h/2 - (32 * board.l / 2)
	currPiece = 1
end

function setBoard(num)

	game.changePoints = {}
	game.chainPoints = {}

	local newBoard = boards[num]
	board.l = newBoard.l
	board.w = newBoard.w
	for y = 1, board.l do
		board[y] = {}
		for x = 1, board.w do
			board[y][x] = newBoard[y][x]
		end
	end
	board.pieces = {}
	for i = 1, #newBoard.pieces do
		local piece = newBoard.pieces[i]
		board.pieces[i] = {
			x = piece.x, y = piece.y, color = piece.color
		}
	end
	
	boardx, boardy = win.w/2 - (32 * board.w / 2), win.h/2 - (32 * board.l / 2)
	currPiece = 1
end

function doColorChange(x, y, toColor)
	table.insert(game.changePoints, {x = x, y = y, color = toColor})
	
	local color = board[y][x]
	
	-- only start a chain if the color at this tile is actually changing
	if color == toColor then return end
	
	local steps = (board.l * board.w) - 1
	local r, step = 1, 1
	
	while steps > 0 do
		-- right/left
		for x1 = x + step, x + r, step do
			if x1 > 0 and y > 0 and x1 <= board.w and y <= board.l then
				steps = steps - 1
				if board[y][x1] == color then
					table.insert(game.changePoints, {x = x1, y = y, color = toColor})
				end
			end
		end
		x = x + r
		
		-- down/up
		for y1 = y + step, y + r, step do
			if x > 0 and y1 > 0 and x <= board.w and y1 <= board.l then
				steps = steps - 1
				if board[y1][x] == color then
					table.insert(game.changePoints, {x = x, y = y1, color = toColor})
				end
			end
		end
		y = y + r
		
		r, step = -(r + step), -step
	end
end

function love.keypressed(k, r)
	local piece = board.pieces[currPiece]

	-- R = restart (or change?) board
	if k == 'r' and not r then
		if love.keyboard.isDown('lshift') or
		   love.keyboard.isDown('rshift') then
			randomize()
		else
			setBoard(1)
		end
		
		game.counter = 0
			
	-- Z/X to select piece
	elseif k == 'x' and not r then
		if currPiece == #board.pieces then
			currPiece = 1
		else
			currPiece = currPiece + 1
		end
		
	elseif k == 'z' and not r then
		if currPiece == 1 then
			currPiece = #board.pieces
		else
			currPiece = currPiece - 1
		end
		
	-- C to detonate
	elseif k == 'c' and #board.pieces > 0 
			and #game.changePoints == 0 and #game.chainPoints == 0 and not r then
		
		table.insert(game.chainPoints, {x = piece.x, y = piece.y, color = piece.color})
		table.remove(board.pieces, currPiece)
		
		print("new #board.pieces = "..#board.pieces)
		if currPiece > #board.pieces then
			currPiece = #board.pieces
		end
		print("new currPiece = "..currPiece)
	-- arrows to move (TODO)
	elseif k == 'left' and piece.x > 1 then
		piece.x = piece.x - 1
	elseif k == 'right' and piece.x < board.w then
		piece.x = piece.x + 1
	elseif k == 'up' and piece.y > 1 then
		piece.y = piece.y - 1
	elseif k == 'down' and piece.y < board.l then
		piece.y = piece.y + 1
	end
end

-- this will be removed, probably
function love.mousepressed(x, y, b)
--[[
	local l = 32 * board.l
	local w = 32 * board.w
	
	if b == "l" then
		local x = math.floor((x - boardx) / 32)
		local y = math.floor((y - boardy) / 32)
		
		-- spiral out and touch all of the same color
		if x >= 0 and y >= 0 and x < board.w and y < board.l then
			table.insert(game.chainPoints, {x = x, y = y, color = math.random(1, #colors)})
		end
	end
]]
end

function love.update(dt)
	local df = math.floor(dt * 60)
	game.counter = game.counter + df
	
	-- process color changes
	if game.changeTime == 0 and #game.changePoints > 0 then
		local c = table.remove(game.changePoints, 1)
		local cx, cy = c.x - 1, c.y - 1
		
		newColorChangeAnim(boardx + (cx * 32), boardy + (cy * 32), colors[board[c.y][c.x]])
		
		board[c.y][c.x] = c.color
		
		-- is there another piece here?
		for i = 1, #board.pieces do
			local piece = board.pieces[i]
			if piece and piece.x == c.x and piece.y == c.y then
				table.insert(game.chainPoints, {x = piece.x, y = piece.y, color = piece.color})
				table.remove(board.pieces, i)
				i = i - 1
				
				-- keep the current piece index within bounds
				if currPiece > #board.pieces then
					currPiece = currPiece - 1
				end
			end
		end
		
		if #game.changePoints > 0 then
			game.changeTime = 1
		elseif #game.chainPoints > 0 then
			game.chainTime = 30
		end
	-- or wait until the next part of the color change
	elseif game.changeTime > 0 then
		game.changeTime = game.changeTime - 1
	-- or set off the next part of the chain
	elseif game.chainTime == 0 and #game.chainPoints > 0 then
		local chain = table.remove(game.chainPoints, 1)
		
		doColorChange(chain.x, chain.y, chain.color)
	-- or wait until the next part of the chain
	elseif game.chainTime > 0 then
		game.chainTime = game.chainTime - 1
	end
	
	updateAnim(df)
end

function love.draw()
	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.print('press Z/X to select piece, arrows to move, C to detonate, R to restart, shift-R to randomize', 8, 8)
	love.graphics.print('c: '..game.counter, 8, 24)
	love.graphics.print('s: '..game.state, 8, 40)
	love.graphics.print('ct: '..game.changeTime, 8, 56)
	love.graphics.print('#cp: '..#game.changePoints, 8, 72)
	love.graphics.print('cht: '..game.chainTime, 8, 88)
	love.graphics.print('#chp: '..#game.chainPoints, 8, 104)
	
	local l = 32 * board.l
	local w = 32 * board.w
	
	-- draw board
	for y = 0, board.l - 1 do
		for x = 0, board.w - 1 do
			if board[y + 1][x + 1] then
				love.graphics.setColor(colors[board[y + 1][x + 1]])
				love.graphics.rectangle("fill", win.w/2 - (w / 2) + (x * 32),
				                        win.h/2 - (l / 2) + (y * 32),
				                        32, 32)
			end
		end
	end
	
	-- draw pieces
	for i = 1, #board.pieces do
		local piece = board.pieces[i]
		
		local x = win.w/2 - (w / 2) + ((piece.x - 1) * 32) + 6
		local y = win.h/2 - (l / 2) + ((piece.y - 1) * 32) - 4
		-- wavy sine animation
		if i == currPiece then
			y = y + 6 * math.sin(math.pi * 8 * game.counter / 360) - 6
		end
		
		-- draw a triangle
		love.graphics.setColor({0, 0, 0})
		love.graphics.polygon('fill', x, y, x + 20, y, x + 10, y + 20)
		love.graphics.setColor(colors[piece.color])
		love.graphics.polygon('fill', x + 2, y + 2, x + 18, y + 2, x + 10, y + 18)
	end
	
	-- draw animations
	drawAnim()
end

love.window.setTitle("This is a test!")
setBoard(1)
--randomize()