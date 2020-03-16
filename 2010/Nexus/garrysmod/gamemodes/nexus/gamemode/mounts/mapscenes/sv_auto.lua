--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to load the map scenes.
function MOUNT:LoadMapScenes()
	self.mapScenes = {};
	
	local mapScenes = NEXUS:RestoreSchemaData( "mounts/scenes/"..game.GetMap() );
	
	for k, v in pairs(mapScenes) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		self.mapScenes[#self.mapScenes + 1] = data;
	end;
end;

MOUNT:LoadMapScenes();

-- A function to save the map scenes.
function MOUNT:SaveMapScenes()
	local mapScenes = {};
	
	for k, v in pairs(self.mapScenes) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		mapScenes[#mapScenes + 1] = data;
	end;
	
	NEXUS:SaveSchemaData("mounts/scenes/"..game.GetMap(), mapScenes);
end;