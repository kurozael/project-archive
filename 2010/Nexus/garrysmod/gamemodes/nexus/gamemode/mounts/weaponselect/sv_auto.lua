--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

NEXUS:HookDataStream("SelectWeapon", function(player, data)
	if (type(data) == "string") then
		if ( player:HasWeapon(data) ) then
			player:SelectWeapon(data);
		end;
	end;
end);