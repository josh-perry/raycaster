-- data/lua/inGame/load_level.lua

function load_level(toLoad)
	local image = love.image.newImageData(toLoad)

	for i = 0, image:getWidth() - 1 do
		level[i] = {}
		for j = 0, image:getHeight() - 1 do
			r, g, b, a = image:getPixel(i, j)

			if i == 0 or i == image:getWidth() - 1 then
				level[i][j] = 1
			elseif j == 0 or j == image:getHeight() - 1 then
				level[i][j] = 1
			elseif r + g + b < 255 * 3 then
				level[i][j] = 2
			else
				level[i][j] = 0
			end
		end
	end
end