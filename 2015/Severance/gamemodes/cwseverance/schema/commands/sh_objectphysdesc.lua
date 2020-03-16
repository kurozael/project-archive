--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the physical description of an object.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (target:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (Clockwork.entity:IsPhysicsEntity(target)) then
				if (player:GetCharacterKey() == target:GetOwnerKey()) then
					player.cwObjectPhysDesc = target;
					
					umsg.Start("cwObjectPhysDesc", player);
						umsg.Entity(target);
					umsg.End();
				else
					Clockwork.player:Notify(player, "You are not the owner of this entity!");
				end;
			else
				Clockwork.player:Notify(player, "This entity is not a physics entity!");
			end;
		else
			Clockwork.player:Notify(player, "This entity is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

Clockwork.command:Register(COMMAND, "ObjectPhysDesc");