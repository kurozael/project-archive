--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- A function to make a player exit their stance.
function PLUGIN:MakePlayerExitStance(player, keepPosition)
	if (player.previousPosition and !keepPosition) then
		for k, v in ipairs( _player.GetAll() ) do
			if (v != player and v:GetPos():Distance(player.previousPosition) <= 32) then
				CloudScript.player:Notify(player, "Another character is blocking this position!");
				
				return;
			end;
		end;
		
		CloudScript.player:SetSafePosition(player, player.previousPosition);
	end;
	
	player:SetForcedAnimation(false);
	player.previousPosition = nil;
	player:SetSharedVar( "stancePosition", Vector(0, 0, 0) );
	player:SetSharedVar( "stanceAngles", Angle(0, 0, 0) );
	player:SetSharedVar( "stanceIdle", false );
end;