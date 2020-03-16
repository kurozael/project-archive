------------------------------------------------
----[ VOTING ]-----------------------------
------------------------------------------------

SS.Voting       = {} -- Voting
SS.Voting.Votes = {} -- Where votes are stored

// Start vote

function SS.Voting:New(ID, Title, Message)
	if (SS.Voting.Votes[ID]) then return false end
	
	local Table = {}
	
	setmetatable(Table, self)
	
	self.__index = self
	
	Table.ID = ID
	Table.Title = Title
	Table.Message = Message
	Table.Votes = {}
	Table.Options = {}
	
	return Table
end

// Add option

function SS.Voting:Words(Option)
	table.insert(self.Options, {Option, 0})
end

// Send

function SS.Voting:Send(Time, Callback)
	self.Time = Time
	
	self.Function = Callback or function() end
	
	SS.Voting.Votes[self.ID] = self
	
	timer.Create("Vote_"..self.ID, self.Time, 1, SS.Voting.Finish, self.ID)
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Panel = SS.Panel:New(V, self.Title)
		
		for B, J in pairs(self.Options) do
			Panel:Button(J[1], 'ss registervote "'..self.ID..'" "'..B..'"')
		end
		
		Panel:Send()
	end
	
end

// Vote

function SS.Voting.Register(Player, Args)
	local Vote = Args[1]
	
	if not (SS.Voting.Votes[Vote]) then SS.PlayerMessage(Player, "There is no vote with that key active!", 1) return end
	
	for K, V in pairs(SS.Voting.Votes[Vote].Votes) do
		if (V[1] == Player) then
			SS.PlayerMessage(Player, "You have already voted!", 1)
			
			return
		end
	end
	
	local Key = tonumber(Args[2])
	
	if not (Key) then SS.PlayerMessage(Player, "Please enter a valid voting key!", 1) return end
	
	if not (SS.Voting.Votes[Vote].Options[Key]) then SS.PlayerMessage(Player, "That is not a valid entry!", 1) return end
	
	SS.Voting.Votes[Vote].Options[Key][2] = SS.Voting.Votes[Vote].Options[Key][2] + 1
	
	SS.PlayerMessage(0, Player:Name().." voted for "..SS.Voting.Votes[Vote].Options[Key][1].."!", 0)
	
	table.insert(SS.Voting.Votes[Vote].Votes, {Player, Key, SS.Voting.Votes[Vote].Options[Key][1]})
end

SS.ConsoleCommand.Simple("registervote", SS.Voting.Register, 2)

// Finish

function SS.Voting.Finish(ID)
	local Cur = 0
	local Winner = ""
	
	for K, V in pairs(SS.Voting.Votes[ID].Options) do
		if (V[2] > Cur) then
			Cur = V[2]
			
			Winner = V[1]
		end
	end
	
	if (SS.Voting.Votes[ID].Message) then
		if (Winner == "") then
			SS.PlayerMessage(0, "Vote '"..SS.Voting.Votes[ID].Title.."': No winner!", 0)
		else
			SS.PlayerMessage(0, "Vote '"..SS.Voting.Votes[ID].Title.."': The winner was "..Winner.."!", 0)
		end
	end
	
	SS.Hooks.Run("ServerVoteFinished", ID, Winner, Cur)
	
	SS.Voting.Votes[ID].Function(Winner, Cur, SS.Voting.Votes[ID].Votes)
	
	SS.Voting.Votes[ID] = nil
end
