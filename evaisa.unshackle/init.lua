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