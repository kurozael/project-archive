local Plugin = SS.Plugins:New("Joke")

// Parse Jokes.ini

Plugin.List = {}

local Parse = SS.Parser:New("lua/ServerSecure/Plugins/Joke/Jokes")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		Plugin.List[K] = {}
		
		for B, J in pairs(V) do
			table.insert(Plugin.List[K], J)
		end
	end
end

// Random

function Plugin.Random(Player, Category)
	if (Plugin.List[Category]) then
		local Panel = SS.Panel:New(Player, Category)
		
		local Joke = SS.Lib.RandomTableEntry(Plugin.List[Category])
		
		Panel:Words(Joke)
		
		Panel:Send()
	end
end

// Chat command

local Joke = SS.Commands:New("Joke")

function Joke.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Jokes")
	
	for K, V in pairs(Plugin.List) do
		Panel:Button(K, {Plugin.Random, K})
	end
	
	Panel:Send()
end

Joke:Create(Joke.Command, {"basic"}, "View a random joke")

// Finish plugin

Plugin:Create()