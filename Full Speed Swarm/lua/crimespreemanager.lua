local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local fs_original_crimespreemanager_onmissionstarted = CrimeSpreeManager.on_mission_started
function CrimeSpreeManager:on_mission_started(...)
	fs_original_crimespreemanager_onmissionstarted(self, ...)

	if Network:is_server() and not self:is_active() then
		CrimeSpreeManager.modify_value = CrimeSpreeManager.dont_modify_value
	end
end

function CrimeSpreeManager:dont_modify_value(id, value)
	return value
end
