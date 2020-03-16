------------------------------------------------
----[ INFO PLAYER ]---------------------
------------------------------------------------

local Info = SS.Commands:New("Info")

// View table of info

function Info.Table(Player, Args)
	local Players = player.GetAll()
	
	local Unique = tostring(Args[1])
	
	local Person = player.GetByUniqueID(Unique)
	
	if (Person) then
		if (CVAR.Request(Person, Args[2])) then
			local Text = CVAR.Format(Args[2])
			
			if not (Text) then Text = Args[2] end
			
			local Panel = SS.Panel:New(Player, Person:Name()..": "..Text)
			
			local Count = table.Count(CVAR.Request(Person, Args[2]))
			
			if (Count != 0) then
				for K, V in pairs(CVAR.Request(Person, Args[2])) do
					local Type = type(V)
					
					if (Type != "table") then
						if (V == "") then V = "None" end
						
						if (K == V) then
							Panel:Words(K)
						else
							Panel:Words(K..": "..tostring(V))
						end
					end
				end
			else
				Panel:Words("This user has no CVARS in this category")
			end
			
			Panel:Send()
		end
	else
		SS.PlayerMessage(Player, "Couldn't find this information!", 1)
	end
end

SS.ConsoleCommand.Simple("infocommand", Info.Table, 2)

// View command

function Info.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local Panel = SS.Panel:New(Player, Person:Name())
		
		local Identity = Person:SteamID()
		
		local Table = CVAR.Store[Identity]
		
		table.sort(Table, function(A, B) return (A < B) end)
		
		for K, V in pairs(Table) do
			local Type = type(V)
			
			if (Type != "table") then
				local Text = CVAR.Format(K)
				
				if not (Text) then Text = K end
				
				if (V == "") then V = "None" end
				
				if (Text == V) then
					Panel:Words(Text)
				else
					Panel:Words(Text..": "..tostring(V))
				end
			end
		end
		
		for K, V in pairs(Table) do
			local Type = type(V)
			
			if (Type == "table") then
				local Text = CVAR.Format(K)
				
				if not (Text) then Text = K end
				
				Panel:Button(Text, 'ss infocommand "'..Person:UniqueID()..'" "'..K..'"')
			end
		end
		
		Panel:Send()
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

Info:Create(Info.Command, {"basic"}, "View information about a player", "<Player>", 1, " ")

SS.Adverts.Add("Type "..SS.Commands.Prefix().."info <Player> to view information about a player!")