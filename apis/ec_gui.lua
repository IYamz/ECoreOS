local gui = {}

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

return gui
