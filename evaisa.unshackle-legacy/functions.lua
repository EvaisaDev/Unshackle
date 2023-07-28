local json = dofile("mods/evaisa.unshackle/lib/json.lua")

local custom_api = {}

local api = {}

function RegisterFunction(name, func)
    table.insert(custom_api, {name = name, func = func})
    api[name] = function(...)
        local arg={...}
        local saved = json.stringify(arg);
        ModSettingSet("unshackle."..name, saved)
    end
end

function Update()
    for i, v in ipairs(custom_api)do
        if(ModSettingGet("unshackle."..v.name) ~= nil)then
            --local pretty = dofile("mods/evaisa.modmanager/lib/pretty.lua")
            local data = json.parse(ModSettingGet("unshackle."..v.name))
            
            v.func(unpack(data))
            ModSettingRemove("unshackle."..v.name)
        end
    end
end

return api