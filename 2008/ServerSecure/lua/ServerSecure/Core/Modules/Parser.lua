------------------------------------------------
----[ PARSER ]-----------------------------
------------------------------------------------

// Majority of script learned from aVoN's INI parser

SS.Parser = {} -- Parser

// Load

function SS.Parser:New(File)
	local Table = {}
	
	setmetatable(Table, self)
	
	self.__index = self
	
	Table.File    = file.Read("../"..File..".ini")
	Table.Results = {}

	return Table
end

// Check

function SS.Parser:Exists()
	if not (self.File) or (self.File == "") then
		return false
	end
	
	return true
end

// Strip comments

function SS.Parser:Comments(Line)
	local Find = string.find(Line, "#")
	
	if (Find) then
		Line = string.sub(Line, 1, Find - 1)
	end
	
	return Line
end

// Strip quotes

function SS.Parser:Quotes(Line)
	return string.gsub(Line, "^[\"'](.+)[\"']$", "%1")
end

// Debug

function SS.Parser:Debug(Message)
	MsgAll("SS [INI Parser] - "..Message.."\n")
end

// Change

function SS.Parser:Change(String)
	if (tonumber(String)) then
		return tonumber(String)
	end
	
	if (string.lower(String) == "true") then
		return true
	end
	
	if (string.lower(String) == "false") then
		return false
	end
	
	return String
end

// Information from section

function SS.Parser:Info(Section, Key)
	local Results = self:Parse()
	
	for K, V in pairs(Results) do
		if (K == Section) then
			for B, J in pairs(V) do
				if (B == Key) then
					return J
				end
			end
		end
	end
	
	return ""
end

// Get a section

function SS.Parser:Section(Section)
	local Results = self:Parse()
	
	for K, V in pairs(Results) do
		if (K == Section) then
			return V
		end
	end
	
	return {}
end

// Get information

function SS.Parser:Parse()
	local Current = ""
	
	local Explode = string.Explode("\n", self.File)
	
	for K, V in pairs(Explode) do
		local Line = string.Trim(self:Comments(V))
		
		if (Line != "") then
			if (string.sub(Line, 1, 1) == "[") then
				local End = string.find(Line, "%]")
				
				if (End) then
					local Block = string.sub(Line, 2, End - 1)
					
					self.Results[Block] = self.Results[Block] or {}
					
					Current = Block
				end
			else
				self.Results[Current] = self.Results[Current] or {}
				
				if (Current != "") then
					local Data = string.Explode("=", Line)
					
					if (table.Count(Data) == 2) then
						local Key   = self:Quotes(string.Trim(Data[1]))
						local Value = self:Quotes(string.Trim(Data[2]))
						
						Value = self:Change(Value)
						
						self.Results[Current][Key] = Value
					else
						if (table.Count(Data) == 1) then
							Value = self:Quotes(string.Trim(Line))
							
							Value = self:Change(Value)
							
							table.insert(self.Results[Current], Value)
						end
					end
				end
			end
		end
	end
	
	return self.Results
end