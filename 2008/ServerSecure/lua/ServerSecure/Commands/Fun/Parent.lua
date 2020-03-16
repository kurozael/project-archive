------------------------------------------------
----[ PARENT ]-----------------------------
------------------------------------------------

local Parent = SS.Commands:New("Parent")

// Branch flag

SS.Flags.Branch("Fun", "Parent")

// Parent command

function Parent.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local Trace = Player:TraceLine()
		
		if not (Trace.Entity) then
			SS.PlayerMessage(Player, "You must aim at a valid entity!", 1)
			
			return
		end
		
		Trace.Entity:SetParent(Person)
		
		SS.PlayerMessage(Player, "Entity has been successfully parented to "..Player:Name().."!", 0)
		
		local function Function(Undo, Entity)
			local Valid = SS.Lib.Valid(Entity)
			
			if (Valid) then
				Entity:SetParent()
			end
		end
		
		undo.Create("Parent")
			undo.SetPlayer(Player)
			undo.AddFunction(Function, Trace.Entity)
		undo.Finish()
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Parent:Create(Parent.Command, {"administrator", "fun", "parent"}, "Parent target entity to a player", "<Player>", 1, " ")