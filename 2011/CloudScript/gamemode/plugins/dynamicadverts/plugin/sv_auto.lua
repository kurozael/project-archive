--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to load the dynamic adverts.
function PLUGIN:LoadDynamicAdverts()
	self.dynamicAdverts = CloudScript:RestoreSchemaData( "plugins/adverts/"..game.GetMap() );
end;

-- A function to save the dynamic adverts.
function PLUGIN:SaveDynamicAdverts()
	CloudScript:SaveSchemaData("plugins/adverts/"..game.GetMap(), self.dynamicAdverts);
end;