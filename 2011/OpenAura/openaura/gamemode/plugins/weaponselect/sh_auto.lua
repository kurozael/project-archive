--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

if (CLIENT) then
	PLUGIN.displaySlot = 0;
	PLUGIN.displayFade = 0;
	PLUGIN.displayAlpha = 0;
	PLUGIN.displayDelay = 0;
	PLUGIN.weaponPrintNames = {};
end;

openAura.config:ShareKey("weapon_selection_multi");

openAura:IncludePrefixed("cl_hooks.lua");