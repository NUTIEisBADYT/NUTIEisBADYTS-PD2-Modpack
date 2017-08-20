if Network:is_server() then
	_G.KeepItClean = _G.KeepItClean or {}
	KeepItClean.civilians_killed = {}
	Announcer:AddHostMod("Keep it clean! (cops will focus more the killers of civilians)")
end
