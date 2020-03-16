local Plugin = SS.Plugins:New("Radar")

// Chat command

local Command = SS.Commands:New("Radar")

function Command.Command(Player, Args)
	local TR = util.GetPlayerTrace(Player)
	
	local Trace = util.TraceLine(TR)
	
	if not (Trace.Entity) then
		SS.PlayerMessage(Player, "You must aim at a valid entity!", 1)
		
		return
	end
	
	local ID = table.concat(Args, " ")
	
	SS.PlayerMessage(Player, "Entity has been added to radar!", 0)
	
	Player:ConCommand('ss_radarentity "'..ID..'"\n')
end

Command:Create(Command.Command, {"basic"}, "Add an entity to your radar", "<Name>", 1, " ")

// Advert

SS.Adverts.Add("To see the radar type ss_showradar 1!")

// Finish plugin

Plugin:Create()