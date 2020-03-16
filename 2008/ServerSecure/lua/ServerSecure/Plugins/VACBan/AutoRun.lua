local Plugin = SS.Plugins:New("VACBan")

// Chat command

local VACBan = SS.Commands:New("VACBan")

function VACBan.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		umsg.Start("SS.VACBan", Person) umsg.End()
		
		SS.PlayerMessage(Player, "You fake VAC banned "..Person:Name().."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

VACBan:Create(VACBan.Command, {"administrator", "vacban"}, "Fake VAC ban a specific player", "<Player>", 1)

// Finish plugin

Plugin:Create()