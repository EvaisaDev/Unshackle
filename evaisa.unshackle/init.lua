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

local collected_mod_init_data = {}

local noita_callbacks = {
    "OnModPreInit",
    "OnModInit",
    "OnModPostInit",
    "OnPlayerSpawned",
    "OnPlayerDied",
    "OnWorldInitialized",
    "OnWorldPreUpdate",
    "OnWorldPostUpdate",
    "OnBiomeConfigLoaded",
    "OnMagicNumbersAndWorldSeedInitialized",
    "OnPausedChanged",
    "OnModSettingsChanged",
    "OnPausePreUpdate",
}

local remove_callbacks_from_global = function()
    for _, callback in ipairs(noita_callbacks)do
        _G[callback] = nil
    end
end

local active_mods = ModGetActiveModIDs()

for i, mod_id in ipairs(active_mods)do
    if(isFile("mods/"..mod_id.."/unshackle.lua"))then
        dofile("mods/"..mod_id.."/unshackle.lua")
        for _, callback in ipairs(noita_callbacks)do
            if _G[callback] then
                if not collected_mod_init_data[mod_id] then
                    collected_mod_init_data[mod_id] = {}
                end
                collected_mod_init_data[mod_id][callback] = _G[callback]
            end
        end

        remove_callbacks_from_global()
    end
end

for i, callback in ipairs(noita_callbacks)do
    _G[callback] = function(...)
        if(callback == "OnWorldInitialized")then
            GameAddFlagRun( "unshackle2_loaded" )
            print("Unshackle2 loaded")
        end
        for mod_id, mod_callbacks in pairs(collected_mod_init_data)do
            if mod_callbacks[callback] then
                mod_callbacks[callback](...)
            end
        end
    end
end