
-- Cache ModPath since it would have changed by the time the LocalizationManagerPostInit hook below gets called
if CreateEmptyLobby_ModPath == nil then
	CreateEmptyLobby_ModPath = ModPath
end

-- Taken from Lobby Player Info (thanks for making such an awesome mod, TdlQ!)
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_CreateEmptyLobby", function(loc)
	for __, filename in pairs(file.GetFiles(CreateEmptyLobby_ModPath .. "localizations/")) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file(CreateEmptyLobby_ModPath .. "localizations/" .. filename)
			break
		end
	end

	loc:load_localization_file(CreateEmptyLobby_ModPath .. "localizations/english.txt", false)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "BuildCreateEmptyLobbyMenu", function(menu_manager, nodes)
	local mainmenu = nodes.main
	if mainmenu == nil then
		-- Not actually a critical error since this occurs when hosting / joining a game session
--		log("[CreateEmptyLobby] Fatal Error: Failed to locate main menu, aborting")
		return
	end
	if mainmenu._items == nil then
		log("[CreateEmptyLobby] Fatal Error: Main menu node is empty, aborting")
		return
	end

	-- From Menu:AddButton() (mods/base/req/menus.lua)
	local data = {
		type = "CoreMenuItem.Item",
	}
	local params = {
		name = "create_empty_lobby_btn",
		text_id = "create_empty_lobby_title",
		help_id = "create_empty_lobby_desc",
		callback = "create_empty_lobby"
	}
	local new_item = mainmenu:create_item(data, params)
--	mainmenu:add_item(new_item)
	-- From MenuNode:add_item() (core/lib/managers/menu/coremenunode)
	new_item.dirty_callback = callback(mainmenu, mainmenu, "item_dirty")
	if mainmenu.callback_handler then
		new_item:set_callback_handler(mainmenu.callback_handler)
	end

	-- Determine where the item should be inserted
	local position = 2
	for index, item in pairs(mainmenu._items) do
		if item:name() == "crimenet_offline" then
			position = index
			break
		end
	end
	table.insert(mainmenu._items, position, new_item)
--	mainmenu:set_default_item_name("create_empty_lobby_btn")
end)

function MenuCallbackHandler:create_empty_lobby()
	-- Default the lobby to friends-only to prevent random people from hogging up slots while the contract is decided
	-- upon / other settings are adjusted
	Global.game_settings.permission = "friends_only"

	-- From Setup:load_start_menu()
	managers.job:deactivate_current_job()
	managers.gage_assignment:deactivate_assignments()
	Global.load_level = false
--	Global.load_start_menu = true
--	Global.load_start_menu_lobby = false
	Global.level_data.level = nil
	Global.level_data.mission = nil
	Global.level_data.world_setting = nil
	Global.level_data.level_class_name = nil
	Global.level_data.level_id = nil

	self:create_lobby()
end
