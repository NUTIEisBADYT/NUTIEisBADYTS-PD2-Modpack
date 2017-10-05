local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local cops_to_intimidate = {}
FullSpeedSwarm.cops_to_intimidate = cops_to_intimidate

local fs_original_copdamage_damagemelee = CopDamage.damage_melee
function CopDamage:damage_melee(attack_data, ...)
	if attack_data.variant == "taser_tased" then
		cops_to_intimidate[self._unit:key()] = TimerManager:game():time()
	end
	return fs_original_copdamage_damagemelee(self, attack_data, ...)
end

local fs_original_copdamage_syncdamagemelee = CopDamage.sync_damage_melee
function CopDamage:sync_damage_melee(variant, ...)
	if variant == 5 then
		cops_to_intimidate[self._unit:key()] = TimerManager:game():time()
	end
	return fs_original_copdamage_syncdamagemelee(self, variant, ...)
end
