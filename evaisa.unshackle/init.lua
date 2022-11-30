package.path = package.path .. ";./mods/evaisa.unshackle/lib/?.lua"
package.path = package.path .. ";./mods/evaisa.unshackle/lib/?/init.lua"
package.cpath = package.cpath .. ";./mods/evaisa.unshackle/bin/?.dll"

lfs = dofile("mods/evaisa.unshackle/lib/lfs.lua")

dofile("data/scripts/lib/coroutines.lua")

local function load(modulename)
    local errmsg = ""
    for path in string.gmatch(package.path, "([^;]+)") do
      local filename = string.gsub(path, "%?", modulename)
      local file = io.open(filename, "rb")
      if file then
        -- Compile and return the module
        return assert(loadstring(assert(file:read("*a")), filename))
      end
      errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
    end
    return errmsg
end

table.insert(package.loaders, 2, load)



function isFile(name)
    if type(name)~="string" then return false end
    if not isDir(name) then
        return os.rename(name,name) and true or false
        -- note that the short evaluation is to
        -- return false instead of a possible nil
    end
    return false
end

function isFileOrDir(name)
    if type(name)~="string" then return false end
    return os.rename(name, name) and true or false
end

function isDir(name)
    if type(name)~="string" then return false end
    local cd = lfs.currentdir()
    local is = lfs.chdir(name) and true or false
    lfs.chdir(cd)
    return is
end

for i = 0, ModSettingGetCount()-1 do
    local setting = ModSettingGetAtIndex( i )
    -- if setting starts with unshackle. then remove it
    if(setting ~= nil)then
        if string.sub(setting, 1, 10) == "unshackle." then
            ModSettingRemove(setting)
        end
    end
end

function OnMagicNumbersAndWorldSeedInitialized()
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnMagicNumbersAndWorldSeedInitialized()
    ModLuaFileAppend("mods/evaisa.unshackle/functions.lua", "mods/evaisa.unshackle/example.lua")
end

function OnWorldInitialized()
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnWorldInitialized()
end

function OnWorldPreUpdate() 
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnWorldPreUpdate()
    dofile("mods/evaisa.unshackle/functions.lua")
    wake_up_waiting_threads(1)
    Update()
end

function OnWorldPostUpdate()
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnWorldPostUpdate()
end

function OnPausePreUpdate()
    dofile("mods/evaisa.unshackle/functions.lua")
    Update()
end

function OnPlayerSpawned()
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnPlayerSpawned()
    --local api = dofile("mods/evaisa.unshackle/functions.lua")
    --api.Save("test.txt", "Hello world!")
end

function OnPlayerDeath()
    __loaded["mods/evaisa.unshackle/hooks.lua"] = nil
    local hooks = dofile("mods/evaisa.unshackle/hooks.lua")
    hooks.OnPlayerDeath()
end