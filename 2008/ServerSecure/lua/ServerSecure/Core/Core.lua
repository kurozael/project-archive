if SERVER then
	-----[ INCLUDE META TABLE AJUSTMENTS ] -------
	
	include("Meta.lua")
	
	------------------------------------------------
	----[ WHEN PLAYER SPAWNS ]-------
	------------------------------------------------
	
	function SS.Player.PlayerSpawn(Player)
		local Ready = Player:IsReady()
		
		if (Ready) then
			SS.Player.PlayerChooseTeam(Player)
			
			timer.Create("SS.Player.PlayerUpdateGUI: "..Player:UniqueID(), 0.05, 1, SS.Player.PlayerUpdateGUI, Player)
			timer.Create("SS.Player.PlayerSpawnModel: "..Player:UniqueID(), 0.05, 1, SS.Player.PlayerSpawnModel, Player)
			timer.Create("SS.Player.PlayerSpawnWeapons: "..Player:UniqueID(), 0.05, 1, SS.Player.PlayerSpawnWeapons, Player)
		end
		
		SS.Hooks.Run("PlayerSpawn", Player)
	end

	hook.Add("PlayerSpawn", "SS.Player.PlayerSpawn", SS.Player.PlayerSpawn)
	
	------------------------------------------------
	----[ IS PLAYER IMMUNE ]-------------
	------------------------------------------------
	
	function SS.Player.Immune(Player, Person)
		if (SS.Flags.PlayerHas(Person, "immune")) then
			if (SS.Groups.Rank(SS.Player.Rank(Player)) <= SS.Groups.Rank(SS.Player.Rank(Person))) then
				return false
			end
			
			return Person:Name().." is immune to this!"
		end
		
		return false
	end
	
	------------------------------------------------
	----[ ON PLAYER DEATH ]---------------
	------------------------------------------------
	
	function SS.Player.PlayerDeath(Player, Attacker, Damage)
		Player:Freeze(false)
		
		Player:Extinguish()
		
		if (TVAR.Request(Player, "RemoveWhenKilled")) then
			for K, V in pairs(TVAR.Request(Player, "RemoveWhenKilled")) do
				if (V) then
					local Valid = SS.Lib.Valid(V)
					
					if (Valid) then
						V:Remove()
					end
				end
			end
		end
		
		SS.Hooks.Run("PlayerDeath", Player, Attacker, Damage)
	end
	
	hook.Add("DoPlayerDeath", "SS.Player.PlayerDeath", SS.Player.PlayerDeath)
	
	------------------------------------------------
	----[ PLAYER CONNECT ]---------------
	------------------------------------------------
	
	function SS.Player.PlayerConnect(ID, Address, Steam)
		SS.Hooks.Run("PlayerConnect", ID, Address, Steam)
	end
	
	hook.Add("PlayerConnect", "SS.Player.PlayerConnect", SS.Player.PlayerConnect)
	
	------------------------------------------------
	----[ PROP SPAWNED ]------------------
	------------------------------------------------
	
	function SS.Player.PlayerPropSpawned(Player, Model, Entity)
		SS.Hooks.Run("PlayerPropSpawned", Player, Entity)
	end
	
	hook.Add("PlayerSpawnedProp", "SS.Player.PlayerPropSpawned", SS.Player.PlayerPropSpawned)
	
	------------------------------------------------
	----[ KEY PRESSED ]---------------------
	------------------------------------------------
	
	function SS.Player.PlayerKeyPress(Player, Key)
		SS.Hooks.Run("PlayerKeyPress", Player, Key)
	end
	
	hook.Add("KeyPress", "SS.Player.PlayerKeyPress", SS.Player.PlayerKeyPress)
	
	------------------------------------------------
	----[ ON INITIAL SPAWN ]-----------
	------------------------------------------------
	
	function SS.Player.PlayerInitialSpawn(Player, Done)
		if not (Done) then
			timer.Create("SS.Player.PlayerInitialSpawn: "..Player:UniqueID(), 1, 1, SS.Player.PlayerInitialSpawn, Player, true)
			
			return
		end
		
		CVAR.Load(Player) CVAR.Create(Player) SS.Player.PlayerSetVariables(Player)
		
		SS.Hooks.Run("PlayerInitialSpawn", Player) Player:Spawn()
	end
	
	hook.Add("PlayerInitialSpawn", "SS.Player.PlayerInitialSpawn", SS.Player.PlayerInitialSpawn)

	---------------------------------------------------------------
	----[ SET VARIABLES ]---------------------------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerSetVariables(Player)
		SS.Hooks.Run("PlayerSetVariables", Player)
	end
	
	---------------------------------------------------------------
	----[ WHEN THE SERVER SHUTSDOWN ]---------
	---------------------------------------------------------------
	
	function SS.ShutDown()
		SS.Hooks.Run("ServerShutdown") SVAR.Save()
	end
	
	hook.Add("ShutDown", "SS.ShutDown", SS.ShutDown)

	---------------------------------------------------------------
	----[ SET MODEL ]---------------------------------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerSpawnModel(Player)
		if (SS.Config.Request("Group Models")) then
			for K, V in pairs(SS.Groups.List) do
				if (V[1] == SS.Player.Rank(Player)) then
					if (V[4] != "") then
						Player:SetModel(V[4])
					end
				end
			end
		end
		
		SS.Hooks.Run("PlayerChooseModel", Player)
	end

	---------------------------------------------------------------
	----[ GIVE WEAPONS ]---------------------------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerSpawnWeapons(Player)
		local Table = {}
		
		if (SS.Config.Request("Group Weapons")) then
			Player:StripWeapons()
		end
		
		for K, V in pairs(SS.Config.Request("Default Weapons")) do
			Player:Give(V)
			
			table.insert(Table, V)
		end
		
		for K, V in pairs(SS.Groups.List) do
			if (V[1] == SS.Player.Rank(Player)) then
				for B, J in pairs(V[5]) do
					Player:Give(J)
					
					table.insert(Table, J)
				end
			end
		end
		
		SS.Hooks.Run("PlayerGivenWeapons", Player, Table)
	end
	
	---------------------------------------------------------------
	----[ SERVER LOADS ]----------------------------------
	---------------------------------------------------------------
	
	function SS.Initialize()
		if (GAMEMODE) then
			if (GAMEMODE.Name) then
				if (SS.Config.Request("Gamemode Prefix")) then
					GAMEMODE.Name = SS.Config.Request("Gamemode Prefix").." "..GAMEMODE.Name
				end
			end
		end
		
		SVAR.New("Configured", 0 )
		
		SS.Hooks.Run("ServerLoad")
	end
	
	hook.Add("Initialize", "SS.Initialize", SS.Initialize)

	---------------------------------------------------------------
	----[ CHOOSE TEAM ]-----------------------------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerChooseTeam(Player)
		if not (SS.Groups.Exists(SS.Player.Rank(Player))) then
			local Default = SS.Groups.Default()
			
			SS.Groups.Change(Player, Default)
		end
		
		for K, V in pairs(SS.Groups.List) do
			if (SS.Player.Rank(Player) == V[1]) then
				Player:SetTeam(V[2])
			end
		end
		
		SS.Hooks.Run("PlayerChooseTeam", Player)
	end

	---------------------------------------------------------------
	----[ SEND ALERT ]--------------------------------------
	---------------------------------------------------------------
	
	function SS.PlayerMessage(Player, Text, Type)
		local Cur = CurTime()
		
		if not (Text) then return end
		
		Type = Type or 0
		
		if (string.len(Text) > 100) then
			Text = string.sub(Text, 0, 100)
			
			Text = Text.."..."
		end
		
		if (type(Player) != "number") then
			if (Player:GetName() == "Console") then
				Player:ChatPrint(Text)
			else
				TVAR.New(Player, "SS.PlayerMessage", Cur)
				
				if (TVAR.Request(Player, "SS.PlayerMessage") <= Cur) then
					umsg.Start("SS.PlayerMessage", Player)
						umsg.Short(Type)
						umsg.String(Text)
					umsg.End()
					
					TVAR.Update(Player, "SS.PlayerMessage", Cur + 1)
				else
					Player:PrintMessage(3, Text)
				end
				
				Player:PrintMessage(2, Text.."\n")
			end
		else
			local Players = player.GetAll()
			
			for K, V in pairs(Players) do
				SS.PlayerMessage(V, Text, Type)
			end
			
			Msg(Text.."\n")
			
			SS.Hooks.Run("ServerMessage", Text)
		end
	end
	
	---------------------------------------------------------------
	----[ TICKER ]---------------------------------------------
	---------------------------------------------------------------
	
	function SS.ServerTicker(Player, Message, Time)
		if (Player == 0) then
			local Players = player.GetAll()
			
			for K, V in pairs(Players) do
				SS.ServerTicker(V, Message, Time)
			end
			
			Msg(Message.."\n")
		else
			if (Player:GetName() == "Console") then
				Player:ChatPrint(Message)
			else
				umsg.Start("SS.ServerTicker", Player)
					umsg.String(Message)
					umsg.Short(Time)
				umsg.End()
				
				Player:PrintMessage(2, Message)
			end
		end
	end
	
	---------------------------------------------------------------
	----[ CHECK RANK ]--------------------------------------
	---------------------------------------------------------------
	
	function SS.Player.Rank(Player)
		if (Player and Player:IsPlayer() and Player:GetName() != "Console") then
			for K, V in pairs(SS.Groups.Loaded) do
				if (string.lower(Player:SteamID()) == string.lower(K)) then
					return V
				end
			end
		else
			return SS.Groups.ID(1)
		end
		
		return SS.Groups.Default()
	end

	---------------------------------------------------------------
	----[ MAIN MINUTES FUNCTION ]-----------------
	---------------------------------------------------------------
	
	function SS.Minutes()
		SS.Hooks.Run("ServerMinute")
	end

	timer.Create("SS.Minutes", 60, 0, SS.Minutes)
	
	---------------------------------------------------------------
	----[ MAIN THINK FUNCTION ]--------------------
	---------------------------------------------------------------
	
	function SS.Think()
		local Cur = CurTime()
		
		SS.Tick = SS.Tick or 0
		
		if (SS.Tick <= Cur) then
			SS.Tick = Cur + 1
			
			SS.Hooks.Run("ServerSecond")
		end
		
		SS.Hooks.Run("ServerThink")
	end
	
	hook.Add("Think", "SS.Think", SS.Think)
	
	---------------------------------------------------------------
	----[ UPDATE GUI ]--------------------------------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerUpdateGUI(Player)
		if not (Player:IsReady()) then return end
		
		Player:SetNetworkedString("Group", "Group: "..SS.Player.Rank(Player))
		
		SS.Hooks.Run("PlayerUpdateGUI", Player)
	end

	---------------------------------------------------------------
	----[ WHEN PLAYER DISCONNECTS ]-------------
	---------------------------------------------------------------
	
	function SS.Player.PlayerDisconnect(Player)
		SS.Hooks.Run("PlayerDisconnect", Player)
		
		CVAR.Save(Player)
	end

	hook.Add("PlayerDisconnected", "SS.Player.PlayerDisconnect", SS.Player.PlayerDisconnect)
	
	---------------------------------------------------------------
	----[ OVERRIDING SWEP SPAWNING ]-----------
	---------------------------------------------------------------
	
	function SS.Player.GiveSWEP(Player, Command, Args)
		if (Args[1] == nil) then return end

		local SWEP = weapons.GetStored(Args[1])
		
		if (SWEP == nil) then return end
		
		if (SS.Config.Request("SWEPS Flag")) then
			if not (SS.Flags.PlayerHas(Player, "sweps")) then
				SS.PlayerMessage(Player, "You need the 'sweps' flag to spawn this weapon!", 1)
				
				return
			end
		else
			if (!SWEP.Spawnable && !Player:IsAdmin()) then
				SS.PlayerMessage(Player, "You need to be an admin to spawn this weapon!", 1)
				
				return
			end
		end
		
		Player:Give(SWEP.Classname)
	end
	
	--[ OVERRIDE COMMAND ]-
	
	function SS.Player.OverrideSWEP()
		concommand.Add("gm_giveswep", SS.Player.GiveSWEP)
	end
	
	SS.Hooks.Add("SS.Player.OverrideSWEP", "ServerLoad", SS.Player.OverrideSWEP)
end