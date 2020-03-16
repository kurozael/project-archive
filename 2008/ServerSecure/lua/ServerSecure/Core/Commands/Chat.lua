SS.Commands      = {} -- Main chat table
SS.Commands.List = {} -- Where commands are stored

-------------------------------------------------------------
----[ GET A COMMAND ]----------------------------------
-------------------------------------------------------------

function SS.Commands.Find(Index)
	Index = string.lower(Index)
	
	for K, V in pairs(SS.Commands.List) do
		if (V.Command == Index) then
			return V
		end
	end
	
	return false
end

-------------------------------------------------------------
----[ INITIATE NEW CHAT COMMAND ]--------
-------------------------------------------------------------

function SS.Commands:New(Index, Price)
	local Table = {}
	
	setmetatable(Table, self)
	self.__index = self
	
	Table.Name = string.lower(Index)
	
	return Table
end

-------------------------------------------------------------
----[ FINALISE CHAT COMMAND ]---------------
-------------------------------------------------------------

function SS.Commands:Create(Function, Restrict, Help, Syntax, Args, Seperator)
	if Syntax == "" then
		Syntax = "<None Specified>"
	end
	
	SS.Commands.Add(self.Name, Function, Help, Restrict, Syntax, Args, Seperator)
end

------------------------------------------------
----[ WHEN PLAYER TALKS ]-----------
------------------------------------------------

function SS.Commands.Say(Player, Text)
	SS.Hooks.Run("PlayerTypeText", Player, Text)
	
	local Command = ""
	local Args    = ""
	
	if (string.sub(Text, 1, 1) == SS.Config.Request("Prefix")) then
		local Find =  string.Explode(" ", Text)[1]
		
		Find = string.sub(Find, 2, string.len(Find) + 1)
		
		for K, V in pairs(SS.Commands.List) do
			if (Find == V.Command) then
				Command = V.Command
				
				Args = string.gsub(Text, SS.Config.Request("Prefix")..V.Command, "", 1)
				
				Args = string.Trim(Args)
			end
		end
		
		if (Command == "") then
			SS.PlayerMessage(Player, 'There is no such command: "'..Find..'"!', 1)
			
			return ""
		end
	end
	
	if (Command != "") then
		if (SS.Commands.List[Command].Func) then
			if (SS.Flags.PlayerHas(Player, SS.Commands.List[Command].Restrict)) then
				local Arguements = {}
				
				if (Args != "") then
					Arguements = string.Explode(SS.Commands.List[Command].Seperator, Args)
				
					for K, V in pairs(Arguements) do
						Arguements[K] = string.Trim(V)
						
						if (SS.Lib.StringNumber(Arguements[K])) then
							Arguements[K] = SS.Lib.StringNumber(Arguements[K])
						end
					end
				end
				
				if (table.Count(Arguements) < SS.Commands.List[Command].Args) then
					Player:PrintMessage(3, "Syntax: "..SS.Commands.List[Command].Syntax)
					
					return ""
				end
				
				SS.Hooks.Run("PlayerTypedCommand", Player, Command, Arguements)
				
				local B, Retval = pcall(SS.Commands.List[Command].Func, Player, Arguements)
				
				if not (B) then
					SS.Lib.Error("Chat Command Error: "..tostring(Retval).."!")
				end
				
				return ""
			else
				local Access = {}
				
				for K, V in pairs(SS.Commands.List[Command].Restrict) do
					if not (SS.Flags.PlayerHas(Player, V)) then
						table.insert(Access, V)
					end
				end
				
				Access = table.concat(Access, " or ")
				
				SS.PlayerMessage(Player, "You do not have access, you need "..Access.." flags.", 1)
				
				return ""
			end
		end
	end
	
	SS.Hooks.Run("PlayerTypedText", Player, Text)
	
	local Return = Player:GetTextReturn()
	
	if (Return) then
		Return = Return[1]
		
		TVAR.Update(Player, "TextReturnValue", nil)
		
		return Return
	end
end

hook.Add("PlayerSay", "SS.Commands.Say", SS.Commands.Say)

------------------------------------------------
----[ ADD NEW COMMAND ]-----------
------------------------------------------------

function SS.Commands.Add(Command, Function, Help, Restrict, Syntax, Args, Seperator)
	SS.Commands.List[Command]           = {}
	SS.Commands.List[Command].Command   = Command
	SS.Commands.List[Command].Func      = Function
	SS.Commands.List[Command].Restrict  = Restrict  or {"basic"}
	SS.Commands.List[Command].Help      = Help      or "<None Specified>"
	SS.Commands.List[Command].Syntax    = Syntax    or "<None Specified>"
	SS.Commands.List[Command].Seperator = Seperator or " "
	SS.Commands.List[Command].Args      = Args 		or 0
	
	SS.ConsoleCommand.Add(Command, Function, Restrict, Syntax, Args, Seperator)
end

--------[ GET COMMANDS PREFIX ]----------

function SS.Commands.Prefix()
	return SS.Config.Request("Prefix")
end