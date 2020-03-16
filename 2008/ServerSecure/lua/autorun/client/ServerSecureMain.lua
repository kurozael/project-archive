------------------------------------------------
----[ VARIABLES ]------------------------
------------------------------------------------

SS      = {}
SS.Draw = {}

// Fonts

surface.CreateFont("Verdana", 15, 600, true, false, "ServerSecureVerdana")
surface.CreateFont("Arial", 15, 600, true, false, "ServerSecureArial")
surface.CreateFont("coolvetica", 70, 500, true, false, "ServerSecureCoolvetica")

// GUI

SS.GUI       = {}
SS.GUI.Panel = {}
SS.GUI.Font  = "ServerSecureVerdana"

// Teams

SS.Groups      = {}
SS.Groups.List = {}

// Ticker

SS.ServerTicker          = {}
SS.ServerTicker.Fade     = false
SS.ServerTicker.Enabled  = false
SS.ServerTicker.Text     = ""
SS.ServerTicker.Time     = 0
SS.ServerTicker.Position = 0

// Parts

SS.Part      = {} -- Bar table.
SS.Part.List = {} -- Top bar.

// Config

SS.Config = {}

function SS.Config.Request(ID)
	return GetGlobalString("SS: "..ID)
end

// Locals

local User = LocalPlayer()

// Hook ticket

function SS.ServerTicker.Hook(Message)
	local Text = Message:ReadString()
	local Time = Message:ReadShort()
	
	SS.ServerTicker.Text     = Text
	SS.ServerTicker.Time     = CurTime()
	SS.ServerTicker.Enabled  = true
	SS.ServerTicker.Fade     = false
	SS.ServerTicker.Position = 0
	
	timer.Create("SS.ServerTicker", Time, 1, SS.ServerTicker.Close)
end

usermessage.Hook("SS.ServerTicker", SS.ServerTicker.Hook)

// Play sound

function SS.GUI.PlaySound(Message)
	local String = Message:ReadString()
	
	surface.PlaySound(String)
end

usermessage.Hook("SS.GUI.PlaySound", SS.GUI.PlaySound)

// Close ticker

function SS.ServerTicker.Close()
	SS.ServerTicker.Fade = true
end

// ConVars

CreateClientConVar("ss_showbar", "1", true, true)  

// Teams

function SS.Groups.Rank(ID)
	local Return = 0
	
	if (SS.Groups.List[ID]) then
		Return = SS.Groups.List[ID][3]
	end
	
	return Return
end

// Setup group

function SS.Groups.Setup(Message)
	local ID = Message:ReadString()
	
	local Index = Message:ReadShort()
	local R     = Message:ReadShort()
	local G     = Message:ReadShort()
	local B     = Message:ReadShort()
	local A     = Message:ReadShort()
	local Rank  = Message:ReadShort()
	
	local Col = Color(R, G, B, A)
	
	Msg("\n[SS] Creating Team '"..ID.."'\n")
	
	team.SetUp(Index, ID, Col)
	
	SS.Groups.List[Index] = {ID, Col, Rank}
end

usermessage.Hook("SS.Groups.Setup", SS.Groups.Setup)

// New part

function SS.Part.Add(ID, Type)
	table.insert(SS.Part.List, {ID, Type})
end

SS.Part.Add("Group", "Bar")
SS.Part.Add("Points", "Bar")
SS.Part.Add("Timer", "Bar")
SS.Part.Add("Points", "Hover")


// Request part

function SS.Part.Request(Player, Type)
	local Table = {}
	
	for K, V in pairs(SS.Part.List) do
		if (V[2] == Type) then
			local Text = "Error"
			
			local Type = type(V[1])
			
			if (Type == "function") then
				Text = V[1]()
			else
				Text = Player:GetNetworkedString(V[1])
			end
			
			table.insert(Table, Text)
		end
	end
	
	return Table
end

// Open file

function SS.GUI.Include(Message)
	local File = Message:ReadString()
	
	include(File)
end

usermessage.Hook("Include.File", SS.GUI.Include)

// Alert

function SS.GUI.PlayerMessage(Message)
	local T = Message:ReadShort()
	local M = Message:ReadString()
	
	local Sound = "ambient/water/drip2.wav"
	
	if T == 1 then
		Sound = "buttons/button10.wav"
	elseif T == 2 then
		Sound = "buttons/button17.wav"
	elseif T == 3 then
		Sound = "buttons/bell1.wav"
	elseif T == 4 then
		Sound = "ambient/machines/slicer"..math.random(1, 4)..".wav"
	end
	
	GAMEMODE:AddNotify(M, T, 10) 
	
	surface.PlaySound(Sound)
end

usermessage.Hook("SS.PlayerMessage", SS.GUI.PlayerMessage)

// Main GUI

SS.GUI.Name = 3024
SS.GUI.Info = 1024

