--[[
Name: "sh_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

nexus.player.RegisterSharedVar("sh_Typing", NWTYPE_NUMBER);
nexus.config.ShareKey("typing_visible_only");

NEXUS:IncludePrefixed("sh_enums.lua");
NEXUS:IncludePrefixed("cl_hooks.lua");