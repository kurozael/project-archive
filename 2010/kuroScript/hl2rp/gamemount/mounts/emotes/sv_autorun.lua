--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to make a player exit their stance.
function MOUNT:MakePlayerExitStance(player, keepPosition)
	if (player._StancePosition and !keepPosition) then
		for k, v in ipairs( g_Player.GetAll() ) do
			if (v != player) then
				if (v:GetPos():Distance(player._StancePosition) <= 32) then
					kuroScript.player.Notify(player, "Another character is blocking this position!");
					
					-- Return to break the function.
					return;
				end;
			end;
		end;
		
		-- Set the player's safe position.
		kuroScript.player.SetSafePosition(player, player._StancePosition);
	end;
	
	-- Set some information.
	player._StanceLocation = nil;
	player._StancePosition = nil;
	
	-- Set some information.
	player:SetForcedAnimation(false);
	player:SetSharedVar("ks_Stance", false);
	player:DrawViewModel(true);
	player:Freeze(false);
end;