--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = openAura.command:New();
COMMAND.tip = "Add a vending machine at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local entity = ents.Create("aura_vendingmachine");
	
	entity:SetPos( trace.HitPos + Vector(0, 0, 48) );
	entity:Spawn();
	
	if ( IsValid(entity) ) then
		entity:SetStock(math.random(10, 20), true);
		entity:SetAngles( Angle(0, player:EyeAngles().yaw + 180, 0) );
		
		openAura.player:Notify(player, "You have added a vending machine.");
	end;
end;

openAura.command:Register(COMMAND, "VendorAdd");