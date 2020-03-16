--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

NEXUS:HookDataStream("MapScene", function(data)
	MOUNT.mapScene = data;
end);