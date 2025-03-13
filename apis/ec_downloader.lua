local rawURLTemp = "https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s" -- URL for the raw file data: User/Repo/Branch
local gitURLTemp = "https://api.github.com/repos/%s/%s/git/trees/%s?=recursive=1" -- URL for the list of files in said repo: User/Repo/Branch

local branch = "main" -- Default branch

local dl = {}

function dl.getRepo(user, repo, branch)
    local dirs = {}
    local files = {}

    local gitURL = string.format(gitURLTemp, user, repo, branch)
    local handle = http.get(gitURL)
    
    if not handle then return 1,"Couldn't find URL" end

    local data = textutils.unserialiseJSON(handle.readAll())
    local content = data.tree
    for i,file in pairs(content) do
        if file.type == "path" then
            table.insert(dirs, file.path)
        elseif file.type == "blob" then
            table.insert(files, file.path)
        end
    end

    return files, dirs
end

function dl.downloadFile(user, repo, branch, file, fileName)
    local rawURL = string.format(rawURLTemp, user, repo, branch, file)
    local handle = http.get(rawURL)

    if not handle then return 1,"Couldn't find URL" end

    local data = handle.readAll()
    local f = fs.open(fileName, "w")
    f.write(data)
    f.close()

    return 0
end

return dl
