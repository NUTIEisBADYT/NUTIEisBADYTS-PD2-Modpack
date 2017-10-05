local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local fs_original_playerinventory_destroyallitems = PlayerInventory.destroy_all_items
function PlayerInventory:destroy_all_items()
	for _, selection_data in pairs(self._available_selections) do
		local key = '_dyn_resource_' .. selection_data.unit:name():key()
		if self[key] then
			managers.dyn_resource:unload(Idstring('unit'), selection_data.unit:name(), managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
			self[key] = nil
		end
	end

	fs_original_playerinventory_destroyallitems(self)
end
