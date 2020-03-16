-------------------------------------------------------------
----[ CONSOLE COMMANDS ]----------------------
-------------------------------------------------------------

// Artificial

SS.ConsoleCommand      = {}
SS.ConsoleCommand.List = {}

// Thanks to foszor for this code

local function Create()
	local Artificial = {}
	
	local Entity = ents.Create("info_target")
	
	Entity:SetPos(Vector(0, 0, 0))
	
	Entity:SetName("Console")
	
	Entity:Spawn()
	
	Artificial.AddCleanup = function() end
	Artificial.AddCount = function() end
	Artificial.AddDeaths = function() end
	Artificial.AddFrags = function() end
	Artificial.AddFrozenPhysicsObject = function() end
	Artificial.Alive = function() return true end
	Artificial.AllowImmediateDecalPainting = function() return end
	Artificial.Armor = function() return 100 end
	Artificial.AttackDisable = function() end
	Artificial.AttackEnable = function() end
	Artificial.ChatPrint = function(Me, Text) Msg(Text.."\n") end
	Artificial.ConCommand = function(Me, Command) game.ConsoleCommand(Command) end
	Artificial.CreateRagdoll = function() end
	Artificial.CrosshairDisable = function() end
	Artificial.CrosshairEnable = function() end
	Artificial.Crouching = function() return false end
	Artificial.Deaths = function() return 0 end
	Artificial.DebugInfo = function() return "I am the Console!" end
	Artificial.DetonateTripmines = function() end
	Artificial.DrawViewModel = function() end
	Artificial.DrawWorldModel = function() end
	Artificial.EnterVehicle = function() end
	Artificial.EquipSuit = function() end
	Artificial.ExitVehicle = function() end
	Artificial.Flashlight = function() end
	Artificial.Frags = function() return 0 end
	Artificial.Freeze = function() end
	Artificial.GetActiveWeapon = function() return "Command Line" end
	Artificial.GetAimVector = function() return Vector(0, 0, 0) end
	Artificial.GetAmmoCount = function() return 0 end
	Artificial.GetClientsideVehicle = function() end
	Artificial.GetCount = function() return 0 end
	Artificial.GetCurrentCommand = function() return "Console" end
	Artificial.GetCursorAimVector = function() return Vector(0, 0, 0) end
	Artificial.GetEyeTrace = function() end
	Artificial.GetFOV = function() end
	Artificial.GetInfo = function() end
	Artificial.GetName = function() return "Console" end
	Artificial.GetScriptedVehicle = function() end
	Artificial.GetShootPos = function() return Vector(0, 0, 0) end
	Artificial.GetVehicle = function() end
	Artificial.GetViewEntity = function() end
	Artificial.GetViewModel = function() end
	Artificial.GetWeapon = function() end
	Artificial.Give = function() end
	Artificial.GiveAmmo = function() end
	Artificial.GodDisable = function() end
	Artificial.GodEnable = function() end
	Artificial.HasWeapon = function() return false end
	Artificial.InVehicle = function() return false end
	Artificial.IPAddress = function() return "127.0.0.1" end
	Artificial.IsAdmin = function() return true end
	Artificial.IsConnected = function() return true end
	Artificial.IsListenServerHost = function() return false end
	Artificial.IsNPC = function() return false end
	Artificial.IsPlayer = function() return false end
	Artificial.IsSuperAdmin = function() return true end
	Artificial.IsUserGroup = function() return false end
	Artificial.IsVehicle = function() return false end
	Artificial.IsWeapon = function() return false end
	Artificial.KeyDown = function() return false end
	Artificial.KeyDownLast = function() return false end
	Artificial.KeyPressed = function() return false end
	Artificial.KeyReleased = function() return false end
	Artificial.Kill = function() end
	Artificial.KillSilent = function() end
	Artificial.LagCompensation = function() end
	Artificial.LastHitGroup = function() end
	Artificial.LimitHit = function() return true end
	Artificial.Lock = function() end
	Artificial.MuzzleFlash = function() end
	Artificial.Name = function() return "Console" end
	Artificial.Nick = function() return "Console" end
	Artificial.PacketLoss = function() end
	Artificial.Ping = function() return "-1" end
	Artificial.PreferredModel = function() return "Alyx" end
	Artificial.PrintMessage = function(Me, Type, Text) Msg("[SS] "..Text.."\n") end
	Artificial.RemoveAmmo = function() end
	Artificial.ScreenText = function(Me, Text) Msg("[SS] "..Text.."\n") end
	Artificial.SelectWeapon = function() end
	Artificial.SendHint = function() end
	Artificial.SendLua = function() end
	Artificial.SetAnimation = function() end
	Artificial.SetArmor = function() end
	Artificial.SetChaseCamDistance = function() end
	Artificial.SetClientsideVehicle = function() end
	Artificial.SetDeaths = function() end
	Artificial.SetDeathTime = function() end
	Artificial.SetEyeAngles = function() end
	Artificial.SetFOV = function() end
	Artificial.SetFrags = function() end
	Artificial.SetMaxSpeed = function() end
	Artificial.SetNoTarget = function() end
	Artificial.SetScriptedVehicle = function() end
	Artificial.SetSuppressPickupNotices = function() end
	Artificial.SetTeam = function() end
	Artificial.SetUserGroup = function() end
	Artificial.SetViewEntity = function() end
	Artificial.ShouldDropWeapon = function() end
	Artificial.SnapEyeAngles = function() end
	Artificial.Spectate = function() end
	Artificial.SpectateEntity = function() end
	Artificial.SprintDisable = function() end
	Artificial.SprintEnable = function() end
	Artificial.SteamID = function() return "Console" end
	Artificial.StopZooming = function() end
	Artificial.StripAmmo = function() end
	Artificial.StripWeapon = function() end
	Artificial.StripWeapons = function() end
	Artificial.SuppressHint = function() end
	Artificial.TakeDamage = function() end
	Artificial.Team = function() return "Console" end
	Artificial.TimeConnected = function() return CurTime() end
	Artificial.UnfreezePhysicsObjects = function() end
	Artificial.UniqueID = function() return "Console" end
	Artificial.UnLock = function() end
	Artificial.UnSpectate = function() end
	Artificial.UserID = function() end
	Artificial.IsValid = function() return true end
	Artificial.IsPlayer = function() return false end
	Artificial.ViewPunch = function() end
	Artificial.IsReady = function() return true end
	
	local Meta = FindMetaTable("Player")
	
	local Copy = table.Copy(Meta)
	
	setmetatable(Artificial, Copy)
	
	Entity:SetTable(Artificial)
	
	return Entity
