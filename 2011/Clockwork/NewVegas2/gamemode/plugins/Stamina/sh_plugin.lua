--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function PLUGIN:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Stamina", true);
end;

Clockwork:IncludePrefixed("sv_hooks.lua");
Clockwork:IncludePrefixed("cl_hooks.lua");