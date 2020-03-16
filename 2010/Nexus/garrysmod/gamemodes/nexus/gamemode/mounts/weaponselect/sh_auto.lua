--[[
Name: "sh_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

if (CLIENT) then
	MOUNT.displaySlot = 0;
	MOUNT.displayFade = 0;
	MOUNT.displayAlpha = 0;
	MOUNT.displayDelay = 0;
	MOUNT.weaponPrintNames = {};
end;

NEXUS:IncludePrefixed("cl_hooks.lua");