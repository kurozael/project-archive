--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(200, 200, 50, 255);
CLASS.factions = {FACTION_BROTHERHOOD};
CLASS.isDefault = true;
CLASS.description = "A member of the heavily armed Brotherhood of Steel.";
CLASS.defaultPhysDesc = "Wearing a dark grey Power Armor set";

CLASS_BROTHERHOOD = openAura.class:Register(CLASS, "Brotherhood of Steel");