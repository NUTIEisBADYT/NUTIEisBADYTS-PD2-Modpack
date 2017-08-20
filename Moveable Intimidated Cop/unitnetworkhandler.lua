local mic_original_unitnetworkhandler_syncinteracted = UnitNetworkHandler.sync_interacted
function UnitNetworkHandler:sync_interacted(unit, unit_id, tweak_setting, status, sender)
	if mic_is_enabled and unit_id ~= -2 and (tweak_setting == "hostage_move" or tweak_setting == "hostage_convert") then
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
			return
		end
		if not self._verify_sender(sender) then
			return
		end

		if unit and alive(unit) and unit:interaction():active() then
			if unit:interaction().tweak_data ~= tweak_setting then
				unit:interaction():set_tweak_data(tweak_setting)
			end
		end
	end

	mic_original_unitnetworkhandler_syncinteracted(self, unit, unit_id, tweak_setting, status, sender)
end

local mic_original_unitnetworkhandler_interactionsetactive = UnitNetworkHandler.interaction_set_active
function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	if active and alive(unit) and tweak_setting == "hostage_convert" then
		-- to handle cases where the stopper is not the mover
		unit:base().mic_is_being_moved = nil
	end

	mic_original_unitnetworkhandler_interactionsetactive(self, unit, u_id, active, tweak_data, flash, sender)
end

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_MIC", function(sender, messageType, data)
	if messageType == "MIC?" then
		LuaNetworking:SendToPeer(sender, "MIC!", "")
	end

	if messageType == "MIC!" then
		mic_is_enabled = sender == 1
	end
end)

Hooks:Add("BaseNetworkSessionOnLoadComplete", "BaseNetworkSessionOnLoadComplete_MIC", function(local_peer, id)
	mic_is_enabled = Network:is_server()
	if not mic_is_enabled then
		LuaNetworking:SendToPeer(1, "MIC?", "")
	end
end)

Announcer:AddHostMod("Moveable Intimidated Cop (move dominated cops like hostages)")
