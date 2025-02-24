love.graphics.setDefaultFilter("nearest", "nearest")

local grid = {}
local grid_width = 10
local grid_height = 20
local cell_size = 30
local tetris_blocks = {
    {{1, 1, 1, 1}}, -- I block
    {{1, 1}, {1, 1}}, -- O block
    {{0, 1, 0}, {1, 1, 1}}, -- T block
    {{1, 0}, {1, 0}, {1, 1}}, -- L block
    {{1, 0}, {1, 1}, {0, 1}}, -- 4 block
    {{1, 0, 1}, {1, 1, 1}} -- U block
}
local current_block, block_x, block_y
local drop_time = 0 
local drop_speed = 0.5
local game_over = false
local show_controls = true
local control_timer = 10

function resetGrid()
    for y = 1, grid_height do
        grid[y] = {}
        for x = 1, grid_width do
            grid[y][x] = 0
        end
    end
end

function checkFullLines()
    for y = 1, grid_height, 1 do
        local full = true
        for x = 1, grid_width do
            if grid[y][x] == 0 then
                full = false
                break
            end
        end
        if full then
            table.remove(grid, y)
            table.insert(grid, 1, {})
            for x = 1, grid_width do
                grid[1][x] = 0
            end
        end
    end
end

function checkGameOver()
    for x = 1, grid_width do
        if grid[1][x] == 1 then
            game_over = true
        end
    end
end

function spawnBlock()
    current_block = tetris_blocks[math.random(#tetris_blocks)]
    block_x, block_y = math.floor(grid_width / 2) - 1, 1
    if not canMove(0, 0) then
        game_over = true
    end
end

function love.load()
    love.window.setMode(grid_width * cell_size, grid_height * cell_size)
    resetGrid()
    spawnBlock()
end

function collidesX(dx)
    for y, row in ipairs(current_block) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                local new_x = block_x + x + dx - 1
                if new_x < 1 or new_x > grid_width then
                    return true
                end
            end
        end
    end
    return false
end

function collidesY(dy)
    for y, row in ipairs(current_block) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                local new_y = block_y + y + dy - 1
                if new_y > grid_height then
                    return true
                end
            end
        end
    end
    return false
end

function collidesBlock(dx, dy)
    for y, row in ipairs(current_block) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                local new_x, new_y = block_x + x + dx - 1, block_y + y + dy - 1
                if grid[new_y] and grid[new_y][new_x] == 1 then
                    return true
                end
            end
        end
    end
    return false
end

function canMove(dx, dy)
    if collidesX(dx) then return false end
    if collidesY(dy) then return false end
    if collidesBlock(dx, dy) then return false end
    return true
end

function placeBlock()
    for y, row in ipairs(current_block) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                grid[block_y + y - 1][block_x + x - 1] = 1
            end
        end
    end
    checkFullLines()
    checkGameOver()
    if not game_over then
        spawnBlock()
    end
end

function rotateBlock()
    local rotated = {}
    for x = 1, #current_block[1] do
        rotated[x] = {}
        for y = #current_block, 1, -1 do
            rotated[x][#current_block - y + 1] = current_block[y][x]
        end
    end
    current_block = rotated
end

function love.update(dt)
    if game_over then 
        return 
    end
    drop_time = drop_time + dt
    if drop_time >= drop_speed then
        if canMove(0, 1) then
            block_y = block_y + 1
        else
            placeBlock()
        end
        drop_time = 0
    end
    if show_controls then
        control_timer = control_timer - dt
        if control_timer <= 0 then
            show_controls = false
        end
    end
end

function love.keypressed(key)
    if game_over then return end
    if key == "left" and canMove(-1, 0) then
        block_x = block_x - 1
    elseif key == "right" and canMove(1, 0) then
        block_x = block_x + 1
    elseif key == "down" and canMove(0, 1) then
        block_y = block_y + 1
    elseif key == "up" then
        rotateBlock()
    end
end

function love.draw()    
    if show_controls then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Controls: Left/Right - Move,\n Down - Speed Drop,\n Up - Rotate", 0, 5, grid_width * cell_size, "center")
    end
    
    for y = 1, grid_height do
        for x = 1, grid_width do
            if grid[y][x] == 1 then
                love.graphics.rectangle("fill", (x - 1) * cell_size, (y - 1) * cell_size, cell_size, cell_size)
            end
        end
    end
    
    love.graphics.setColor(0, 1, 0)
    for y, row in ipairs(current_block) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                love.graphics.rectangle("fill", (block_x + x - 2) * cell_size, (block_y + y - 2) * cell_size, cell_size, cell_size)
            end
        end
    end
    
    if game_over then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Game Over", 0, grid_height * cell_size / 2 - 10, grid_width * cell_size, "center")
    end
end
