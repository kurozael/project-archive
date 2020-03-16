--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

NEXUS:HookDataStream("SurfaceTexts", function(data)
	MOUNT.surfaceTexts = data;
end);

NEXUS:HookDataStream("SurfaceTextAdd", function(data)
	MOUNT.surfaceTexts[#MOUNT.surfaceTexts + 1] = data;
end);

NEXUS:HookDataStream("SurfaceTextRemove", function(data)
	for k, v in pairs(MOUNT.surfaceTexts) do
		if (v.position == data) then
			MOUNT.surfaceTexts[k] = nil;
		end;
	end;
end);