function SS.GUI.Update()
	local TR = utilx.GetPlayerTrace(User, User:GetCursorAimVector())
	
	local Trace = util.TraceLine(TR)
	
	local Players = player.GetAll()
	
	for K, V in pairs(Players) do
		local Living = V:Alive()
		
		if (Living) then
			local Person = V
			
			if (Person != User) then
				local Pos = Person:GetShootPos() - User:GetShootPos()
				local Leng = Pos:Length()
				
				if (Leng < SS.GUI.Name) then
					if (Leng < 128) then
						Leng = 128
					end
					
					local Alpha = math.max(math.min(255 - ((255 / SS.GUI.Info) * Leng), 255), 0)
					local Dist  = math.max(math.min(255 - ((255 / SS.GUI.Name) * Leng), 255), 0)
					
					local X = Person:GetShootPos():ToScreen().x - 6
					local Y = Person:GetShootPos():ToScreen().y + 100
					
					local Col = team.GetColor(Person:Team())
					
					if (Person:GetNetworkedInt("Hide: Name") != 1) then
						local ID = Person:Name()
						
						draw.SimpleText(ID, SS.GUI.Font, X + 1, (Y - 178) + 1, Color(0, 0, 0, Dist), 1, 1)
						draw.SimpleText(ID, SS.GUI.Font, X, (Y - 178), Color(Col.r, Col.g, Col.b, Dist), 1, 1)
						
						local NY   = (Y - 178)
						local Cur = 0
						
						local Data = SS.Part.Request(Person, "Name")
						
						for B, J in pairs(Data) do
							if (J != "") then
								Cur = Cur + 16
								
								draw.SimpleText(J, SS.GUI.Font, X + 1, (NY + Cur) + 1, Color(0, 0, 0, Dist), 1, 1)
								draw.SimpleText(J, SS.GUI.Font, X, NY + Cur, Color(255, 255, 255, Dist), 1, 1)
							end
						end
					end
					
					if (Person:GetNetworkedInt("Hide: Hover") != 1) then
						if (Trace.Entity) then
							if (Trace.Entity == Person) then
								local HX = gui.MouseX() - 16
								local HY = gui.MouseY() - 64
								
								local Cur = 0
								
								local Number = 0
								
								local Amount = 0
								
								local Data = SS.Part.Request(Person, "Hover")
								
								// Font
								
								surface.SetFont(SS.GUI.Font)
								
								for B, J in pairs(Data) do
									if (J != "") then
										Number = Number + 1
										
										local W, H = surface.GetTextSize(J)
										
										if (W > Amount) then
											Amount = W
										end
									end
								end
								
								local BX, BY, BW, BH = (HX - 48), HY, (Amount + 32), ((18 * Number) + 10)
								
								SS.GUI.Box(BX, BY, BW, BH, Color(50, 50, 50, Alpha))
								
								local Data = SS.Part.Request(Person, "Hover")
								
								for B, J in pairs(Data) do
									if (J != "") then
										Cur = Cur + 16
										
										draw.SimpleText(J, SS.GUI.Font, (BX + (BW / 2)) + 1, (BY + Cur) + 1, Color(0, 0, 0, Alpha), 1, 1)
										draw.SimpleText(J, SS.GUI.Font, BX + (BW / 2), (BY + Cur), Color(255, 255, 255, Alpha), 1, 1)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if (User:GetNetworkedInt("Hide: Bar") != 1) then SS.Draw.Bar() end
end

hook.Add("HUDPaint", "SS.GUI.Update", SS.GUI.Update)

// Overwrite

function GAMEMODE:HUDDrawTargetID()
end

// Draw ticker

function SS.ServerTicker.Draw(PlayerColor)
	if (SS.ServerTicker.Enabled) then
		local Time = CurTime() - SS.ServerTicker.Time
		
		local Col = Color(100, 100, 100, 200)
		
		local Position = 0
		
		if not (SS.ServerTicker.Fade) then
			Position = math.Clamp(SS.ServerTicker.Position + (Time / 2), 0, 26)
		else
			Position = math.Clamp(SS.ServerTicker.Position - (Time / 2), 0, 26)
		end
		
		SS.ServerTicker.Position = Position
		
		draw.RoundedBox(0, 0, Position, ScrW(), 24, Col)
		draw.RoundedBox(0, 0, Position + 24, ScrW(), 2, PlayerColor)
		
		draw.SimpleText(SS.ServerTicker.Text, "Default", 6, Position + 6, Color(0, 0, 0, 255), 0, 0)
		draw.SimpleText(SS.ServerTicker.Text, "Default", 5, Position + 5, Color(255, 255, 255, 255), 0, 0)
		
		if (SS.ServerTicker.Fade) then
			if (Position <= 0) then
				SS.ServerTicker.Enabled = false
			end
		end
	end
end

// Draw a box

function SS.GUI.Box(X, Y, W, H, Colour)
	draw.RoundedBox(4, X, Y, W, H, Colour)
	
	return {X = X, Y = Y, W = W, H = H}
end

// Get team colour

function SS.GUI.TeamColor()
	local Side = User:Team()
	
	local Col = team.GetColor(Side)
	
	return Col
end

------------------------------------------------
----[ DRAW BAR ]-------------------------
------------------------------------------------

function SS.Draw.Bar()
	if (GetConVarNumber("ss_showbar") == 0) then
		surface.SetFont(SS.GUI.Font)
		
		local Text = "The bar GUI has been disabled!"
		
		local W, H = surface.GetTextSize(Text)
		
		W = W + 16
		
		draw.RoundedBox(6, 4, 4, W, 24, Color(50, 50, 50, 150))
		
		draw.SimpleText(Text, SS.GUI.Font, 5 + (W / 2), 5 + (24 / 2), Color(0, 0, 0, 200), 1, 1)
		draw.SimpleText(Text, SS.GUI.Font, 4 + (W / 2), 4 + (24 / 2), Color(255, 255, 255, 255), 1, 1)
		
		return
	end
	
	local Colour = SS.GUI.TeamColor()
	
	SS.ServerTicker.Draw(Colour)
	
	local Data = SS.Part.Request(User, "Bar")
	
	local Col = Color(50, 50, 50, 200)
	
	local Height = 24
	
	draw.RoundedBox(0, 0, 0, ScrW(), Height, Col)
	
	draw.RoundedBox(0, 0, Height, ScrW(), 2, Colour)
	
	local Col = Color(255, 255, 255, 255)
	
	local Text = table.concat(Data, "\t")
	
	draw.SimpleText(Text, "Default", 6, 6, Color(0, 0, 0, 255), 0, 0)
	draw.SimpleText(Text, "Default", 5, 5, Col, 0, 0)
end