_G.LobbyPlayerInfo = _G.LobbyPlayerInfo or {}
LobbyPlayerInfo._path = ModPath
LobbyPlayerInfo._data_path = SavePath .. 'lobby_player_info.txt'
LobbyPlayerInfo._font_sizes = {
	tweak_data.menu.pd2_small_font_size - 6,
	tweak_data.menu.pd2_small_font_size - 4,
	tweak_data.menu.pd2_small_font_size - 2,
	tweak_data.menu.pd2_small_font_size - 0,
}
LobbyPlayerInfo.settings = {}
LobbyPlayerInfo.play_times = {}
LobbyPlayerInfo.pd2stats_player_status = {}
LobbyPlayerInfo.skills_layouts = {
	'%s:%02u  %s:%02u  %s:%02u  %s:%02u  %s:%02u',
	'%s.: %s\n%s.: %s\n%s.: %s\n%s.: %s\n%s.: %s',
	'',
	'%s:%02u %02u %02u  %s:%02u %02u %02u  %s:%02u %02u %02u  %s:%02u %02u %02u  %s:%02u %02u %02u' -- for hudstatsscreen
}
LobbyPlayerInfo._abbreviation_length_v = 3

function LobbyPlayerInfo:ResetToDefaultValues()
	self.settings = {
		team_skillpoints_thresholds = {
			silver = 25,
			gold = 40,
			overspecialized = 80
		},
		show_perkdeck_mode = 3,
		show_perkdeck_progression = true,
		hide_complete_perkdeck_progression = true,
		show_perkdeck_progression_graphically = true,
		show_perkdeck_in_loadout = true,
		show_skills_mode = 2,
		skills_layout = 2,
		skills_font_size = 3,
		skills_details = 2,
		show_play_time_mode = 1,
		play_time_font_size = 1,
		team_skills_mode = 4,
		keep_pre68_character_name_position = false,
		show_skills_in_stats_screen = true
	}
end

function LobbyPlayerInfo:GetFontSizeForSkills()
	return self._font_sizes[self.settings.skills_font_size or 2]
end

function LobbyPlayerInfo:GetFontSizeForPlayTime()
	return self._font_sizes[self.settings.play_time_font_size or 1]
end

function LobbyPlayerInfo:GetSkillsFormat()
	return self.skills_layouts[self.settings.skills_layout]
end

function LobbyPlayerInfo:GetSkillNameLength()
	if self.settings.skills_layout == 1 then
		return 1
	else
		return self._abbreviation_length_v
	end
end

function LobbyPlayerInfo:GetSkillPointsPerTree(skills)
	local result = {}
	for i = 0, 4 do
		result[i+1] = skills[i * 3 + 1] + skills[i * 3 + 2] + skills[i * 3 + 3]
	end
	return result
end

function LobbyPlayerInfo:Load()
	self:ResetToDefaultValues()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

