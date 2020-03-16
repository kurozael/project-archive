local Plugin = SS.Plugins:New("News")

// Config

Plugin.News = "To set the news please type "..SS.Commands.Prefix().."news <Text>"

// When a player initially spawns

function Plugin.PlayerInitialSpawn(Player)
	Plugin.Show(Player)
end

// Show

function Plugin.Show(Player)
	local News = SVAR.Request("news")
	
	local Panel = SS.Panel:New(Player, "News")
	
	Panel:Words(News)
	
	Panel:Button("Rules", {SS.Rules.Show})
	
	Panel:Send()
end

// Chat command

local Command = SS.Commands:New("News")

function Command.Command(Player, Args)
	local News = table.concat(Args, " ")
	
	SVAR.Update("news", News)
	
	SS.PlayerMessage(Player, "The server news has been set to "..News.."!", 0)
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		Plugin.Show(V)
	end
end

Command:Create(Command.Command, {"server"}, "Set the news of the server", "<Text>", 1, " ")

// When servers loads

function Plugin.ServerLoad()
	SVAR.New("news", Plugin.News)
end

Plugin:Create()