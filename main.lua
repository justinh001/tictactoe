ttt = {}

function ttt:drawGrid()
    love.graphics.setColor(255 ,255, 255)
    local w, h = ttt.win_w / 3, ttt.win_h / 3
    love.graphics.setLineWidth(5)
    for i = 0, 1 do
        love.graphics.line((i * w) + w, 0, (i * w) + w, ttt.win_h)
        love.graphics.line(0, (i * h) + h, ttt.win_w, (i * h) + h)
    end
end

function ttt:drawPositions()
    local cell_w, cell_h = (ttt.win_w / 3), (ttt.win_h / 3)

    for y = 0, 2 do
        for x = 0, 2 do
            if (ttt.player_positions[y + 1][x + 1] == 1) then --draw an X
                love.graphics.draw(ttt.resources.x, (x * cell_w) + (cell_w * 0.5) - 75, (y * cell_h) + (cell_h * 0.5) - 75, 0, 0.5, 0.5)
            elseif (ttt.player_positions[y + 1][x + 1] == -1) then --draw an O
                love.graphics.draw(ttt.resources.o, (x * cell_w) + (cell_w * 0.5) - 75, (y * cell_h) + (cell_h * 0.5) - 75, 0, 0.5, 0.5)
            end
        end
    end
end

function ttt:AIPlay()
    local rand = math.random(9 - ttt.turns_played)
    local empty_cells_traversed = 0
    for y = 1, 3 do
        for x = 1, 3 do
            if (ttt.player_positions[y][x] == 0) then
                empty_cells_traversed = empty_cells_traversed + 1
                if (empty_cells_traversed == rand) then
                    ttt.player_positions[y][x] = ttt.ai_type
                    ttt:checkWin(ttt.ai_type)
                    return
                end
            end
        end
    end
end

function ttt:checkWin(ply)
    ttt.turns_played = ttt.turns_played + 1

    local function check_horizontal()
        for i = 1, 3 do
            if (ttt.player_positions[i][1] == ply) and (ttt.player_positions[i][2] == ply) and (ttt.player_positions[i][3] == ply) then
                return true
            end
        end
        return false
    end

    local function check_vertical()
        for i = 1, 3 do
            if (ttt.player_positions[1][i] == ply) and (ttt.player_positions[2][i] == ply) and (ttt.player_positions[3][i] == ply) then
                return true
            end
        end
        return false
    end

    local function check_diagonal()
        if (ttt.player_positions[1][1] == ply) and (ttt.player_positions[2][2] == ply) and (ttt.player_positions[3][3] == ply) or
         (ttt.player_positions[1][3] == ply) and (ttt.player_positions[2][2] == ply) and (ttt.player_positions[3][1] == ply) then
            return true
        end
        return false
    end

    if check_horizontal() or check_vertical() or check_diagonal() then
        love.audio.play(ttt.resources.game_end)
        if (ply == ttt.player_type) then
            ttt.winner = ttt.player_type
        else
            ttt.winner = ttt.ai_type
        end
        ttt.gamestate = "over"
        return
    end

    if (ttt.turns_played == 9) then --tie
        love.audio.play(ttt.resources.game_end)
        ttt.gamestate = "over"
    end
end

function ttt:Reset()
    ttt.player_positions = { --0 = empty, 1 = X, -1 = O
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    }
    ttt.turns_played = 0
    ttt.winner = 0
    ttt.gamestate = "playing"
end

function love.load()
    math.randomseed(os.time())

    love.window.setTitle("Tic-Tac-Toe")
    love.graphics.setBackgroundColor(0.549, 0.549, 0.541)
    love.window.setMode(600, 600, {
        resizable = true,
        minwidth = 600,
        minheight = 600
    })
    ttt.win_w = 600
    ttt.win_h = 600

    ttt.player_type = math.random(2) * 2 - 3
    ttt.ai_type = (ttt.player_type == 1) and -1 or 1 --1 = X, -1 = O

    ttt:Reset()

    --resource cache
    ttt.resources = {}

    --fonts
    ttt.resources.overfont = love.graphics.newFont(70)
    ttt.resources.fpsfont = love.graphics.newFont(12)

    --sound
    ttt.resources.click_sound = love.audio.newSource("resources/click.ogg", "static")
    ttt.resources.error_sound = love.audio.newSource("resources/click_error.ogg", "static")
    ttt.resources.game_end = love.audio.newSource("resources/game_end.ogg", "static")

    --images
    ttt.resources.x = love.graphics.newImage("resources/x.png")
    ttt.resources.o = love.graphics.newImage("resources/o.png")
end

function love.draw()
    ttt:drawGrid() --draw crosshatches
    ttt:drawPositions() --draw whats in each cell

    if (ttt.gamestate == "over") then
        local text_color = {125, 125, 125}
        local game_over_type = "Tie!"
        if (ttt.winner == ttt.player_type) then
            text_color = {0, 255, 0}
            game_over_type = "Win!"
        elseif (ttt.winner ~= 0) then
            text_color = {255, 0, 0}
            game_over_type = "Lose!"
        end
        love.graphics.setFont(ttt.resources.overfont)
        local over_text_w, over_text_h = ttt.resources.overfont:getWidth(game_over_type), ttt.resources.overfont:getHeight(game_over_type)
        love.graphics.print({text_color, game_over_type}, (ttt.win_w * 0.5) - (over_text_w * 0.5), (ttt.win_h * 0.5) - (over_text_h * 0.5))
    end
end

function love.mousepressed(x, y, button)
    if (button ~= 1) then --ignore anything other than left click
        love.audio.play(ttt.resources.error_sound)
        return
    end

    if (ttt.gamestate == "over") then --clicking once after a game will reset the board
        ttt.gamestate = "playing"
        ttt:Reset()
        return
    end

    local cell_x, cell_y = math.floor(x / (ttt.win_w / 3) + 1), math.floor(y / (ttt.win_h / 3) + 1)
    if (ttt.player_positions[cell_y][cell_x] ~= 0) then --trying to place on already populated cell
        love.audio.play(ttt.resources.error_sound)
    else --open cell
        love.audio.play(ttt.resources.click_sound)
        ttt.player_positions[cell_y][cell_x] = ttt.player_type
        ttt:checkWin(ttt.player_type)
        if (ttt.gamestate == "over") then return end
        ttt:AIPlay()
    end
end

function love.resize(w, h) ttt.win_w, ttt.win_h = w, h end