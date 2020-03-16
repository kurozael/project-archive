SS.Lib = {} -- Library table

// Error message

function SS.Lib.Error(ID)
	local Message = string.upper("ERROR: "..ID)
	
	Msg("\n\n")
	
	Msg(Message.."\n")
	
	Msg("\n\n")
end

// Debug message

function SS.Lib.Debug(Message)
	if (SS.Config.Request("Debug")) then
		Msg("[SS] Debug: "..Message.."\n")
	end
end

// Format

function SS.Lib.StringValue(String)
	local Type = type(String)
	
	if not (Type == "string") then return String end
	
	local Number = tonumber(String)
	
	if (Number) then return Number end
	
	if (string.lower(String) == "false") then return false end
	
	if (string.lower(String) == "true") then return true end
	
	return String
end

// Smoke trail

function SS.Lib.CreateSmokeTrail(Entity, Col)
	local Table = {"sprites/firetrail.spr", "sprites/whitepuff.spr"}
	
	local Smoke = ents.Create("env_smoketrail")
	
	Smoke:SetKeyValue("opacity", 1)
	Smoke:SetKeyValue("spawnrate", 25)
	Smoke:SetKeyValue("lifetime", 2)
	Smoke:SetKeyValue("startcolor", Col[1])
	Smoke:SetKeyValue("endcolor", Col[2])
	Smoke:SetKeyValue("minspeed", 15)
	Smoke:SetKeyValue("maxspeed", 30)
	Smoke:SetKeyValue("startsize", (Entity:BoundingRadius() / 2))
	Smoke:SetKeyValue("endsize", Entity:BoundingRadius())
	Smoke:SetKeyValue("spawnradius", 10)
	Smoke:SetKeyValue("emittime", 300)
	Smoke:SetKeyValue("firesprite", Table[1])
	Smoke:SetKeyValue("smokesprite", Table[2])
	Smoke:SetPos(Entity:GetPos())
	Smoke:SetParent(Entity)
	Smoke:Spawn()
	Smoke:Activate()
	
	Entity:DeleteOnRemove(Smoke)
	
	return Smoke
end

// Boolean value

function SS.Lib.StringBoolean(String)
	local Bool = true
	
	if (string.lower(String) == "false") or (String == 0) then
		Bool = false
	end
	
	return Bool
end

// Needed for votes etc

function SS.Lib.VotesNeeded(Number)
	local Fraction = SS.Lib.PlayersConnected() - (SS.Lib.PlayersConnected() / 4)
	
	Fraction = math.floor(Fraction)
	
	Fraction = math.max(Fraction, 0)
	
	if (Number < Fraction) then
		return false, Fraction
	end
	
	return true, Fraction
end

// Random string

function SS.Lib.StringRandom(Characters)
	local String = ""
	
	for I = 1, Characters do
		String = String..string.char(math.random(48, 90))
	end
	
	String = string.upper(String)
	
	return String
end

// Modified string.Replace

