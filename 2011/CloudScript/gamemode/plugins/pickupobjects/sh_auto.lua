--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.player:AddSharedVar("beingDragged", NWTYPE_BOOL, true);

CloudScript:IncludePrefixed("hooks/sv_hooks.lua");
CloudScript:IncludePrefixed("hooks/cl_hooks.lua");
CloudScript:IncludePrefixed("plugin/cl_auto.lua");
CloudScript:IncludePrefixed("plugin/sv_auto.lua");