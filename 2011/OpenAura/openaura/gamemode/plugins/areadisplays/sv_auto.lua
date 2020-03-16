--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura:HookDataStream("EnteredArea", function(player, data)
	if ( data[1] and data[2] and data[3] ) then
		hook.Call( "PlayerEnteredArea", openAura, player, data[1], data[2], data[3] );
	end;
end);

-- A function to load the area names.
function PLUGIN:LoadAreaDisplays()
	self.areaDisplays = openAura:RestoreSchemaData( "plugins/areas/"..game.GetMap() );
end;

-- A function to save the area names.
function PLUGIN:SaveAreaDisplays()
	openAura:SaveSchemaData("plugins/areas/"..game.GetMap(), self.areaDisplays);
end;