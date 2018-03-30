-- main.lua

vector = require("data/lua/hump/vector")
camera = require("data/lua/hump/camera")

require("data/lua/libs/kikito-middleclass")
require("data/lua/libs/kikito-middleclass-extras")
require("data/lua/libs/utility")

require("data/lua/game")
require("data/lua/inGame/inGame")

require("data/levels/level")
require("data/lua/inGame/load_level")

Game = Game:new()

function love.load()
	Game:gotoState("InGame")
	Game:load()
end

function love.draw()
	love.graphics.setColor(50, 50, 50)
	love.graphics.rectangle("fill", 0, 0, 320, 120)

	love.graphics.setColor(111, 78, 55)
	love.graphics.rectangle("fill", 0, 120, 320, 120)

	love.graphics.setColor(255, 255, 255)

	Game:draw()

	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
end

function love.update(dt)
	Game:update(dt)
end

function love.mousepressed(x, y, button)
	Game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	Game:mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
	Game:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	Game:keyreleased(key, unicode)

	if key == "escape" then
		love.event.quit()
	end
end

function love.focus(f)
	Game:focus(f)
end

function love.quit()
	Game:quit()
end