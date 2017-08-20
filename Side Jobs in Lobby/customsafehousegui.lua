local sjil_original_customsafehousegui_setup = CustomSafehouseGui.init
function CustomSafehouseGui:init(...)
	local active_menu = managers.menu:active_menu()
	local name = active_menu and active_menu.logic:selected_node_name()
	if name and (name == "main" or name == "lobby") then
		managers.menu_component._custom_safehouse_page = 3
	else
		managers.menu_component._custom_safehouse_page = nil
	end

	sjil_original_customsafehousegui_setup(self, ...)
end

function CustomSafehouseGui:set_active_page(new_index, play_sound)
	if not self._active_page then
	elseif self._tabs_data[new_index].name_id == "menu_cs_daily_challenge" then
		managers.menu:set_and_send_sync_state("payday")
	else
		managers.menu:set_and_send_sync_state("custom_safehouse")
	end

	CustomSafehouseGui.super.set_active_page(self, new_index, play_sound)
end
