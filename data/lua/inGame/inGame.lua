-- data/lua/inGame/inGame.lua

local InGame = Game:addState("InGame")

function InGame:load()
	love.graphics.setBackgroundColor(100, 149, 235)

	screen = {w = love.graphics:getWidth(), h = love.graphics:getHeight()}

	player = {}
	player.pos = {x = 3, y = 3}
	player.dir = {x = -1, y = 0} -- Direction

	plane = {}
	plane.x = 0
	plane.y = 0.66

	level = {}
	textures = {
		love.image.newImageData("data/gfx/textures/bluestone.png"),
		love.image.newImageData("data/gfx/textures/colorstone.png"),
		love.image.newImageData("data/gfx/textures/eagle.png"),
		love.image.newImageData("data/gfx/textures/greystone.png"),
		love.image.newImageData("data/gfx/textures/mossy.png"),
		love.image.newImageData("data/gfx/textures/purplestone.png"),
		love.image.newImageData("data/gfx/textures/redbrick.png"),
		love.image.newImageData("data/gfx/textures/wood.png")
	}

	texture_size = 128
	texture_mode = false

	canvas = love.image.newImageData(screen.w + 1, screen.h + 1)

	camera = {}
	ray = {pos = {}, dir = {}}
	map = {}
	sideDist = {}
	deltaDist = {}
	step = {}

	load_level("data/levels/level1_2.png")
	-- level = require("data/levels/level")
end

function InGame:draw()
	for x = 0, screen.w do
		camera.x = 2 * x / screen.w - 1
		ray.pos.x = player.pos.x
		ray.pos.y = player.pos.y
		ray.dir.x = player.dir.x + plane.x * camera.x
		ray.dir.y = player.dir.y + plane.y * camera.x

		map.x = math.floor(ray.pos.x)
		map.y = math.floor(ray.pos.y)

		sideDist.x = 0
		sideDist.y = 0

		deltaDist.x = math.sqrt(1 + (ray.dir.y^2) / (ray.dir.x^2))
		deltaDist.y = math.sqrt(1 + (ray.dir.x^2) / (ray.dir.y^2))

		perpWallDist = 0

		step.x = 0
		step.y = 0

		hit = 0
		side = 0

		if ray.dir.x < 0 then
			step.x = -1
			sideDist.x = (ray.pos.x - map.x) * deltaDist.x
		else
			step.x = 1
			sideDist.x = (map.x + 1 - ray.pos.x) * deltaDist.x
		end

		if ray.dir.y < 0 then
			step.y = -1
			sideDist.y = (ray.pos.y - map.y) * deltaDist.y
		else
			step.y = 1
			sideDist.y = (map.y + 1 - ray.pos.y) * deltaDist.y
		end

		while hit == 0 do
			if sideDist.x < sideDist.y then
	          	sideDist.x = sideDist.x + deltaDist.x;
	          	map.x = map.x + step.x;
	          	side = 0;
	        else
	          	sideDist.y = sideDist.y + deltaDist.y;
	         	map.y = map.y + step.y;
	        	side = 1;
	        end

	        if level[map.x][map.y] > 0 then
	        	hit = 1
	        end
		end

		if side == 0 then
			perpWallDist = math.abs((map.x - ray.pos.x + (1 - step.x) / 2) / ray.dir.x)
		else
			perpWallDist = math.abs((map.y - ray.pos.y + (1 - step.y) / 2) / ray.dir.y)
		end

		lineHeight = math.abs(screen.h / perpWallDist)

		drawStart = -lineHeight / 2 + screen.h / 2

		if drawStart < 0 then
			drawStart = 0
		end

		drawEnd = lineHeight / 2 + screen.h / 2

		if drawEnd >= screen.h then
			drawEnd = screen.h - 1
		end

		--texture_mode = true
		if not texture_mode then
			colour = {r = 0, g = 0, b = 0}

			if level[map.x][map.y] == 1 then
				colour = {r = 255, g = 128, b = 128}
			elseif level[map.x][map.y] == 2 then
				colour = {r = 128, g = 255, b = 128}
			elseif level[map.x][map.y] == 3 then
				colour = {r = 128, g = 128, b = 255}
			elseif level[map.x][map.y] == 4 then
				colour = {r = 255, g = 255, b = 255}
			else
				colour = {r = 255, g = 255, b = 128}
			end

			if side == 1 then
				colour.r = colour.r / 2
				colour.g = colour.g / 2
				colour.b = colour.b / 2
			end

			love.graphics.setColor(colour.r, colour.g, colour.b)
			love.graphics.line(x, drawStart, x, drawEnd)
		else -- Use textures
			texNum = level[map.x][map.y]

			if side == 1 then
				wallX = ray.pos.x + ((map.y - ray.pos.y + (1 - step.y) / 2) / ray.dir.y) * ray.dir.x
			else
				wallX = ray.pos.y + ((map.x - ray.pos.x + (1 - step.x) / 2) / ray.dir.x) * ray.dir.y
			end

			wallX = wallX - math.floor(wallX)

			texX = wallX * texture_size
			if side == 0 and ray.dir.x > 0 then texX = texture_size - texX - 1 end
			if side == 1 and ray.dir.y < 0 then texX = texture_size - texX - 1 end

			for y = drawStart, drawEnd do
			    d = y * 256 - screen.h * 128 + lineHeight * 128
			    texY = ((d * texture_size) / lineHeight) / 256

			    colour = {}
				colour.r, colour.g, colour.b, a = textures[1]:getPixel(1, 1)

				canvas:setPixel(x, y, colour.r, colour.g, colour.b, 255)
			end
		end
	end

	--love.graphics.setColor(colour.r, colour.g, colour.b)
	love.graphics.draw(love.graphics.newImage(canvas), 0, 0)
