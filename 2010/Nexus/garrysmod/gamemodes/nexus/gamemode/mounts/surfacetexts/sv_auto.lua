--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to load the surface texts.
function MOUNT:LoadSurfaceTexts()
	self.surfaceTexts = NEXUS:RestoreSchemaData( "mounts/texts/"..game.GetMap() );
end;

-- A function to save the surface texts.
function MOUNT:SaveSurfaceTexts()
	NEXUS:SaveSchemaData("mounts/texts/"..game.GetMap(), self.surfaceTexts);
end;