package.path = package.path .. ";./mods/evaisa.unshackle/lib/?.lua"
package.path = package.path .. ";./mods/evaisa.unshackle/lib/?/init.lua"
package.cpath = package.cpath .. ";./mods/evaisa.unshackle/bin/?.dll"
package.cpath = package.cpath .. ";./mods/evaisa.unshackle/bin/?.exe"

VERSION_UNSHACKLE = "2.6.4"

require 'lua-utf8'

lfs = require("lfs")
bitser = require("bitser")


dofile("data/scripts/lib/coroutines.lua")

try = dofile("mods/evaisa.unshackle/lib/try_catch.lua")

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

steam = nil

function GetModFilePath(mod_id, steam_id)
	local file_path = nil

	if(steam == nil or not steam_id or steam_id == "" or steam_id == "0")then
		file_path = "mods/" .. mod_id
	else
		local subscribed_items = steam.UGC.getSubscribedItems()
		local item_infos = {}

		for _, v in ipairs(subscribed_items) do
			if(tonumber(tostring(v)) ~= nil)then
				--print("Checking item: " .. tostring(v))
				local success, size, folder, timestamp = steam.UGC.getItemInstallInfo(v)
				if (success) then
					item_infos[tostring(v)] = {size = size, folder = folder, timestamp = timestamp}
				end
			end
		end

		if(item_infos[steam_id])then
			file_path = item_infos[steam_id].folder
		end
	end

	return file_path
end

try(function()
	steam = require("luasteam")
end)

table.insert(package.loaders, 2, load)

dofile("mods/evaisa.unshackle/lib/ffi_extensions.lua")

function doesScriptExist(path)
    --local file = ModTextFileGetContent(path)
    -- pcall to hide the error
    if(ModDoesFileExist)then
        return ModDoesFileExist(path)
    end
    local file, err = pcall(ModTextFileGetContent, path)
    return file ~= "" and file ~= nil
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
    if(doesScriptExist("mods/"..mod_id.."/unshackle.lua"))then
        dofile("mods/"..mod_id.."/unshackle.lua")
        print("Unshackle Mod Loaded: "..mod_id)
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
            print("Unshackle Version: "..VERSION_UNSHACKLE.." Loaded!")
        elseif(callback == "OnWorldPreUpdate")then
            wake_up_waiting_threads(1)
		elseif(callback == "OnPlayerSpawned")then
			input = dofile("mods/evaisa.unshackle/lib/input.lua")
		elseif(callback == "OnMagicNumbersAndWorldSeedInitialized")then
			if(steam)then
				steam.init()
			end
        end
        for mod_id, mod_callbacks in pairs(collected_mod_init_data)do
            if mod_callbacks[callback] then
                mod_callbacks[callback](...)
            end
        end
    end
end

