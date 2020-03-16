--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.ammo = {pistol = 64};
CLASS.wages = 25;
CLASS.color = Color(150, 125, 100, 255);
CLASS.limit = 16;
CLASS.factions = {FACTION_POLICE};
CLASS.weapons = {"weapon_glock"};
CLASS.description = "Supplies the police force with equipment.\nThey earn more than a civilian\nwith full contraband, without the risk\nof having it destroyed.";
CLASS.headsetGroup = 1;
CLASS.defaultPhysDesc = "Wearing a nice, clean police uniform";

-- Called when the model for the class is needed for a player.
function CLASS:GetModel(player, defaultModel)
	return string.gsub(defaultModel, "group%d%d", "group09");
end;

CLASS_DISPENSER = openAura.class:Register(CLASS, "Dispenser");