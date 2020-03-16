--[[
Name: "sh_comm.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;
local COMMAND = {};

-- Set some information.
COMMAND.tip = "Record the biosignal of the character you're looking at.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( target and target:IsPlayer() ) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			if ( kuroScript.game:PlayerIsCombine(player) ) then
				if ( !kuroScript.game:PlayerIsCombine(target) ) then
					if (target:GetSharedVar("ks_Tied") != 0) then
						target:SetCharacterData("biosignal", true);
						
						-- Notify the player.
						kuroScript.player.Notify(player, "You have recorded this character's biosignal.");
					else
						kuroScript.player.Notify(player, "This character is not tied!");
					end;
				else
					kuroScript.player.Notify(player, "You cannot record the Combine's biosignal!");
				end;
			else
				kuroScript.player.Notify(player, "You are not the Combine!");
			end;
		else
			kuroScript.player.Notify(player, "This character is too far away!");
		end;
	else
		kuroScript.player.Notify(player, "You must look at a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "biosignal");