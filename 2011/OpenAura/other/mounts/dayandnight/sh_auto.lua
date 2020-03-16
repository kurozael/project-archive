--[[
Name: "sh_auto.lua".
Product: "blueprint".
--]]

local PLUGIN = PLUGIN;

PLUGIN.name = "Day and Night";
PLUGIN.author = "Foszor, Catdaemon and kuropixel";

BLUEPRINT:IncludePrefixed("sh_enums.lua");
BLUEPRINT:IncludePrefixed("sv_hooks.lua");

BLUEPRINT:RegisterGlobalSharedVar("sh_SkyColor", NWTYPE_VECTOR);
BLUEPRINT:RegisterGlobalSharedVar("sh_SkyName", NWTYPE_STRING);