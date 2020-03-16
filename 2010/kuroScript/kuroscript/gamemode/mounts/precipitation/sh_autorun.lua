--[[
Name: "sh_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Set some information.
MOUNT.name = "Precipitation";
MOUNT.author = "kuromeku";

-- Register a global networked table.
RegisterNWTableGlobal( {
	{"ks_Precipitation", 0, NWTYPE_CHAR, REPL_EVERYONE}
} );

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("scheme/sh_comm.lua");
kuroScript.frame:IncludePrefixed("scheme/sh_enums.lua");
kuroScript.frame:IncludePrefixed("scheme/sv_hooks.lua");
kuroScript.frame:IncludePrefixed("scheme/cl_hooks.lua");

-- Set some information.
MOUNT.precipitation = {
	[PREC_NIGHT_TIME_RAIN] = {
		amount = 10,
		sound = "ambient/weather/rumble_rain_nowind.wav"
	},
	[PREC_DAY_TIME_RAIN] = {
		amount = 10,
		sound = "ambient/weather/rumble_rain_nowind.wav"
	},
	[PREC_MORNING_RAIN] = {
		amount = 10,
		sound = "ambient/weather/rumble_rain_nowind.wav"
	},
	[PREC_EVENING_RAIN] = {
		amount = 10,
		sound = "ambient/weather/rumble_rain_nowind.wav"
	},
	[PREC_STORM_RAIN] = {
		amount = 10,
		sound = "ambient/weather/rumble_rain.wav"
	}
};