--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to load the dynamic adverts.
function MOUNT:LoadDynamicAdverts()
	self.dynamicAdverts = NEXUS:RestoreSchemaData( "mounts/adverts/"..game.GetMap() );
end;

-- A function to save the dynamic adverts.
function MOUNT:SaveDynamicAdverts()
	NEXUS:SaveSchemaData("mounts/adverts/"..game.GetMap(), self.dynamicAdverts);
end;