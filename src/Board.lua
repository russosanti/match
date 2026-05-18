--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level or 1
    self.matches = {}
    self.colorPool = self:getColorPool()

    self:initializeTiles()
end

-- Get max Tile variety based on level. Starts on level 3 and increses every 2 levels til 6
function Board:getMaxTileVariety()
    return math.min(6, math.floor((self.level + 1) / 2))
end

-- Creates a new Tile. Used when generating board and creating falling tiles
function Board:createTile(x, y)
    if x == 4 and y==4 then
        return Tile(x, y, self.colorPool[math.random(#self.colorPool)], math.random(self:getMaxTileVariety()), true)
    end
    return Tile(x, y, self.colorPool[math.random(#self.colorPool)], math.random(self:getMaxTileVariety()))
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            local tile = self:createTile(tileX, tileY)

            -- Check and fix any initial matches on the board by regenerating the tile if it is in a match
            while (tileX >= 3 and self.tiles[tileY][tileX - 1].color == tile.color and
                   self.tiles[tileY][tileX - 2].color == tile.color) or
                  (tileY >= 3 and self.tiles[tileY - 1][tileX].color == tile.color and
                   self.tiles[tileY - 2][tileX].color == tile.color) do

                tile = self:createTile(tileX, tileY)
            end 
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], tile)
        end
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1
    local specialMatch = false

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}
                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last column by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches (moving by rows now)
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile in column
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end
    -- Expans or explode the special tiles
    matches = self:expandSpecialMatches(matches)
    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = self:createTile(x, y)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end

function Board:getColorPool()
    local colors = {}

    -- table with all the colors
    for i = 1, 18 do
        table.insert(colors, i)
    end

    local colorPool = {}
    local maxColors = math.min(7, 3 + math.floor(self.level / 2))

    for i = 1, maxColors do
        local color = math.random(#colors)
        table.insert(colorPool, colors[color])
        table.remove(colors, color)
    end
    return colorPool
end

function Board:containsTile(match, tile)
    for _, matchTile in pairs(match) do
        if matchTile == tile then
            return true
        end
    end

    return false
end

function Board:expandSpecialMatches(matches)
    for _, match in pairs(matches) do
        local checkedSpecials = {}

        -- index-based loop is intentional: match grows while we iterate it.
        -- This allows chained special tiles found in added rows/columns to expand too.
        local index = 1
        while index <= #match do
            local tile = match[index]

            if tile.special and not self:containsTile(checkedSpecials, tile) then
                table.insert(checkedSpecials, tile)

                -- add the whole row for this special tile
                for x = 1, 8 do
                    local rowTile = self.tiles[tile.gridY][x]

                    if rowTile and not self:containsTile(match, rowTile) then
                        table.insert(match, rowTile)
                    end
                end

                -- add the whole column for this special tile
                for y = 1, 8 do
                    local columnTile = self.tiles[y][tile.gridX]

                    if columnTile and not self:containsTile(match, columnTile) then
                        table.insert(match, columnTile)
                    end
                end
            end

            index = index + 1
        end
    end

    return matches
end