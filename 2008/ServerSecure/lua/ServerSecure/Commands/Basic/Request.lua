------------------------------------------------
----[ REQUEST MOD ]-------------------
------------------------------------------------

local Request = SS.Commands:New("Request")

// Request command

function Request.Command(Player, Args)
	local ID = Args[1]
	
	table.remove(Args, 1)
	
	local Reason = table.concat(Args, " ")
	
	local File = ""
	
	if (file.Exists("SS/Requests.txt")) then
		File = file.Read("SS/Requests.txt").."\n"
	end
	
	File = File.."[Request] "..Player:Name().." ("..Player:SteamID()..") requested "..ID..", Reason: '"..Reason.."'"
	
	file.Write("SS/Requests.txt", File)
	
	SS.PlayerMessage(Player, ID.." has been requested!", 0)
end

Request:Create(Request.Command, {"basic"}, "Request a new mod to be added", "<Name/Link> <Reason>", 2, " ")

SS.Adverts.Add("Request new mods by typing "..SS.Commands.Prefix().."request <Name> <Reason>")