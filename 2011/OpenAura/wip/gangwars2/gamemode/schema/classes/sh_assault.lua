--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(125, 50, 125, 255);
CLASS.image = "gangwars2/classes/assault";
CLASS.factions = {FACTION_QAEDA, FACTION_MAFIA, FACTION_YAKUZA, FACTION_KINGS};
CLASS.isDefault = true;
CLASS.description = "Basic assault gang member specialising in front line combat.";
CLASS.defaultPhysDesc = "Holding a primary and secondary weapon";

CLASS_ASSAULT = openAura.class:Register(CLASS, "Assault");