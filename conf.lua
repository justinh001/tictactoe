function love.conf(t)
    t.version = "11.5"

    t.window.title = "Tic-Tac-Toe"
    t.window.width = 600
    t.window.height = 600
    t.window.resizable = true

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.thread = false
    t.modules.touch = false
    t.modules.timer = false
    t.modules.math = false
end