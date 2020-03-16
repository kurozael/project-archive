--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 25;
CLASS.color = Color(150, 125, 100, 255);
CLASS.limit = 8;
CLASS.classes = {"Civilian"};
CLASS.description = "A secretary working for the president.\nThey earn more than a civilian\nwith full contraband, without the risk\nof having it destroyed.";
CLASS.headsetGroup = 1;
CLASS.defaultPhysDesc = "Wearing a clean, black suit with no tie";

-- Called when the model for the class is needed for a player.
function CLASS:GetModel(player, defaultModel)
	return string.gsub(defaultModel, "group%d%d", "group10");
end;

CLASS_SECRETARY = Clockwork.class:Register(CLASS, "Secretary");