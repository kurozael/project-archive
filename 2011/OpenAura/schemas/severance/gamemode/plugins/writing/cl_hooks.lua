--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when an entity's menu options are needed.
function PLUGIN:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass();
	
	if (class == "aura_paper") then
		if ( entity:GetDTBool("note") ) then
			options["Read"] = "aura_paperOption";
		else
			options["Write"] = "aura_paperOption";
		end;
	end;
end;