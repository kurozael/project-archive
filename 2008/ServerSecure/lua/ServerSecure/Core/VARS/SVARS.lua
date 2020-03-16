SVAR 	   = {} -- SVAR table
SVAR.Store = {} -- Where SVARS are stored

// New SVAR

function SVAR.New(Index, Value)
	local Index = string.lower(Index)
	
	SVAR.Store[Index] = SVAR.Store[Index] or Value
end

// Get an SVAR

function SVAR.Request(Index)
	Index = string.lower(Index)
	
	if (tonumber(SVAR.Store[Index])) then
		SVAR.Store[Index] = tonumber(SVAR.Store[Index])
	end
	
	return SVAR.Store[Index]
end

// Update an SVAR

function SVAR.Update(Index, Value)
	Index = string.lower(Index)
	
	SVAR.Store[Index] = Value
end

// Save SVARS

function SVAR.Save()
	local Contents = util.TableToKeyValues(SVAR.Store)
	
	file.Write("SS/SVARS/SVARS.txt", Contents)
end

// Load SVARS

function SVAR.Load()
	if file.Exists("SS/SVARS/SVARS.txt") then
		local File = file.Read("SS/SVARS/SVARS.txt")
		
		if File then
			SVAR.Store = util.KeyValuesToTable(File)
		end
	end
end

SVAR.Load()