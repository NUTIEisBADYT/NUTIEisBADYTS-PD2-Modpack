Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_SideJobsInLobbyMenu", function(menu_manager, nodes)
	if nodes.custom_safehouse then
		nodes.custom_safehouse:parameters().sync_state = "payday"
	end

	if nodes.main then
		MenuHelper:AddMenuItem(nodes.main, "custom_safehouse", "menu_cn_challenge", "menu_cn_challenge_desc", "quickplay", "after")

		for _, v in pairs(nodes.main._items) do
			if v._parameters.name == "custom_safehouse" then
				v._parameters.icon = "guis/textures/pd2/icon_reward"
				v._parameters.icon_visible_callback = { "got_challenge_reward" }
				v._icon_visible_callback_name_list  = { "got_challenge_reward" }
				v:set_callback_handler(v._callback_handler)
				break
			end
		end
	end

	if nodes.lobby then
		for _, v in pairs(nodes.lobby._items) do
			if v._parameters.name == "custom_safehouse" then
				v._parameters.icon = "guis/textures/pd2/icon_reward"
				break
			end
		end
	end
end)

function MenuCallbackHandler:got_challenge_reward()
	if not managers.challenge then
		return
	end
	for key, challenge in pairs(managers.challenge._global.active_challenges) do
		if challenge.completed and not challenge.rewarded then
			return true
		end
	end
end
MenuCallbackHandler.show_custom_safehouse_menu_icon = MenuCallbackHandler.got_challenge_reward