end

function InGame:update(dt)
	moveSpeed = dt * 5
	rotSpeed = dt

	love.mouse.setPosition(love.graphics:getWidth() / 2, love.graphics:getHeight() / 2)
	if love.mouse.getX() < love.graphics:getWidth() / 2 then
		self:turn_left((love.graphics:getWidth() / 2) - love.mouse.getX())
	elseif love.mouse.getX() > love.graphics:getWidth() / 2 then
		self:turn_right(love.mouse.getX() - (love.graphics:getWidth() / 2))
	end

	if love.keyboard.isDown("w") then
		self:move_forward()
	end

	if love.keyboard.isDown("s") then
		self:move_backward()
	end

	if love.keyboard.isDown("a") then
		self:turn_left(0)
	end

	if love.keyboard.isDown("d") then
		self:turn_right(0)
	end

	if love.mouse.isDown(2) then
		self:move_forward()
	end

	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function InGame:mousepressed(x, y, button)
end

function InGame:mousereleased(x, y, button)
end

function InGame:keypressed(key, unicode)
end

function InGame:keyreleased(key, unicode)
end

function InGame:focus(f)
end

function InGame:quit()
end

function InGame:move_forward()
	if level[math.floor(player.pos.x + player.dir.x * moveSpeed)][math.floor(player.pos.y)] == 0 then
		player.pos.x = player.pos.x + player.dir.x * moveSpeed
	end

	if level[math.floor(player.pos.x)][math.floor(player.pos.y + player.dir.y * moveSpeed)] == 0 then
		player.pos.y = player.pos.y + player.dir.y * moveSpeed
	end
end

function InGame:move_backward()
	if level[math.floor(player.pos.x - player.dir.x * moveSpeed)][math.floor(player.pos.y)] == 0 then
		player.pos.x = player.pos.x - player.dir.x * moveSpeed
	end

	if level[math.floor(player.pos.x)][math.floor(player.pos.y - player.dir.y * moveSpeed)] == 0 then
		player.pos.y = player.pos.y - player.dir.y * moveSpeed
	end
end

function InGame:turn_left(a)
	if a ~= 0 then rotSpeed = (rotSpeed * (a / 2)) end

	oldDir = {x = player.dir.x}
	player.dir.x = player.dir.x * math.cos(rotSpeed) - player.dir.y * math.sin(rotSpeed)
	player.dir.y = oldDir.x * math.sin(rotSpeed) + player.dir.y * math.cos(rotSpeed)
	oldplane = {x = plane.x}
	plane.x = plane.x * math.cos(rotSpeed) - plane.y * math.sin(rotSpeed)
	plane.y = oldplane.x * math.sin(rotSpeed) + plane.y * math.cos(rotSpeed)
end

function InGame:turn_right(a)
	if a ~= 0 then rotSpeed = (rotSpeed * (a / 2)) end

	oldDir = {x = player.dir.x}
	player.dir.x = player.dir.x * math.cos(-rotSpeed) - player.dir.y * math.sin(-rotSpeed)
	player.dir.y = oldDir.x * math.sin(-rotSpeed) + player.dir.y * math.cos(-rotSpeed)
	oldplane = {x = plane.x}
	plane.x = plane.x * math.cos(-rotSpeed) - plane.y * math.sin(-rotSpeed)
	plane.y = oldplane.x * math.sin(-rotSpeed) + plane.y * math.cos(-rotSpeed)
end