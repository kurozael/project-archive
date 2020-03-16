--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when a player's character screen info should be adjusted.
function MOUNT:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( !kuroScript.game:IsCombineClass(character._Class) ) then
		if ( character._Data["biosignal"] ) then
			info.tags["Biosignal Recorded"] = true;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	if ( player:GetCharacterData("biosignal") ) then
		player:SetSharedVar("ks_Biosignal", true);
	else
		player:SetSharedVar("ks_Biosignal", false);
	end;
end;