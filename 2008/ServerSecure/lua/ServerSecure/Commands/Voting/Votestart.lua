------------------------------------------------
----[ START VOTE ]-----------------------
------------------------------------------------

local Votestart = SS.Commands:New("Votestart")

// Branch flag

SS.Flags.Branch("Administrator", "Votestart")

// Start vote command

function Votestart.Command(Player, Args)
	local Panel = SS.Voting:New(Player:SteamID(), Args[1], true)
	
	if not (Panel) then SS.PlayerMessage(Player, "This vote is already active!", 1) return end
	
	table.remove(Args, 1)
	
	for K, V in pairs(Args) do
		Panel:Words(V)
	end
	
	Panel:Send(30)
end

Votestart:Create(Votestart.Command, {"moderator", "votestart"}, "Start a new vote", "<Title>, <Option>", 2, ", ")