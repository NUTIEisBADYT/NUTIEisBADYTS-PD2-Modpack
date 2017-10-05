-- adapted from https://github.com/JamesWilko/GoonMod/blob/43e1d2862c71bf66c10281b68db5245cc56bd6b0/GoonMod/mutators/mutator_spawn_adjustments.lua

function GroupAIStateBesiege:_upd_group_spawning()
	if not self._spawning_groups then
		return
	end

	for k, v in pairs(self._spawning_groups) do
		local spawn_task = v
		local nr_units_spawned = 0
		local produce_data = {
			name = true,
			spawn_ai = {}
		}
		local group_ai_tweak = tweak_data.group_ai
		local spawn_points = spawn_task.spawn_group.spawn_pts
		local function _try_spawn_unit(u_type_name, spawn_entry)
			local hopeless = true
			local current_unit_type = tweak_data.levels:get_ai_group_type()
			for _, sp_data in ipairs(spawn_points) do
				local category = group_ai_tweak.unit_categories[u_type_name]
				if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() then
					hopeless = false
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective
					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)
						if not objective then
							spawned_unit:set_slot(0)
							return true
						end
						objective.grp_objective = spawn_task.group.objective
					end
					local u_data = self._police[u_key]
					self:set_enemy_assigned(objective.area, u_key)
					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}
						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end
					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)
					u_data.rank = spawn_entry.rank
					self:_add_group_member(spawn_task.group, u_key)
					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end
						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end
					nr_units_spawned = nr_units_spawned + 1
					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
					end
					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end
					return true
				end
			end
			if hopeless then
				debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)
				return true
			end
		end
		for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
			if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
				for i = spawn_info.amount, 1, -1 do
					local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)
					if success then
						spawn_info.amount = spawn_info.amount - 1
					end
				end
			end
		end
		for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)
				if success then
					spawn_info.amount = spawn_info.amount - 1
				end
			end
		end
		local complete = true
		for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
			if 0 < spawn_info.amount then
				complete = false
			else
			end
		end
		if complete then
			spawn_task.group.has_spawned = true
			table.remove(self._spawning_groups, k)
			if 0 >= spawn_task.group.size then
				self._groups[spawn_task.group.id] = nil
			end
		end
	end
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault
	if not task_data.active then
		return
	end

	local t = self._t
	self:_assign_recon_groups_to_retire()
	local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)
	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			self._assault_number = self._assault_number + 1
			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			self:_set_rescue_state(false)
			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil
			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)
			if task_data.is_hesitating and self._t > task_data.voice_delay then
				if 0 < self._hostage_headcount then
					local best_group
					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end
					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t or self._drama_data.zone == "high" then
			task_data.phase = "sustain"
			task_data.phase_end_t = t + math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)
		end
	elseif task_data.phase == "sustain" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif t > task_data.phase_end_t and not self._hunt_mode then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")
		if not self._hunt_mode then
			local min_enemies_left = 7
			if enemies_left < min_enemies_left or t > task_data.phase_end_t + 350000 then
				if t > task_data.phase_end_t - 8 and not task_data.said_retreat then
					if self._drama_data.amount < tweak_data.drama.assault_fade_end then
						task_data.said_retreat = true
						self:_police_announce_retreat()
					end
				elseif t > task_data.phase_end_t and self._drama_data.amount < tweak_data.drama.assault_fade_end and self:_count_criminals_engaged_force(4) <= 3 then
					end_assault = true
				end
			end
			if task_data.force_end or end_assault then
				print("assault task clear")
				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end
				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()
				return
			end
		end
	end
	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)
			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end
	local primary_target_area = task_data.target_areas[1]
	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)
				if not nearest_dis or nearest_dis > dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end
		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end
	local nr_wanted = task_data.force - self:_count_police_force("assault")
	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end
	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event
		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false
			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end
		if used_event or next(self._spawning_groups) then
		else
			local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)
			if spawn_group then
				local grp_objective = {
					type = "assault_area",
					area = spawn_group.area,
					coarse_path = {
						{
							spawn_group.area.pos_nav_seg,
							spawn_group.area.pos
						}
					},
					attitude = "avoid",
					pose = "crouch",
					stance = "hos"
				}
				self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
			end
		end
	end
	if task_data.phase ~= "anticipation" then
		if t > task_data.use_smoke_timer then
			task_data.use_smoke = true
		end
		if self._smoke_grenade_queued and task_data.use_smoke and not self:is_smoke_grenade_active() then
			self:detonate_smoke_grenade(self._smoke_grenade_queued[1], self._smoke_grenade_queued[1], self._smoke_grenade_queued[2], self._smoke_grenade_queued[4])
			if self._smoke_grenade_queued[3] then
				self._smoke_grenade_ignore_control = true
			end
		end
	end
	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks
	while i > 0 do
		local task_data = reenforce_tasks[i]
		local force_settings = task_data.target_area.factors.force
		local force_required = force_settings and force_settings.force
		if force_required then
			local force_occupied = 0
			for group_id, group in pairs(self._groups) do
				if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					force_occupied = force_occupied + (group.has_spawned and group.size or group.initial_size)
				end
			end
			local undershot = force_required - force_occupied
			if undershot > 0 and not self._task_data.regroup.active and self._task_data.assault.phase ~= "fade" and t > self._task_data.reenforce.next_dispatch_t and self:is_area_safe(task_data.target_area) then
				local used_event
				if task_data.use_spawn_event then
					task_data.use_spawn_event = false
					if self:_try_use_task_spawn_event(t, task_data.target_area, "reenforce") then
						used_event = true
					end
				end
				local used_group, spawning_groups
				if not used_event then
					spawning_groups = true
					local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.reenforce.groups, nil, nil, nil)
					if spawn_group then
						local grp_objective = {
							type = "reenforce_area",
							area = spawn_group.area,
							target_area = task_data.target_area,
							attitude = "avoid",
							stance = "hos",
							pose = "stand",
							scan = true
						}
						self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)
						used_group = true
					end
				end
				if used_event or used_group then
					self._task_data.reenforce.next_dispatch_t = t + self:_get_difficulty_dependent_value(self._tweak_data.reenforce.interval)
				end
			elseif undershot < 0 then
				local force_defending = 0
				for group_id, group in pairs(self._groups) do
					if group.objective.area == task_data.target_area and group.objective.type == "reenforce_area" then
						force_defending = force_defending + (group.has_spawned and group.size or group.initial_size)
					end
				end
				local overshot = force_defending - force_required
				if overshot > 0 then
					local closest_group, closest_group_size
					for group_id, group in pairs(self._groups) do
						if group.has_spawned then
							if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" and (not closest_group_size or closest_group_size < group.size) and overshot >= group.size then
								closest_group = group
								closest_group_size = group.size
							end
						end
					end
					if closest_group then
						self:_assign_group_to_retire(closest_group)
					end
				end
			end
		else
			for group_id, group in pairs(self._groups) do
				if group.has_spawned then
					if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
						self:_assign_group_to_retire(group)
					end
				end
			end
			reenforce_tasks[i] = reenforce_tasks[#reenforce_tasks]
			table.remove(reenforce_tasks)
		end
		i = i - 1
	end
	self:_assign_enemy_groups_to_reenforce()
end
