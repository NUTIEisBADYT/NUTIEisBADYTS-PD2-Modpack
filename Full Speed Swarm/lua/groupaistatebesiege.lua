local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local full_force = true
local fs_groupaistatebesiege_spawningroup = GroupAIStateBesiege._spawn_in_group
function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)
	if grp_objective.type == "assault_area" then
		grp_objective.primary_target_area = self._task_data.assault.target_areas and self._task_data.assault.target_areas[1]
		if grp_objective.primary_target_area then
			local assault_behavior = FullSpeedSwarm.settings.assault_behavior
			if assault_behavior == 3 or assault_behavior == 2 and full_force then
				grp_objective.area = grp_objective.primary_target_area
			end
			full_force = not full_force
			grp_objective.coarse_path = nil
		end
	end
	return fs_groupaistatebesiege_spawningroup(self, spawn_group, spawn_group_type, grp_objective, ai_task)
end

local fs_groupaistatebesiege_spawningroup = GroupAIStateBesiege._create_objective_from_group_objective
function GroupAIStateBesiege._create_objective_from_group_objective(grp_objective, receiving_unit)
	local objective = fs_groupaistatebesiege_spawningroup(grp_objective, receiving_unit)
	if grp_objective.type == "assault_area" and grp_objective.primary_target_area then
		objective.area = grp_objective.primary_target_area
	end
	return objective
end

local fs_groupaistatebesiege_checkphalanxgrouphasspawned = GroupAIStateBesiege._check_phalanx_group_has_spawned
function GroupAIStateBesiege:_check_phalanx_group_has_spawned()
	if self._phalanx_spawn_group and self._phalanx_spawn_group.has_spawned then
		if not self._phalanx_spawn_group.set_to_phalanx_group_obj then
			for i, group_unit in pairs(self._phalanx_spawn_group.units) do
				if not alive(group_unit.unit) then
					if group_unit.tweak_table == 'phalanx_vip' then
						-- because sending the captain right into a killzone is always a good idea...
						managers.groupai:state():phalanx_damage_reduction_disable()
						managers.groupai:state():unregister_phalanx_vip()
						self._phalanx_spawn_group.units[i] = nil
					end
				end
			end
		end
	end
	fs_groupaistatebesiege_checkphalanxgrouphasspawned(self)
end
