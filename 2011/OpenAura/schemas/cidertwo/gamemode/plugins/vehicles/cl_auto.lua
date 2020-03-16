--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

usermessage.Hook("aura_VehiclePhysDesc", function(msg)
	local entity = msg:ReadEntity();
	
	if ( IsValid(entity) ) then
		Derma_StringRequest("Description", "What is the physical description of this vehicle?", nil, function(text)
			openAura:StartDataStream( "VehiclePhysDesc", {entity, text} );
		end);
	end;
end);