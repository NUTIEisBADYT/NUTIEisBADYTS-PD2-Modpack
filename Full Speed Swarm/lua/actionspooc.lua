local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local fs_original_actionspooc_init = ActionSpooc.init
function ActionSpooc:init(action_desc, common_data)
	local result = fs_original_actionspooc_init(self, action_desc, common_data)
	self._move_speed = CopActionWalk._move_speeds[common_data.ext_base._tweak_table][self._stance.name][self._haste]
	return result
end

ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed
