------------------------------------------------
----[ OPENSCRIPT ]----------------------
------------------------------------------------

local Openscript = SS.Commands:New("Openscript")

// Branch flag

SS.Flags.Branch("Server", "Openscript")

// Openscript command

function Openscript.Command(Player, Args)
	local File = table.concat(Args, " ")
	
	if not (file.Exists("../lua/ServerSecure/"..File)) then
		SS.PlayerMessage(Player, "No such file ServerSecure/"..File, 1)
		
		return
	end
	
	SS.Lib.ConCommand("lua_openscript", "ServerSecure/"..File)
	
	SS.PlayerMessage(Player, "ServerSecure/"..File.." opened", 0)
end

Openscript:Create(Openscript.Command, {"server", "openscript"}, "Open a script relative to the ServerSecure folder", "<File>", 1, " ")