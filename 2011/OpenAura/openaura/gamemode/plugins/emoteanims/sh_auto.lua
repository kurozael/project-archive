--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

PLUGIN.stances = {
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

openAura.player:RegisterSharedVar("stancePosition", NWTYPE_VECTOR);
openAura.player:RegisterSharedVar("stanceAngles", NWTYPE_ANGLE);
openAura.player:RegisterSharedVar("stanceIdle", NWTYPE_BOOL, true);

openAura:IncludePrefixed("sh_coms.lua");
openAura:IncludePrefixed("cl_hooks.lua");
openAura:IncludePrefixed("sv_hooks.lua");

-- A function to get whether a player is in a stance.
function PLUGIN:IsPlayerInStance(player)
	return player:GetSharedVar("stancePosition") != Vector(0, 0, 0);
end;

-- Called when a player starts to move.
function PLUGIN:Move(player, moveData)
	if ( self:IsPlayerInStance(player) ) then
		player:SetAngles( player:GetSharedVar("stanceAngles") );
		
		return true;
	end;
end;