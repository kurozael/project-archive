--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 30;
CLASS.color = Color(150, 125, 100, 255);
CLASS.limit = 1;
CLASS.classes = {"Secretary"};
CLASS.description = "The guy who keeps the city together.\nThey earn more than a civilian\nwith full contraband, without the risk\nof having it destroyed.";
CLASS.headsetGroup = 1;
CLASS.defaultPhysDesc = "Wearing a clean, brown suit with a tie";

-- Called when the model for the class is needed for a player.
function CLASS:GetModel(player, defaultModel)
	return string.gsub(defaultModel, "group%d%d", "group17");
end;

CLASS_PRESIDENT = openAura.class:Register(CLASS, "President");