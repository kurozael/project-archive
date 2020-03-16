--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludeDirectory(openAura:GetPluginDirectory().."/victories/");

openAura.player:RegisterSharedVar("stamina", NWTYPE_NUMBER, true);
openAura.player:RegisterSharedVar("thermal", NWTYPE_BOOL, true);

openAura:IncludePrefixed("sv_hooks.lua");
openAura:IncludePrefixed("cl_hooks.lua");