function SS.Lib.StringReplace(String, Find, Replace, Amount)
	local Start = 1
	
	local Done = 0
	
	Amount = Amount or 0
	
	while (true) do
		local Pos = string.find(String, Find, Start, true)
	
		if (Pos == nil) then
			break
		end
		
		if (Done == Amount and Amount != 0) then
			break
		end
		
		local L = string.sub(String, 1, Pos - 1)
		local R = string.sub(String, Pos + #Find)
		
		String = L..Replace..R
		
		Start = Pos + #Replace
		
		Done = Done + 1
	end
	
	return String
end

// Chop string

function SS.Lib.StringChop(String, Amount)
	local Pieces  = {}
	
	local Current = 0
	
	while (string.len(String) > Amount) do
		local Text = string.sub(String, Current, Amount)
		
		table.insert(Pieces, Text)
		
		String = string.sub(String, Amount)
	end
	
	return Pieces
end

// Blowup

function SS.Lib.EntityExplode(Entity)
	local Effect = EffectData()
	
	Effect:SetOrigin(Entity:GetPos())
	Effect:SetScale(1)
	Effect:SetMagnitude(25)
	
	util.Effect("Explosion", Effect, true, true)

	if (Entity:IsPlayer()) then
		Entity:Kill()
	else
		Entity:Remove()
	end
end

// Explode string

function SS.Lib.StringExplode(String, Seperator)
	local Table = string.Explode(Seperator, String)
	
	for K, V in pairs(Table) do
		Table[K] = string.Trim(V)
		
		if (V == "") then
			Table[K] = nil
		end
	end
	
	return Table
end

// To number

function SS.Lib.StringNumber(String)
	return tonumber(String)
end

// Get string color like 255, 255, 255, 255

function SS.Lib.StringColor(String, Bool)
	local Explode = SS.Lib.StringExplode(String, ", ")
	
	local R = tonumber(Explode[1]) or 0
	local G = tonumber(Explode[2]) or 0
	local B = tonumber(Explode[3]) or 0
	local A = tonumber(Explode[4]) or 0
	
	if not (Bool) then
		return {R, G, B, A}
	else
		return Color(R, G, B, A)
	end
end

// Players connected

function SS.Lib.PlayersConnected()
	local Players = player.GetAll()
	
	return table.Count(Players)
end

// Random table entry

function SS.Lib.RandomTableEntry(Table)
	local Max = math.random(1, table.getn(Table))
	
	return Table[Max]
end

// Find matching player

function SS.Lib.Find(String)
	String = string.lower(String)
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local ID = V:Name()
		
		ID = string.lower(ID)
		
		if (string.find(ID, String)) then
			return V, "Match found for "..String.."!"
		end
	end
	
	return false, "There was no matches for "..String.."!"
end

// Add all custom content in a folder

function SS.Lib.AddCustomContent(Folder)
	local Files = file.Find("../"..Folder.."*")
	
	if (Files) then
		for K, V in pairs(Files) do
			if (file.IsDir("../"..Folder..V.."/")) then
				SS.Lib.AddCustomContent(Folder..V.."/")
			else
				if (V != "." and V != "..") then
					resource.AddFile(Folder..V)
				end
			end
		end
	end
end

// Include all files in a folder and include

function SS.Lib.FileInclude(Folder, Extension)
	local Files = file.Find("../lua/"..Folder.."*"..Extension)
	
	Msg("\n")
	
	for K, V in pairs(Files) do
		include(Folder..V)
		
		Msg("\n\t[Generic] File - "..V.." loaded")
	end
	
	Msg("\n")
end

// Find all files in folders in a folder and include

function SS.Lib.FolderSearch(Folder, Extension)
	local Files = file.Find("../lua/"..Folder.."*")
	
	Msg("\n")
	
	for K, V in pairs(Files) do
		local Friendly = V
		
		V = V.."/"
		
		if (file.IsDir("../lua/"..Folder..V)) then
			local Temp = file.Find("../lua/"..Folder..V.."*"..Extension)
			
			for B, J in pairs(Temp) do
				include(Folder..V..J)
				
				Msg("\n\t["..Friendly.."] File - "..J.." loaded")
			end
		end
	end
end

// Execute serverside console command

function SS.Lib.ConCommand(Key, ...)
	local Table = {}
	
	if (arg) then
		for I = 1, table.getn(arg) do
			Table[I] = arg[I]
		end
	end
	
	local Value = table.concat(Table, " ")
	
	game.ConsoleCommand(Key..' '..Value..'\n')
end

// Kick a player

function SS.Lib.PlayerKick(Player, Reason)	
	local Steam = Player:SteamID()
	
	SS.Lib.ConCommand("kickid", Steam, Reason)
end

// Ban player

function SS.Lib.PlayerBan(Player, Time, Reason)
	Reason = Reason or "<None Specified>"
	
	// Run hook before banned
	
	SS.Hooks.Run("PlayerBanned", Player, Time, Reason)
	
	// Send ban GUI
	
	local Steam = Player:SteamID()
	
	SS.Lib.ConCommand("banid", Time, Steam)
	
	umsg.Start("SS.Ban", Player)
	umsg.String(Reason)
	umsg.Short(Time)
	umsg.End()
	
	timer.Simple(10, SS.Lib.ConCommand, "kickid", Steam, "Banned")
	timer.Simple(10, SS.Lib.ConCommand, "writeid")
	
	// Freeze them
	
	Player:Freeze(true)
end

// Slay player

function SS.Lib.PlayerSlay(Player)
	Player:Kill()
end

// Freeze player

function SS.Lib.PlayerFreeze(Player, Bool)
	if (Bool) then
		Player:Freeze(true)
	else
		Player:Freeze(false)
	end
end

// Blind player

function SS.Lib.PlayerBlind(Player, Bool)
	umsg.Start("SS.Blind", Player) umsg.Bool(Bool) umsg.End()
end

// God player

function SS.Lib.PlayerGod(Player, Bool)
	if (Bool) then
		Player:GodEnable()
	else
		Player:GodDisable()
	end
end

// Invis player

function SS.Lib.PlayerInvis(Player, Bool)
	Player:HideGUI("Hover", Bool)
	Player:HideGUI("Name", Bool)
	
	if not (Bool) then
		Player:SetMaterial("")
	else
		Player:SetMaterial("sprites/heatwave")
	end
end

// Valid entity

function SS.Lib.Valid(Entity)
	if not (Entity) then return false end
	
	local Valid = Entity:IsValid()
	
	if (Valid) then
		return true
	end
	
	return false
end