dofile(FullSpeedSwarm._path .. "mutators/mutatorbigparty.lua")

local fs_original_mutatorsmanager_init = MutatorsManager.init
function MutatorsManager:init()
	fs_original_mutatorsmanager_init(self)

	table.insert(self._mutators, MutatorBigParty:new(self))

	local id = MutatorBigParty._type
	local data = Global.mutators.active_on_load[id]
	if data then
		local mutator = self:get_mutator_from_id(id)
		table.insert(self:active_mutators(), {mutator = mutator})

		for key, value in pairs(data) do
			if Network:is_client() then
				mutator:set_host_value(key, value)
			end
		end

		mutator:setup(self)
	end
end