end

// Backup

local Backup = concommand.Add

// Redefine

function concommand.Add(ID, Func, Autocomplete)
	local function Function(Player, Command, Args)
		local Using = Player
		
		if not (SS.Lib.Valid(Player)) then Using = SS.ConsoleCommand.Console end
		
		Func(Using, Command, Args)
	end
	
	Backup(ID, Function, Autocomplete)
end

SS.ConsoleCommand.Console = Create()

// Core

function SS.ConsoleCommand.Core(Player, Command, Args)
	if not (Args) or not (Args[1]) then SS.PlayerMessage(Player, "Please enter a valid command!", 1) return end
	
	for K, V in pairs(SS.ConsoleCommand.List) do
		if (string.lower(Args[1]) == string.lower(V.Command)) then
			if (SS.Flags.PlayerHas(Player, V.Restrict)) then
				table.remove(Args, 1)
				
				Args = table.concat(Args, " ")
				
				Args = string.Explode(V.Seperator, Args)
				
				for K, V in pairs(Args) do
					Args[K] = string.Trim(V)
					
					if (tonumber(Args[K])) then
						Args[K] = tonumber(Args[K])
					end
					
					if (Args[K] == "") then
						Args[K] = nil
					end
				end
				
				if (table.Count(Args) < V.Args) then
					Player:PrintMessage(3, "Syntax: "..V.Syntax)
				else
					local B, Retval = pcall(V.Func, Player, Args)
					
 					if not B then
						SS.Lib.Error("Console Command Error: "..tostring(Retval).."!")
					end
					
					SS.Hooks.Run("PlayerTypedCommand", Player, V.Command, Args)
				end
			else
				local Access = {}
				
				for B, J in pairs(V.Restrict) do
					if not (SS.Flags.PlayerHas(Player, J)) then
						table.insert(Access, J)
					end
				end
				
				Access = table.concat(Access, " or ")
				
				SS.PlayerMessage(Player, "You do not have access, you need "..Access.." flags", 1)
			end
			
			return
		end
	end
	
	SS.PlayerMessage(Player, 'There is no such command: "'..Args[1]..'"!', 1)
end

concommand.Add("ss", SS.ConsoleCommand.Core)

// Add

function SS.ConsoleCommand.Add(Command, Function, Restrict, Syntax, Args, Seperator)
	SS.ConsoleCommand.List[Command]           = {}
	SS.ConsoleCommand.List[Command].Command   = Command
	SS.ConsoleCommand.List[Command].Func      = Function
	SS.ConsoleCommand.List[Command].Restrict  = Restrict  or {"basic"}
	SS.ConsoleCommand.List[Command].Syntax    = Syntax    or "<None Specified>"
	SS.ConsoleCommand.List[Command].Args      = Args 	  or 0
	SS.ConsoleCommand.List[Command].Seperator = Seperator or " "
end

// Simple

function SS.ConsoleCommand.Simple(Command, Function, Args)
	SS.ConsoleCommand.Add(Command, Function, nil, "<This should be done automatically>", Args, nil)
end