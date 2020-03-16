local Plugin = SS.Plugins:New("Protect")

// Tables

Plugin.Protecting = {}

// Branch flag

SS.Flags.Branch("Moderator", "Protect")

------[ CHAT COMMAND ]----------------

local Command = SS.Commands:New("Protect")

function Command.Command(Player, Args)
	local Selected = Player:EntitiesSelected()
	
	if not (Selected) then
		SS.PlayerMessage(Player, "Select some entities first using "..SS.Commands.Prefix().."select!", 1)
		
		return
	end
	
	local Number = 0
	
	for K, V in pairs(Selected) do
		local Index = V:EntIndex()
		
		Plugin.Protecting[Index] = V
		
		Number = Number + 1
	end
	
	SS.PlayerMessage(Player, "Protected "..Number.." entities from noclip!", 0)
end

Command:Create(Command.Command, {"moderator", "protect"}, "Protect selected entities from noclip")

--[ THINK ]--

function Plugin.ServerThink()
	for K, V in pairs(Plugin.Protecting) do
		local Valid = SS.Lib.Valid(V)
		
		if (V and Valid) then
			local Players = player.GetAll()
			
			for B, J in pairs(Players) do
				if (J:GetMoveType() == MOVETYPE_NOCLIP) then
					local Len = V:GetPos() - J:GetPos()
					
					Len = Len:Length()
					
					local Radius = V:BoundingRadius()
					
					if (Len <= Radius) then
						J:Kill()
						
						SS.PlayerMessage(J, "This entity has noclip prevention!", 1)
					end
				end
			end
		else
			Plugin.Protecting[K] = nil
		end
	end
end

// Space for other plugins

function Plugin.ServerLoad()
	if (PurchaseFlags) then
		PurchaseFlags.Add("Protect", "Flags [Protect]", 5, "Protect your entities from noclip")
	end
end

Plugin:Create()