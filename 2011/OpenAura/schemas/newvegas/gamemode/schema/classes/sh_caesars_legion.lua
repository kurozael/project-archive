--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(75, 200, 50, 255);
CLASS.factions = {FACTION_LEGION};
CLASS.isDefault = true;
CLASS.description = "A member of the infamous slaver organisation.";
CLASS.defaultPhysDesc = "Wearing dirty and scratched combat armor";

CLASS_LEGION = openAura.class:Register(CLASS, "Caesar's Legion");