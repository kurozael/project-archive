------------------------------------------------
----[ SET A PLAYERS GROUP ]---------
------------------------------------------------

local Group = SS.Commands:New("Group")

// Branch flag

SS.Flags.Branch("Server", "Group")

// Group command

function Group.Command(Player, Args)
	local ID = Args[1]
	
	local Level = table.concat(Args, " ", 2)
	
	local Group = ""
	
	local Found = false
	
	for K, V in pairs(SS.Groups.List) do
		if (string.lower(Level) == string.lower(V[1])) then
			Group = V[1]
			
			Found = true
		end
	end
	
	if not (Found) then
		SS.PlayerMessage(Player, "Invalid group name!", 1)
		
		return
	end
	
	if (SS.Groups.Rank(Level) < SS.Groups.Rank(SS.Player.Rank(Player))) then
		SS.PlayerMessage(Player, "You cannot change this person's group, because it is ranked higher than yours!", 1)
		
		return
	end
	
	local Person, Error = SS.Lib.Find(ID)
	
	if (Person) then
		if Person == Player then SS.PlayerMessage(Player, "Cannot change your own group!", 1) return end
		
		SS.PlayerMessage(0, Person:Name().."'s group has been changed to "..Group, 0)
		
		SS.Groups.Change(Person, Group)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Group:Create(Group.Command, {"group", "server"}, "Change somebodies group", "<Player> <Group>", 2, " ")