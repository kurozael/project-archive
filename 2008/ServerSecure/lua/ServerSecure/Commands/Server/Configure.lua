------------------------------------------------
----[ CONFIGURE ]------------------------
------------------------------------------------

local Command = SS.Commands:New("Configure")

// Branch flag

SS.Flags.Branch("Server", "Configure")

// Configure command

function Command.Command(Player, Args)
	SS.Plugins.Configure(Player)
end

Command:Create(Command.Command, {"configure", "server"}, "Configure the plugins on the server")