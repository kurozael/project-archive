--[[
Name: "sh_comm.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;
local COMMAND = {};

-- Set some information.
COMMAND.tip = "Add a vending machine.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local entity = ents.Create("ks_vendingmachine");
	
	-- Set some information.
	entity:SetPos( trace.HitPos + Vector(0, 0, 48) );
	entity:Spawn();
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		entity:SetStock(math.random(10, 20), true);
		entity:SetAngles( Angle(0, player:EyeAngles().yaw + 180, 0) );
		
		-- Notify the player.
		kuroScript.player.Notify(player, "You have added a vending machine.");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "vendingmachine");