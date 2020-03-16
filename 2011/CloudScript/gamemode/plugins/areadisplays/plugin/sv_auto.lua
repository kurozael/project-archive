--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:HookDataStream("EnteredArea", function(player, data)
	if ( data[1] and data[2] and data[3] ) then
		hook.Call( "PlayerEnteredArea", CloudScript, player, data[1], data[2], data[3] );
	end;
end);

-- A function to load the area names.
function PLUGIN:LoadAreaDisplays()
	self.areaDisplays = CloudScript:RestoreSchemaData( "plugins/areas/"..game.GetMap() );
end;

-- A function to save the area names.
function PLUGIN:SaveAreaDisplays()
	CloudScript:SaveSchemaData("plugins/areas/"..game.GetMap(), self.areaDisplays);
end;