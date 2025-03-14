local cf = {}

local function updateSettings(settings)
    local f = fs.open(".config", "w")
    f.write(textutils.serialise(settings))
    f.close()
end

function cf.getAll()
    if not fs.exists(".config") then
        local f = fs.open(".config", "w")
        f.write("{}")
        f.close()
    end
    local f = fs.open(".config", "r")
    local data = textutils.unserialise(f.readAll())
    f.close()

    return data or {}
end

function cf.get(setting)
    local data = cf.getAll()

    if not data[setting] then
        return -1,"Setting not found"
    end

    return data[setting].value
end

function cf.set(setting, newValue)
    local data = cf.getAll()

    if data[setting] then
        data[setting].value = newValue
    else
        local newSetting = {}
        newSetting.name = setting or nil
        newSetting.value = newValue or nil
        data[setting] = newSetting
    end
    updateSettings(data)

    return 0
end

function cf.remove(setting)
    local data = cf.getAll()

    if not data[setting] then return -1,"Setting not found" end
    
    data[setting] = nil
    updateSettings(data)

    return 0
end

return cf
