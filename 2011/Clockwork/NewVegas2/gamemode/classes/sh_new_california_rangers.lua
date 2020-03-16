--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};
	CLASS.color = Color(50, 200, 175, 255);
	CLASS.factions = {FACTION_NCR};
	CLASS.isDefault = true;
	CLASS.description = "A member of one of the most powerful military groups in New Vegas.";
	CLASS.defaultPhysDesc = "Wearing military gear and equipment";
CLASS_NCR = Clockwork.class:Register(CLASS, "New California Rangers");