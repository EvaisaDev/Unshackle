local smallfolk = dofile("mods/evaisa.unshackle/lib/smallfolk.lua")

local custom_api = {}

local api = {}

function RegisterFunction(name, func)
    table.insert(custom_api, {name = name, func = func})
    api[name] = function(...)
        local arg={...}
        local saved = smallfolk.dumpsies(arg);
        ModSettingSet("unshackle."..name, saved)
    end
end

function Update()
    for i, v in ipairs(custom_api)do
        if(ModSettingGet("unshackle."..v.name) ~= nil)then
            v.func(unpack(smallfolk.loadsies(ModSettingGet("unshackle."..v.name))))
            ModSettingRemove("unshackle."..v.name)
        end
    end
end

return api