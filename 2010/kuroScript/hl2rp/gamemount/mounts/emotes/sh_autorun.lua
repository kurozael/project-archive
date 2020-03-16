--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Emotes";
MOUNT.author = "kuromeku";
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
	["plazaidle4"] = true,
	["plazaidle2"] = true,
	["plazaidle1"] = true,
	["spreadwall"] = true,
	["idle_baton"] = true,
	["lean_back"] = true
};

-- Register a player networked table.
RegisterNWTablePlayer( {
	{"ks_Stance", false, NWTYPE_BOOL, REPL_PLAYERONLY}
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");