--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

NEXUS:HookDataStream("EnteredArea", function(player, data)
	if ( data[1] and data[2] and data[3] ) then
		hook.Call( "PlayerEnteredArea", NEXUS, player, data[1], data[2], data[3] );
	end;
end);

-- A function to load the area names.
function MOUNT:LoadAreaDisplays()
	self.areaDisplays = NEXUS:RestoreSchemaData( "mounts/areas/"..game.GetMap() );
end;

-- A function to save the area names.
function MOUNT:SaveAreaDisplays()
	NEXUS:SaveSchemaData("mounts/areas/"..game.GetMap(), self.areaDisplays);
end;