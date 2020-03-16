------------------------------------------------
----[ REMOVE ALL ]-----------------------
------------------------------------------------

local RemoveAll = SS.Commands:New("RemoveAll")

// Branch flag

SS.Flags.Branch("Administrator", "RemoveAll")

// Remove all command

function RemoveAll.Command(Player, Args)
	local Class = ents.FindByClass(Args[1])
	local Found = false
	
	for K, V in pairs(Class) do
		V:Remove()
		
		Found = true
	end
	
	if (Found) then
		SS.PlayerMessage(Player, "Removed all "..Args[1].." entities on the server!", 0)
	else
		SS.PlayerMessage(Player, "No "..Args[1].." entities exist on the server!", 0)
	end
end

RemoveAll:Create(RemoveAll.Command, {"removeall", "administrator"}, "Remove all entities of a specific class", "<Class>", 1, " ")