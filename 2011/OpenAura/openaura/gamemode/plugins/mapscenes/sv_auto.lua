--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the map scenes.
function PLUGIN:LoadMapScenes()
	self.mapScenes = {};
	
	local mapScenes = openAura:RestoreSchemaData( "plugins/scenes/"..game.GetMap() );
	
	for k, v in pairs(mapScenes) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		self.mapScenes[#self.mapScenes + 1] = data;
	end;
end;

-- A function to save the map scenes.
function PLUGIN:SaveMapScenes()
	local mapScenes = {};
	
	for k, v in pairs(self.mapScenes) do
		local data = {
			position = v.position,
			angles = v.angles
		};
		
		mapScenes[#mapScenes + 1] = data;
	end;
	
	openAura:SaveSchemaData("plugins/scenes/"..game.GetMap(), mapScenes);
end;