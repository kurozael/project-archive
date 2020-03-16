local Radar = {}

// Config

Radar.Settings = {}

Radar.Custom = {}

Radar.Settings.W = 128

Radar.Settings.H = 128

Radar.Settings.Color = Color(50, 50, 50, 200)

Radar.Settings.Distance = 4120

// Locals

local User = LocalPlayer()

// ConVars

CreateClientConVar("ss_showradar", 0, true, true)

// Draw

function Radar.Point(Table, X, Y)
	for K, V in pairs(Table) do
		if (V:IsValid()) then
			if not (V:IsPlayer()) or (V:GetNetworkedInt("HideInformation") != 1) then
				local ID = "None"
				
				if (V:IsPlayer()) then
					ID = V:Name()
				else
					ID = V.ID
				end
				
				local PX = X + (Radar.Settings.W / 2)
				
				local PY = Y + (Radar.Settings.H / 2)
				
				local Using = User:GetPos()
				
				if (User:GetControllingEntity():IsValid()) then
					Using = User:GetControllingEntity():GetPos()
				end
				
				local Dist = V:GetPos() - Using
				
				if (V:IsPlayer()) then
					if (V:GetControllingEntity():IsValid()) then
						Dist = V:GetControllingEntity():GetPos() - Using
					end
				end
				
				--[ Clever maths stuff mostly by GCDesign ]--
				
				if not (V:IsPlayer()) or (V:Alive()) then
					if (User != V) then
						if (Dist:Length() < Radar.Settings.Distance) then
							local NX = (Dist.x / Radar.Settings.Distance)
							local NY = (Dist.y / Radar.Settings.Distance)
							
							local Z = math.sqrt(NX * NX + NY * NY)
							
							local Something = math.Deg2Rad(math.Rad2Deg(math.atan2(NX, NY) ) - math.Rad2Deg(math.atan2(User:GetAimVector().x, User:GetAimVector().y)) - 90)
							
							NX = math.cos(Something) * Z
							NY = math.sin(Something) * Z
							
							local Col = Color(255, 255, 255, 255)
							
							local Player = V:IsPlayer()
							
							if (Player) then
								local Side = V:Team()
								
								Col = team.GetColor(Side)
							else
								local R, G, B, A = V:GetColor()
								
								Col = Color(R, G, B, A)
							end
							
							local X = PX + NX * Radar.Settings.W / 2 - 4
							local Y = PY + NY * Radar.Settings.H / 2 - 4
							
							draw.SimpleText(ID, "Default", X, Y + 16, Color(255, 255, 255, 255), 1, 1)
							
							draw.RoundedBox(0, X, Y, 4, 4, Col)
						end
					end
				end
			end
		else
			Radar.Custom[K] = nil
		end
	end
end

// Code

function Radar.Draw()
	if (GetConVarNumber("ss_showradar") == 0) then return end
	
	local X = (ScrW() - Radar.Settings.W) - 16
	
	local Y = 48
	
	if (SS.ServerTicker.Enabled) then
		Y = Y + SS.ServerTicker.Position
	end
	
	local Side = User:Team()
	
	local Col = team.GetColor(Side)

	local Players = player.GetAll()
	
	SS.GUI.Box(X, Y, Radar.Settings.W, Radar.Settings.H, Radar.Settings.Color, 2, Col)
	
	Radar.Point(Players, X, Y)
	
	Radar.Point(Radar.Custom, X, Y)
end

hook.Add("HUDPaint", "Radar.Draw", Radar.Draw)

// Custom radar

function Radar.Console(Player, Command, Args)
	if (Args == nil) or (Args[1] == nil) then return end
	
	local TR = utilx.GetPlayerTrace(Player, Player:GetCursorAimVector())
	
	local Trace = util.TraceLine(TR)
	
	if (Trace.Entity and Trace.Entity:IsValid()) then
		local Index = Trace.Entity:EntIndex()
		
		Radar.Custom[Index] = Trace.Entity
		
		Trace.Entity.ID = Args[1]
	end
end

concommand.Add("ss_radarentity", Radar.Console)