--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = {};
	CLASS.wages = 5;
	CLASS.limit = 16;
	CLASS.color = Color(150, 125, 100, 255);
	CLASS.classes = {"Civilian"};
	CLASS.description = "An underground blackmarket dealer.\nThey have low wages compared to legal classes.";
	CLASS.defaultPhysDesc = "Wearing nice and clean clothes";
CLASS_BLACKMARKET = Clockwork.class:Register(CLASS, "Blackmarket");