--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.color = Color(50, 100, 150, 255);
CLASS.wages = 20;
CLASS.factions = {FACTION_MPF};
CLASS.isDefault = true;
CLASS.wagesName = "Supplies";
CLASS.description = "A metropolice unit working as Civil Protection.";
CLASS.defaultPhysDesc = "Wearing a metrocop jacket with a radio";

CLASS_MPU = openAura.class:Register(CLASS, "Metropolice Unit");