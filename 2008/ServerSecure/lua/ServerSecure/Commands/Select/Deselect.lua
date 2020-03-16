------------------------------------------------
----[ DESELECT ALL ]--------------------
------------------------------------------------

local Deselect = SS.Commands:New("Deselect")

// Deselect command

function Deselect.Command(Player, Args)
	if not (TVAR.Request(Player, "Selected")) then
		SS.PlayerMessage(Player, "You have no entities selected!", 1)
		
		return
	end
	
	local Number = Player:DeselectEntities()
	
	SS.PlayerMessage(Player, Number.." entities deselected!", 0)
end

Deselect:Create(Deselect.Command, {"basic"}, "Deselect all selected entities")