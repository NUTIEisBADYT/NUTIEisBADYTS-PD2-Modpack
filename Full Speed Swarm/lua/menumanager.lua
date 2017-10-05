local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_FullSpeedSwarm', function(loc)
	for _, filename in pairs(file.GetFiles(FullSpeedSwarm._path .. 'loc/')) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(FullSpeedSwarm._path .. 'loc/' .. filename)
			break
		end
	end

	loc:load_localization_file(FullSpeedSwarm._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_FullSpeedSwarm', function(menu_manager)

	MenuCallbackHandler.FullSpeedSwarmSetMaxTasks = function(self, item)
		FullSpeedSwarm.settings.max_tasks = math.floor(item:value())
		if type(FullSpeedSwarmUpdateMaxTasks) == 'function' then
			FullSpeedSwarmUpdateMaxTasks(FullSpeedSwarm.settings.max_tasks)
		end
	end

	MenuCallbackHandler.FullSpeedSwarmSetCharPosQuality = function(self, item)
		FullSpeedSwarm.settings.character_positioning_quality = item:value()
	end

	MenuCallbackHandler.FullSpeedSwarmSetWalkingQuality = function(self, item)
		FullSpeedSwarm.settings.walking_quality = item:value()
	end

	MenuCallbackHandler.FullSpeedSwarmSetLODUpdater = function(self, item)
		FullSpeedSwarm.settings.lod_updater = item:value()
	end

	MenuCallbackHandler.FullSpeedSwarmSetOptimizedInputs = function(self, item)
		FullSpeedSwarm.settings.optimized_inputs = item:value() == 'on'
	end

	MenuCallbackHandler.FullSpeedSwarmSetFastPaced = function(self, item)
		FullSpeedSwarm.settings.fastpaced = item:value() == 'on'
		for _, fct in pairs(FullSpeedSwarm.call_on_fastpaced) do
			fct()
		end
		FullSpeedSwarm:UpdateAnnouncement()
	end

	MenuCallbackHandler.FullSpeedSwarmSetInstantIdentify = function(self, item)
		FullSpeedSwarm.settings.instant_identify = item:value() == 'on'
		FullSpeedSwarm:UpdateAnnouncement()
	end

	MenuCallbackHandler.FullSpeedSwarmSetAssaultBehavior = function(self, item)
		FullSpeedSwarm.settings.assault_behavior = item:value()
		FullSpeedSwarm:UpdateAnnouncement()
	end

	MenuCallbackHandler.FullSpeedSwarmSave = function(this, item)
		FullSpeedSwarm:Save()
	end

	MenuHelper:LoadFromJsonFile(FullSpeedSwarm._path .. 'menu/options.txt', FullSpeedSwarm, FullSpeedSwarm.settings)

end)

local fs_original_menucallbackhandler_updateoutfitinformation = MenuCallbackHandler._update_outfit_information
function MenuCallbackHandler:_update_outfit_information()
	fs_original_menucallbackhandler_updateoutfitinformation(self)
	managers.player:fs_refresh_body_armor_skill_multiplier()
	managers.player:fs_reset_max_health()
end

FullSpeedSwarm:UpdateAnnouncement()

dofile(ModPath .. 'lua/blt_keybinds_manager.lua')
