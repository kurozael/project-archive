------------------------------------------------
----[ VOTE BAN ]--------------------------
------------------------------------------------

local VoteBan = SS.Commands:New("VoteBan")

// Config

VoteBan.Time   = 60 // Time banned for
VoteBan.Limit  = 60 // Seconds before can voteban again

// Variables

VoteBan.Check  = {} // Leave this
VoteBan.Player = "None" // Leave this

// Ban command

function VoteBan.Command(Player, Args)
	local Cur = CurTime()
	
	if (VoteBan.Check[Player]) then
		if (VoteBan.Check[Player] > Cur) then
			SS.PlayerMessage(Player, "You cannot do another voteban so soon!", 1)
			
			return
		end
	end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local Error = SS.Player.Immune(Player, Person)
		
		if (Error and Person != Player) then SS.PlayerMessage(Player, Error, 1) return end
		
		local Vote = SS.Voting:New("Ban", "Ban "..Person:Name(), false)
		
		if (Vote) then
			VoteBan.Player = Person
			
			Vote:Words("Yes")
			Vote:Words("No")
			
			Vote:Send(20, VoteBan.End)
		else
			SS.PlayerMessage(Player, "Ban vote already in progress!", 1)
		end
		
		VoteBan.Check[Player] = Cur + VoteBan.Limit
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

// End ban command

function VoteBan.End(Winner, Number, Table)
	if (Winner == "" or Winner == " ") then SS.PlayerMessage(0, "Ban Vote: No winner!", 0) return end
	
	if not (VoteBan.Player:IsPlayer()) then SS.PlayerMessage(0, "Ban Vote: Player no longer connected!", 0) return end
	
	if (Winner == "Yes") then
		local Enough, Amount = SS.Lib.VotesNeeded(Number)
		
		if (Enough) then
			SS.Lib.PlayerBan(VoteBan.Player, VoteBan.Time, "Vote Banned")
		else
			SS.PlayerMessage(0, "Ban Vote: Not enough votes to ban "..VoteBan.Player:Name()..", "..Number.."/"..Amount.."!", 1)
		end
	else
		SS.PlayerMessage(0, "Ban Vote: The answer was no!", 0)
	end
end

VoteBan:Create(VoteBan.Command, {"basic"}, "Start a vote to ban a player", "<Player>", 1, " ")

SS.Adverts.Add("You can start a voteban by typing "..SS.Commands.Prefix().."voteban <Name>")