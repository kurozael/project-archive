-----------------------------------------
-----[ CRACK CODE ]---------------
-----------------------------------------

local Plugin = SS.Plugins:New("Crack")

// Chat command

local Command = SS.Commands:New("Crack")

function Command.Command(Player, Args)
	if (Keypad) then
		local Trace = util.GetPlayerTrace(Player)
		
		local TR = util.TraceLine(Trace)
		
		if (TR.Entity) then
			local Index = TR.Entity:EntIndex()
			
			for K, V in pairs(Keypad.Passwords) do
				if (Index == V.Ent) then
					SS.PlayerMessage(Player, "Password: '"..V.Pass.."'!", 0)
					
					return
				end
			end
			
			SS.PlayerMessage(Player, "Could not crack keypad!", 0)
		else
			SS.PlayerMessage(Player, "You must aim at a valid entity!", 1)
		end
		
	else
		SS.PlayerMessage(Player, "Keypad is not installed on this server!", 1)
	end
end

Command:Create(Command.Command, {"administrator"}, "Crack a keypad code")

Plugin:Create()