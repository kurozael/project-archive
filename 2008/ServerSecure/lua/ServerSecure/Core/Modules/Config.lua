------------------------------------------------
----[ CONFIG ]-----------------------------
------------------------------------------------

SS.Config = {}

SS.Config.List = {}

// New

function SS.Config.New(ID, ...)
	if arg[2] then
		local Table = {}
		
		for I = 1, table.getn(arg) do	
			Table[I] = arg[I]
		end
		
		SS.Config.List[ID] = Table
	else
		SetGlobalString("SS: "..ID, arg[1])
		
		SS.Config.List[ID] = arg[1]
	end
end

// Request

function SS.Config.Request(ID)
	return SS.Config.List[ID]
end