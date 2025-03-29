local log = {}

local function createLogFile(name)
    local f = fs.open("/logs/" .. name, "w")
    f.write("{}")
    f.close()
end

local function getLogData(name)
    local f = fs.open("/logs/" .. name, "r")
    
    return textutils.unserialise(f.readAll())
end

local function updateLog(name, newData)
    local f = fs.open("/logs/" .. name, "w")
    f.write(textutils.serialise(newData))
    f.close()
end

function log.new(logName, entry, includeDate)
    if not fs.exists("/logs/" .. logName) then
        createLogFile(logName)
    end
    local data = getLogData(logName)
    table.insert(data, includeDate == true and os.date("[%m/%d/%Y %H:%M] ") .. entry or entry)
    updateLog(logName, data)
end

return log
