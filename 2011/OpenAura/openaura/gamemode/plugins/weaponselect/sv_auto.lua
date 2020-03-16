--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- Whether or not doors are hidden by default.
openAura.config:Add("weapon_selection_multi", false);

openAura:HookDataStream("SelectWeapon", function(player, data)
	if (type(data) == "string") then
		if ( player:HasWeapon(data) ) then
			player:SelectWeapon(data);
		end;
	end;
end);