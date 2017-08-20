if Network:is_server() then
	local fcb_original_securitycamera_init = SecurityCamera.init
	function SecurityCamera:init(...)
		self.fcb_suspicion_levels = {0, 0, 0, 0}
		self.fcb_suspicion_levels_sync = {}
		return fcb_original_securitycamera_init(self, ...)
	end

	local fcb_original_securitycamera_save = SecurityCamera.save
	function SecurityCamera:save(data)
		fcb_original_securitycamera_save(self, data)
		data.suspicion_lvl = nil
	end

	local REACT_SCARED = AIAttentionObject.REACT_SCARED
	function SecurityCamera:_upd_sound(unit, t)
		if self._alarm_sound then
			return
		end

		local new_suspicion_levels = {}
		for u_key, attention_info in pairs(self._detected_attention_objects) do
			if attention_info.reaction >= REACT_SCARED then
				if attention_info.identified then
					self:_sound_the_alarm(attention_info.unit)
					return
				end
			end

			local peer
			if attention_info.is_human_player then
				peer = managers.network:session():peer_by_unit(attention_info.unit)
			elseif attention_info.is_person then
				local brain = attention_info.unit:brain()
				if brain and brain.objective then
					local objective = brain:objective()
					if objective and objective.type == 'follow' then
						peer = managers.network:session():peer_by_unit(objective.follow_unit)
					end
				end
			elseif attention_info.is_deployable then
				local owner_id = attention_info.unit:base()._owner_id
				if owner_id then
					peer = managers.network:session():peer(owner_id)
				end
			else
				local cd = attention_info.unit:carry_data()
				if cd and cd.fcb_last_carrier_id then
					peer = managers.network:session():peer(cd.fcb_last_carrier_id)
				end
			end

			if peer then
				local peer_id = peer:id()
				local suspicion_level = new_suspicion_levels[peer_id]
				local value = attention_info.uncover_progress or attention_info.notice_progress
				if not suspicion_level or value > suspicion_level then
					new_suspicion_levels[peer_id] = value
				end
			end
		end

		for i = 1, 4 do
			local new_suspicion_level = new_suspicion_levels[i]
			if new_suspicion_level then
				self:_set_suspicion_sound(new_suspicion_level, i)
			else
				self:_stop_all_sounds(i)
			end
		end
	end

	function SecurityCamera:_set_suspicion_sound(suspicion_level, peer_id)
		if peer_id == 1 then
			if self.fcb_suspicion_levels[peer_id] == suspicion_level then
				return
			end
			if not self._suspicion_sound then
				self._suspicion_sound = self._unit:sound_source():post_event("camera_suspicious_signal")
				self.fcb_suspicion_levels[peer_id] = 0
			end
			local pitch = suspicion_level >= self.fcb_suspicion_levels[peer_id] and 1 or 0.6
			self.fcb_suspicion_levels[peer_id] = suspicion_level
			self._unit:sound_source():set_rtpc("camera_suspicion_level_pitch", pitch)
			self._unit:sound_source():set_rtpc("camera_suspicion_level", suspicion_level)

		else--if Network:is_server() then
			local suspicion_lvl_sync = math.clamp(math.ceil(suspicion_level * 6), 1, 6)
			local fcb_suspicion_level = self.fcb_suspicion_levels_sync[peer_id]
			if suspicion_lvl_sync ~= fcb_suspicion_level then
				local event_id = self._NET_EVENTS["suspicion_" .. tostring(suspicion_lvl_sync)]
				if self:_send_net_event(event_id, peer_id) then
					self.fcb_suspicion_levels_sync[peer_id] = suspicion_lvl_sync
				end
			end
		end
	end

	function SecurityCamera:_stop_all_sounds(peer_id)
		-- if Network:is_server() then
			if self._alarm_sound or peer_id and self.fcb_suspicion_levels_sync[peer_id] then
				if self:_send_net_event(self._NET_EVENTS.sound_off, peer_id) then
					self.fcb_suspicion_levels_sync[peer_id] = nil
				end
			end
		-- end
		if not peer_id or peer_id == 1 then
			if self._alarm_sound or self._suspicion_sound then
				self._alarm_sound = nil
				self._suspicion_sound = nil
				self._unit:sound_source():post_event("camera_silent")
			end
			if not peer_id then
				self.fcb_suspicion_levels = {0, 0, 0, 0}
			end
		else
			self.fcb_suspicion_levels[peer_id] = 0
		end
	end

	function SecurityCamera:_send_net_event(event_id, peer_id)
		if peer_id then
			if peer_id ~= 1 then
				local session = managers.network:session()
				local peer = session:peer(peer_id)
				if peer then
					session:send_to_peer_synched(peer, "sync_unit_event_id_16", self._unit, "base", event_id)
					return peer:synched()
				end
			end
		else
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", event_id)
		end
	end
end
