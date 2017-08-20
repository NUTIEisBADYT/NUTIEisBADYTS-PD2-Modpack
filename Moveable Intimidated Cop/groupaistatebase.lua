local mic_original_groupaistatebase_onenemyunregistered = GroupAIStateBase.on_enemy_unregistered
function GroupAIStateBase:on_enemy_unregistered(unit)
	local interacting_unit = unit:base().mic_is_being_moved
	if interacting_unit and alive(interacting_unit) then
		self:on_hostage_follow(interacting_unit, unit, false)
	end

	mic_original_groupaistatebase_onenemyunregistered(self, unit)
end

local mic_original_groupaistatebase_onobjectivefailed = GroupAIStateBase.on_objective_failed
function GroupAIStateBase:on_objective_failed(unit, objective, no_new_objective)
	local owner = unit:base().mic_is_being_moved
	if owner and alive(owner) then
		unit:brain():on_hostage_move_interaction(owner, "fail")
		return
	end

	mic_original_groupaistatebase_onobjectivefailed(self, unit, objective, no_new_objective)
end

if not FullSpeedSwarm then
	local mic_original_groupaistatebase_onhostagestate = GroupAIStateBase.on_hostage_state
	function GroupAIStateBase:on_hostage_state(state, key, ...)
		mic_original_groupaistatebase_onhostagestate(self, state, key, ...)

		local attention_data = self._attention_objects.all[key]
		local unit = attention_data and attention_data.unit
		if alive(unit) then
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", unit, "brain", state and 3 or 4)
		end
	end
end
