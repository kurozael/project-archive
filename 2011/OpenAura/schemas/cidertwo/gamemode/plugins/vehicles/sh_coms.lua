--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

COMMAND = openAura.command:New();
COMMAND.tip = "Set the physical description of a vehicle.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;

	if (IsValid(target) and target:IsVehicle() and target.ItemTable) then
		if (target:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if ( player.vehicles and player.vehicles[target] ) then
				if ( arguments[1] ) then
					local text = table.concat(arguments, " ");

					if (string.len(text) < 8) then
						openAura.player:Notify(player, "You did not specify enough text!");

						return;
					end;

					target.PhysDesc = openAura:ModifyPhysDesc(text);
					target:SetNetworkedString("physDesc", target.PhysDesc);
				else
					player.vehiclePhysDesc = target;

					umsg.Start("aura_VehiclePhysDesc", player);
						umsg.Entity(target);
					umsg.End();
				end;
			else
				openAura.player:Notify(player, "You are not the owner of this vehicle!");
			end;
		else
			openAura.player:Notify(player, "This entity is too far away!");
		end;
	else
		openAura.player:Notify(player, "You must look at a valid vehicle!");
	end;
end;

openAura.command:Register(COMMAND, "VehiclePhysDesc");