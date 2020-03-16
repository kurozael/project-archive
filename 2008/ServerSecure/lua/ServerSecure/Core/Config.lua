---------------------------------------------------------------
----[ GROUPS ]--------------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Groups")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		local Group = SS.Groups:New(K)
		
		for B, J in pairs(V) do
			if (B == "Color") then
				local Col = SS.Lib.StringColor(J)
				
				Group:Color(unpack(Col))
			elseif (B == "Model") then
				Group:Model(J)
			elseif (B == "Flags") then
				local Explode = SS.Lib.StringExplode(J, ", ")
				
				Group:Flags(unpack(Explode))
			elseif (B == "Weapons") then
				local Explode = SS.Lib.StringExplode(J, ", ")
				
				Group:Weapons(unpack(Explode))
			elseif (B == "Default") then
				Group:Starting()
			elseif (B == "Rank") then
				Group:Position(J)
			end
		end
		
		Group:Create()
	end
end

---------------------------------------------------------------
----[ FLAGS ]-----------------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Flags")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Flags.Branch(K, J)
		end
	end
end

---------------------------------------------------------------
----[SETTINGS ]-----------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Autoexec")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Lib.ConCommand(B, J)
		end
	end
end

---------------------------------------------------------------
----[ GENERAL ]------------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/General")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			if (type(J) == "string") then
				local Explode = SS.Lib.StringExplode(J, ", ")
				
				SS.Config.New(B, unpack(Explode))
			else
				SS.Config.New(B, J)
			end
		end
	end
end

---------------------------------------------------------------
----[ BAN LIST ]-----------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Bans")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	Msg("\n")
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Ban.Add(B, J)
		end
	end
end

---------------------------------------------------------------
----[ ADVERTS ]------------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Adverts")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Adverts.Add(J)
		end
	end
end

---------------------------------------------------------------
----[ RULES ]----------------------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Rules")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Rules.Add(J)
		end
	end
end

---------------------------------------------------------------
----[ PROMOTIONS ]-----------------------------------
---------------------------------------------------------------

local Parse = SS.Parser:New("lua/ServerSecure/Config/Promotions")

if (Parse:Exists()) then
	local Results = Parse:Parse()
	
	for K, V in pairs(Results) do
		for B, J in pairs(V) do
			SS.Promotion.Add(B, J)
		end
	end
end