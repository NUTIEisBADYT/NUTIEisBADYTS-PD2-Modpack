local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.FullSpeedSwarm = _G.FullSpeedSwarm or {}
FullSpeedSwarm._path = ModPath
FullSpeedSwarm._data_path = SavePath .. 'full_speed_swarm.txt'
FullSpeedSwarm.in_arrest_logic = {}
FullSpeedSwarm.units_per_navseg = {}
FullSpeedSwarm.call_on_loud = {}
FullSpeedSwarm.call_on_fastpaced = {}
FullSpeedSwarm.announcement = ''
FullSpeedSwarm.settings = {
	max_tasks = 50,
	character_positioning_quality = 3,
	lod_updater = 1,
	optimized_inputs = true,
	fastpaced = false,
	assault_behavior = 2,
	walking_quality = 1,
	slower_but_safer = false, -- to be enabled in mods/saves/full_speed_swarm.txt
}

function FullSpeedSwarm:UpdateAnnouncement()
	local must_announce
	local options = {}

	if self.settings.fastpaced then
		table.insert(options, 'fast-paced')
		must_announce = true
	end

	if self.settings.instant_identify then
		table.insert(options, 'nervous')
		must_announce = true
	end

	if self.settings.assault_behavior == 2 then
		table.insert(options, 'mixed assaults')
		must_announce = true
	elseif self.settings.assault_behavior == 3 then
		table.insert(options, 'aggressive assaults')
		must_announce = true
	end

	local new_announcement = 'Full Speed Swarm (' .. table.concat(options, ', ') .. ')'
	if self.announcement == new_announcement then
		return
	end

	Announcer:RemoveHostMod(self.announcement)
	self.announcement = new_announcement
	if must_announce then
		Announcer:AddHostMod(new_announcement)
	end
end

function FullSpeedSwarm:UpdateWalkingQuality()
	CopBase.fs_lod_stage = CopBase['fs_lod_stage_' .. self.settings.walking_quality]
end

function FullSpeedSwarm:Load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

function FullSpeedSwarm:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

FullSpeedSwarm:Load()

if core then
	core:module('CoreCode')
end

if _G.FullSpeedSwarm.settings.slower_but_safer then
	function alive(obj)
		local tp = type(obj)
		if tp == 'userdata' or tp == 'table' and type(obj.alive) == 'function' then
			return obj:alive()
		end
		return false
	end
else
	function alive(obj)
		return obj and obj:alive()
	end
end
