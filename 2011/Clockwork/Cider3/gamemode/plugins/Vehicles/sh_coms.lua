--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the physical description of a vehicle.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;

	if (IsValid(target) and target:IsVehicle() and target.cwItemTable) then
		if (target:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (player.cwVehicleList and player.cwVehicleList[target]) then
				if (arguments[1]) then
					local text = table.concat(arguments, " ");

					if (string.len(text) < 8) then
						Clockwork.player:Notify(player, "You did not specify enough text!");

						return;
					end;

					target.cwPhysDesc = Clockwork:ModifyPhysDesc(text);
					target:SetNetworkedString("PhysDesc", target.cwPhysDesc);
				else
					player.cwVehiclePhysDesc = target;

					umsg.Start("cwVehiclePhysDesc", player);
						umsg.Entity(target);
					umsg.End();
				end;
			else
				Clockwork.player:Notify(player, "You are not the owner of this vehicle!");
			end;
		else
			Clockwork.player:Notify(player, "This entity is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid vehicle!");
	end;
end;

Clockwork.command:Register(COMMAND, "VehiclePhysDesc");