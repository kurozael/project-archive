--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the Clockwork shared variables are added.
function PLUGIN:ClockworkAddSharedVars(globalVars, playerVars)
	playerVars:Number("Fuel", true);
end;

Clockwork:IncludePrefixed("cl_plugin.lua");
Clockwork:IncludePrefixed("sv_plugin.lua");
Clockwork:IncludePrefixed("sv_hooks.lua");
Clockwork:IncludePrefixed("cl_hooks.lua");
Clockwork:IncludePrefixed("sh_coms.lua");

PLUGIN.normalExits = {
	"exit1", "exit2", "exit3", "exit4", "exit5", "exit6"
};

-- A function to handle the roller coaster animation.
local function HandleRollercoasterAnimation(vehicle, player)
	return player:SelectWeightedSequence(ACT_GMOD_SIT_ROLLERCOASTER);
end;

list.Set("Vehicles", "Seat_Jeep", { 	
	Name = "Jeep Seat",
	Model = "models/nova/jeep_seat.mdl",
	Class = "prop_vehicle_prisoner_pod",
	Author = "Nova[X]",
	Members = {
		HandleAnimation = HandleRollercoasterAnimation,
	},
	Category = "Half-Life 2",
	KeyValues = {
		vehiclescript = "scripts/vehicles/prisoner_pod.txt",
		limitview = "0"
	},
	Information = "Classic Jeep passenger Seat",
	CustomExits = { Vector(0, -50, 0), Vector(50, 0, 0), Vector(-50, 0, 0), Vector(0, 50, 0), Vector(0, 0, 50), Vector(0, 0, -50) },
});