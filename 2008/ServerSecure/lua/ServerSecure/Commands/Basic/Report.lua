------------------------------------------------
----[ REPORT PLAYER ]-------------------
------------------------------------------------

local Report = SS.Commands:New("Report")

// Report command

function Report.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if Person then
		table.remove(Args, 1)
		
		local Reason = table.concat(Args, " ")
		
		local File = ""
		
		if (file.Exists("SS/Reports.txt")) then
			File = file.Read("SS/Reports.txt").."\n"
		end
		
		File = File.."[Report] "..Player:Name().." ("..Player:SteamID()..") reported "..Person:Name().." ("..Person:SteamID().."), Reason: '"..Reason.."'"
		
		file.Write("SS/Reports.txt", File)
		
		SS.PlayerMessage(Player, Person:Name().." has been reported!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Report:Create(Report.Command, {"basic"}, "Report somebody", "<Player> <Reason>", 2, " ")

SS.Adverts.Add("Report someone by typing "..SS.Commands.Prefix().."report <Name> <Reason>")