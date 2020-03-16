--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 25;
CLASS.ammo = {pistol = 64};
CLASS.color = Color(150, 125, 100, 255);
CLASS.weapons = {"weapon_glock"};
CLASS.isDefault = true;
CLASS.factions = {FACTION_POLICE};
CLASS.description = "A hard working police officer of the city.\nThey earn more than a civilian\nwith full contraband, without the risk\nof having it destroyed.";
CLASS.headsetGroup = 1;
CLASS.defaultPhysDesc = "Wearing a nice, clean police uniform";

-- Called when the model for the class is needed for a player.
function CLASS:GetModel(player, defaultModel)
	return string.gsub(defaultModel, "group%d%d", "group09");
end;

CLASS_POLICE = Clockwork.class:Register(CLASS, "Police");