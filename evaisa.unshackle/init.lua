lfs = dofile("mods/evaisa.unshackle/lib/lfs.lua")

dofile("data/scripts/lib/coroutines.lua")

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
    ModLuaFileAppend("mods/evaisa.unshackle/functions.lua", "mods/evaisa.unshackle/example.lua")
end


function OnWorldPreUpdate() 
    dofile("mods/evaisa.unshackle/functions.lua")
    wake_up_waiting_threads(1)
    Update()
end

function OnPausePreUpdate()
    dofile("mods/evaisa.unshackle/functions.lua")
    Update()
end

function OnPlayerSpawned()
    --local api = dofile("mods/evaisa.unshackle/functions.lua")
    --api.Save("test.txt", "Hello world!")
end