--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};

CLASS.wages = 10;
CLASS.limit = 32;
CLASS.color = Color(150, 125, 100, 255);
CLASS.classes = {"Civilian"};
CLASS.description = "A seller of food, drink and alcohol.\nThey earn decent wages from legitimate sales.";
CLASS.defaultPhysDesc = "Wearing nice and clean clothes";

CLASS_CATERER = openAura.class:Register(CLASS, "Caterer");