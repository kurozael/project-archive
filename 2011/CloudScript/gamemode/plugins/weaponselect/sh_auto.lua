--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	PLUGIN.displaySlot = 0;
	PLUGIN.displayFade = 0;
	PLUGIN.displayAlpha = 0;
	PLUGIN.displayDelay = 0;
	PLUGIN.weaponPrintNames = {};
end;

CloudScript.config:ShareKey("weapon_selection_multi");

CloudScript:IncludePrefixed("hooks/cl_hooks.lua");
CloudScript:IncludePrefixed("plugin/cl_auto.lua");
CloudScript:IncludePrefixed("plugin/sv_auto.lua");