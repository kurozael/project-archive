------------------------------------------------
----[ NOCLIP ]----------------------------------
------------------------------------------------

local Noclip = SS.Commands:New("Noclip")

// Noclip command

function Noclip.Command(Player, Args)
	if (Player:GetMoveType() == MOVETYPE_NOCLIP) then
		Player:SetMoveType(MOVETYPE_WALK)
	else
		Player:SetMoveType(MOVETYPE_NOCLIP)
	end
end

// Overwrite

function Noclip.PlayerNoClip(Player, ON)
	Player:ConCommand("ss noclip\n")
	
	return false
end

hook.Add("PlayerNoClip", "Noclip.PlayerNoClip", Noclip.PlayerNoClip)

Noclip:Create(Noclip.Command, {"basic"}, "Enter noclip mode")