local gui = {}
gui.buttons = {}
gui.buttons.list = {}

gui.primary = nil
gui.w = nil
gui.h = nil
gui.primaryBG = nil
gui.primaryFG = nil

function gui.setPrimary(screen, bg, fg)
    local ok, err = pcall(function() screen.getSize() end)
    if not ok then print("'" .. screen .. "' is not a valid screen.") return 1,"Invalid screen!" end

    gui.primary = screen
    gui.w,gui.h = screen.getSize()
    gui.primaryBG = bg or colors.black
    gui.primaryFG = fg or colors.white

    screen.setBackgroundColor(gui.primaryBG)
    screen.setTextColor(gui.primaryFG)
    screen.clear()

    return 0
end

local function skip()
    local x, y = gui.primary.getCursorPos()
    gui.primary.setCursorPos(1, y + 1)
    if y + 1 > gui.h then
        gui.primary.scroll(1)
        gui.primary.setCursorPos(1, y)
    end
end

local function printNoSkip(text)
    for word in text:gmatch("%s*[^%s]+%s*") do
        local x, y = gui.getPos()
        if x + #word > gui.w then
            skip()
        end

        gui.write(word)
    end
end

function gui.setBG(color)
    gui.primary.setBackgroundColor(color)
end

function gui.setFG(color)
    gui.primary.setTextColor(color)
end

function gui.setPos(x, y)
    gui.primary.setCursorPos(x, y)
end

function gui.getPos(x, y)
    local x, y = gui.primary.getCursorPos()

    return x, y
end

function gui.clear()
    gui.primary.clear()
end

function gui.clearLine(line)
    gui.setPos(1, line)
    for i = 1, gui.w do
        gui.primary.write(" ")
    end
end

function gui.clearBox(startY, endY)
    for i = startY, endY do
        gui.clearLine(i)
    end
end

function gui.write(text)
    gui.primary.write(text)
end

function gui.centerWrite(text, line, offset)
    if line == true then
        line = gui.h / 2 + offset
    end
    gui.setPos(math.ceil(gui.w / 2 - string.len(text) / 2), line)
    gui.write(text)
end

function gui.writeFormatted(...)
    local formatting = {...}

    for i,data in pairs(formatting) do
        if type(data) == "table" then
            gui.setFG(data[2])
            gui.write(data[1])
            gui.setFG(gui.primaryFG)
        else
            write(data)
        end
    end
end

function gui.print(text)
    printNoSkip(text)
    skip()
end

function gui.printFormatted(...)
    local formatting = {...}

    for i,data in pairs(formatting) do
        if type(data) == "table" then
            gui.setFG(data[2])
            printNoSkip(data[1])
            gui.setFG(gui.primaryFG)
        else
            printNoSkip(data)
        end
    end
    skip()
end

function gui.buttons.add(label, data)
    if not label then print("Button must have a label!") return end
    if type(label) ~= "string" then print("Object label must be a string!") return end
    if data and type(data) ~= "table" then print("Object data must be a table!") return end
    if not data then data = {} end

    local newButton = {}
    newButton.label = label
    newButton.text = data.text or "Button"
    newButton.on_click = data.on_click or function() end
    newButton.x = data.x or 1
    newButton.y = data.y or 1
    if newButton.x == true then
        newButton.x = math.floor(gui.w / 2 - string.len(" " .. newButton.text .. " ") / 2)
    end
    if newButton.y == true then
        newButton.y = math.floor(gui.h / 2)
    end
    newButton.bg_color = data.bg_color or colors.blue
    newButton.fg_color = data.fg_color or colors.white
    newButton.hl_color = data.hl_color or colors.lightBlue
    newButton.do_shadow = data.do_shadow or 1

    gui.buttons.list[label] = newButton
end

local function drawButton(label, hl)
    local button = gui.buttons.list[label]
    if not button then print("Button '" .. label .. "' not found!") return end

    gui.setPos(button.x, button.y)
    gui.setBG(hl == true and button.hl_color or button.bg_color)
    gui.setFG(button.fg_color)
    gui.write(" " .. button.text .. " ")
    gui.setBG(gui.primaryBG)
    gui.setFG(gui.primaryFG)
    if button.do_shadow == 1 then
        gui.setFG(colors.black)
        gui.write(string.char(148))
        gui.setPos(button.x, button.y + 1)
        gui.write(string.char(130))
        for i = 1, string.len(" " .. button.text .. " ") - 1 do
            gui.write(string.char(131))
        end
        gui.write(string.char(129))
        gui.setFG(gui.primaryFG)
    end
end

local function hlButton(label)
    drawButton(label, true)
    sleep(0.1)
    drawButton(label, false)
end

function gui.buttons.draw()
    for i,button in pairs(gui.buttons.list) do
        drawButton(button.label)
    end
end

function gui.update()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if event == "mouse_click" or "monitor_touch" then
            for i,button in pairs(gui.buttons.list) do
                if x >= button.x and x <= button.x + button.text:len() + 1 and y == button.y then
                    hlButton(button.label)
                    button.on_click()
                end
            end
        end
    end
end

return gui
