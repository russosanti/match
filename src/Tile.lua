--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, special)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.special = special or false

    if special then
        -- Particle system for sparkle effect on special tiles
        self:startEffect()
    end
end

function Tile:update(dt)
    if self.psystem then
        self.psystem:update(dt)
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.psystem then
        love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
    end
end

function Tile:startEffect()
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 200)
    self.psystem:setParticleLifetime(0.4, 0.8)
    self.psystem:setEmissionRate(45)
    self.psystem:setSizes(0.45, 0.2)
    self.psystem:setSpeed(1, 6)
    self.psystem:setLinearAcceleration(-3, -6, 3, 2)
    self.psystem:setEmissionArea('uniform', 15, 15)
    self.psystem:setColors(1, 1, 1, 0.9, 1, 1, 1, 0)
    self.psystem:start()
end

function Tile:startDestroyingEffect()
    self:startEffect()
end