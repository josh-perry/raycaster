-- data/lua/game.lua

Game = class("Game")
Game:include(Stateful)

function Game:load()
end

function Game:draw()
end

function Game:update(dt)
end

function Game:mousepressed(x, y, button)
end

function Game:mousereleased(x, y, button)
end

function Game:keypressed(key, unicode)
end

function Game:keyreleased(key, unicode)
end

function Game:focus(f)
end

function Game:quit()
end