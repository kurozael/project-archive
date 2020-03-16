--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.config:AddAuraWatch("max_safebox_weight", "The maximum weight a player's safebox can hold.");

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

openAura.chatBox:RegisterClass("wire", "ic", function(info)
	openAura.chatBox:Add(info.filtered, nil, Color(275, 255, 200, 255), info.text);
end);