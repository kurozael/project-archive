------------------------------------------------
----[ WRITE ]-------------------------------
------------------------------------------------

local Write = SS.Commands:New("Write")

// Branch flag

SS.Flags.Branch("Server", "Write")

// Write command

function Write.Command(Player, Args)
	local File = Args[1]
	
	table.remove(Args, 1)
	
	local Text = table.concat(Args, " ")
	
	local Content = ""
	
	if (file.Exists("SS/Write/"..File..".txt")) then
		Content = file.Read("SS/Write/"..File..".txt").."\n"
	end
	
	Content = Content..Text
	
	file.Write("SS/Write/"..File..".txt", Content)
	
	SS.PlayerMessage(Player, "Text added to '"..File.."'!", 0)
end

Write:Create(Write.Command, {"server", "write"}, "Write text to a file in the Data/SS/Write/ directory", "<File> <Text>", 2, " ")

------------------------------------------------
----[ READ ]---------------------------------
------------------------------------------------

local Read = SS.Commands:New("Read")

// Branch flag

SS.Flags.Branch("Server", "Read")

// Read command

function Read.Command(Player, Args)
	local File = Args[1]
	
	if (file.Exists("SS/Write/"..File)) then
		local Content = file.Read("SS/Write/"..File)
		
		local Explode = string.Explode("\n", Content)
		
		local Panel = SS.Panel:New(Player, File)
		
		for K, V in pairs(Explode) do
			Panel:Words(V)
		end
		
		Panel:Send()
		
		SS.PlayerMessage(Player, "'"..File.."' has been successfully Readed!", 0)
	else
		SS.PlayerMessage(Player, "File does not exist: 'SS/Write/"..File.."'!", 0)
	end
end

Read:Create(Read.Command, {"server", "read"}, "Read a file from the Data/SS/Write/ directory", "<File>", 1, " ")