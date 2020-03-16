--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

usermessage.Hook("aura_StorageMessage", function(msg)
	local entity = msg:ReadEntity();
	local message = msg:ReadString();
	
	if ( IsValid(entity) ) then
		entity.message = message;
	end;
end);

usermessage.Hook("aura_ContainerPassword", function(msg)
	local entity = msg:ReadEntity();
	
	Derma_StringRequest("Password", "What is the password for this container?", nil, function(text)
		openAura:StartDataStream( "ContainerPassword", {text, entity} );
	end);
end);