function LobbyPlayerInfo:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_LobbyPlayerInfo', function(loc)
	if _G.PD2KR then
		LobbyPlayerInfo._abbreviation_length_v = 2
		loc:load_localization_file(LobbyPlayerInfo._path .. 'loc/korean.txt')
	else
		for _, filename in pairs(file.GetFiles(LobbyPlayerInfo._path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(LobbyPlayerInfo._path .. 'loc/' .. filename)
				break
			end
		end
	end

	loc:load_localization_file(LobbyPlayerInfo._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_LobbyPlayerInfo', function(menu_manager)

	MenuCallbackHandler.LobbyPlayerInfoShowPerkDeckMode = function(this, item)
		LobbyPlayerInfo.settings.show_perkdeck_mode = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoShowPerkDeckProgression = function(this, item)
		LobbyPlayerInfo.settings.show_perkdeck_progression = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoHideCompletePerkDeckProgression = function(this, item)
		LobbyPlayerInfo.settings.hide_complete_perkdeck_progression = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoShowPerkdeckProgressionGraphically = function(this, item)
		LobbyPlayerInfo.settings.show_perkdeck_progression_graphically = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoShowPerkDeckInLoadout = function(this, item)
		LobbyPlayerInfo.settings.show_perkdeck_in_loadout = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoTeamSkillsMode = function(this, item)
		LobbyPlayerInfo.settings.team_skills_mode = item:value()
		if managers.menu_component._contract_gui then
			LPITeamBox:Update()
		end
	end

	MenuCallbackHandler.LobbyPlayerInfoShowSkillsMode = function(this, item)
		LobbyPlayerInfo.settings.show_skills_mode = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoSetLayout = function(self, item)
		LobbyPlayerInfo.settings.skills_layout = item:value()
		local contract_gui = managers.menu_component._contract_gui
		if contract_gui then
			if contract_gui._peers_skills then
				for _, obj in pairs(contract_gui._peers_skills) do
					obj:parent():remove(obj)
				end
				contract_gui._peers_skills = {}
			else
				for peer_id, chardata in pairs(contract_gui._peer_panels) do
					if chardata._peer_skills then
						chardata._peer_skills:parent():remove(chardata._peer_skills)
						chardata._peer_skills = LobbyPlayerInfo:CreatePeerSkills(chardata._panel)
					end
				end
			end
		end
	end

	MenuCallbackHandler.LobbyPlayerInfoSetFontSizeForSkills = function(self, item)
		LobbyPlayerInfo.settings.skills_font_size = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoSetDetailsForSkills = function(self, item)
		LobbyPlayerInfo.settings.skills_details = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoShowPlayTime = function(this, item)
		LobbyPlayerInfo.settings.show_play_time_mode = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoSetFontSizeForPlayTime = function(self, item)
		LobbyPlayerInfo.settings.play_time_font_size = item:value()
	end

	MenuCallbackHandler.LobbyPlayerInfoKeepPre68CharacterNamePosition = function(self, item)
		LobbyPlayerInfo.settings.keep_pre68_character_name_position = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoShowSkillsInStatsScreen = function(self, item)
		LobbyPlayerInfo.settings.show_skills_in_stats_screen = item:value() == 'on' and true or false
	end

	MenuCallbackHandler.LobbyPlayerInfoResetToDefaultValues = function(this, item)
		LobbyPlayerInfo:ResetToDefaultValues()
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_show_perkdeck_mode'] = true}, LobbyPlayerInfo.settings.show_perkdeck_mode)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_show_perkdeck_progression'] = true}, LobbyPlayerInfo.settings.show_perkdeck_progression)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_hide_complete_perkdeck_progression'] = true}, LobbyPlayerInfo.settings.hide_complete_perkdeck_progression)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_show_perkdeck_progression_graphically'] = true}, LobbyPlayerInfo.settings.show_perkdeck_progression_graphically)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_show_perkdeck_in_loadout'] = true}, LobbyPlayerInfo.settings.show_perkdeck_in_loadout)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_team_skills_mode'] = true}, LobbyPlayerInfo.settings.team_skills_mode)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_show_skills_mode'] = true}, LobbyPlayerInfo.settings.show_skills_mode)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_skills_layout'] = true}, LobbyPlayerInfo.settings.skills_layout)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_skills_font_size'] = true}, LobbyPlayerInfo.settings.skills_font_size)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_skills_details'] = true}, LobbyPlayerInfo.settings.skills_details)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_show_play_time'] = true}, LobbyPlayerInfo.settings.show_play_time_mode)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_multi_play_time_font_size'] = true}, LobbyPlayerInfo.settings.play_time_font_size)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_keep_pre68_character_name_position'] = true}, LobbyPlayerInfo.settings.keep_pre68_character_name_position)
		MenuHelper:ResetItemsToDefaultValue(item, {['lpi_toggle_show_skills_in_stats_screen'] = true}, LobbyPlayerInfo.settings.show_skills_in_stats_screen)
	end

	MenuCallbackHandler.LobbyPlayerInfoSave = function(this, item)
		LobbyPlayerInfo:Save()
	end

	LobbyPlayerInfo:Load()

	MenuHelper:LoadFromJsonFile(LobbyPlayerInfo._path .. 'menu/options.txt', LobbyPlayerInfo, LobbyPlayerInfo.settings)

end)

local lpi_original_menumanager_pushtotalk = MenuManager.push_to_talk
function MenuManager:push_to_talk(enabled)
	lpi_original_menumanager_pushtotalk(self, enabled)
	if managers.network and managers.network.voice_chat and managers.network.voice_chat._enabled and managers.network:session() then
		managers.network.voice_chat._users_talking[managers.network:session():local_peer():id()] = { active = enabled }
	end
end
