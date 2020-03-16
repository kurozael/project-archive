--[[
Name: "sh_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

MOUNT.stances = {
	["d1_t03_tenements_look_out_window_idle"] = true,
	["d2_coast03_postbattle_idle02_entry"] = true,
	["d2_coast03_postbattle_idle01_entry"] = true,
	["d2_coast03_postbattle_idle02"] = true,
	["d2_coast03_postbattle_idle01"] = true,
	["d1_t03_lookoutwindow"] = true,
	["idle_to_sit_ground"] = true,
	["sit_ground_to_idle"] = true,
	["spreadwallidle"] = true,
	["apcarrestidle"] = true,
	["plazathreat2"] = true,
	["plazathreat1"] = true,
	["sit_ground"] = true,
	["lineidle04"] = true,
	["lineidle02"] = true,
	["lineidle01"] = true,
	["plazaidle4"] = true,
	["plazaidle2"] = true,
	["plazaidle1"] = true,
	["spreadwall"] = true,
	["wave_close"] = true,
	["idle_baton"] = true,
	["wave_smg1"] = true,
	["lean_back"] = true,
	["cheer1"] = true,
	["wave"] = true
};

nexus.player.RegisterSharedVar("sh_StancePosition", NWTYPE_VECTOR);
nexus.player.RegisterSharedVar("sh_StanceAngles", NWTYPE_ANGLE);
nexus.player.RegisterSharedVar("sh_StanceIdle", NWTYPE_BOOL, true);

NEXUS:IncludePrefixed("sh_coms.lua");
NEXUS:IncludePrefixed("cl_hooks.lua");
NEXUS:IncludePrefixed("sv_hooks.lua");

-- A function to get whether a player is in a stance.
function MOUNT:IsPlayerInStance(player)
	return player:GetSharedVar("sh_StancePosition") != Vector(0, 0, 0);
end;

-- Called when a player starts to move.
function MOUNT:Move(player, moveData)
	if ( self:IsPlayerInStance(player) ) then
		player:SetAngles( player:GetSharedVar("sh_StanceAngles") );
		
		return true;
	end;
end;