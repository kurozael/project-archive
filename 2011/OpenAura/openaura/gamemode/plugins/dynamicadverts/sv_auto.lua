--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the dynamic adverts.
function PLUGIN:LoadDynamicAdverts()
	self.dynamicAdverts = openAura:RestoreSchemaData( "plugins/adverts/"..game.GetMap() );
end;

-- A function to save the dynamic adverts.
function PLUGIN:SaveDynamicAdverts()
	openAura:SaveSchemaData("plugins/adverts/"..game.GetMap(), self.dynamicAdverts);
end;