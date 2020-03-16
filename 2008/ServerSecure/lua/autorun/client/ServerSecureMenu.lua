if (MM) then return end

// Locals

local User = LocalPlayer()

------------------------------------------------
----[ MENU ]--------------------------------
------------------------------------------------

MM               = {}
MM.Panel         = {}
MM.Panel.Current = {}
MM.Panel.Limit   = 8
MM.Panel.X       = 8
MM.Panel.Y       = 150
MM.Panel.Font    = "Verdana"

// Font

surface.CreateFont("Verdana", 15, 600, true, false, "Verdana")

// Screen clicker

MM.Panel.Backup = gui.EnableScreenClicker

function gui.EnableScreenClicker(Bool)
	MM.Panel.Clicker = Bool
	
	MM.Panel.Backup(Bool)
end

// New

function MM.Panel:New(Title)
	MM.Panel.Current = {}
	
	local Table = {}
	
	setmetatable(Table, self)
	
	self.__index = self
	
	Table.Buttons = {}
	Table.More    = {}
	Table.Title   = Title
	Table.X       = MM.Panel.X
	Table.Y       = MM.Panel.Y
	Table.W       = 0
	Table.H       = 0
	
	Table.Closing = false
	
	Table.Close           = {}
	Table.Close.Highlight = false
	Table.Close.Box       = {X = 0, Y = 0, W = 0, H = 0}
	
	Table.Active = true
	
	return Table
end

// Button

function MM.Panel:Button(Text, Command, Bool, R, G, B, Hide)
	Bool = Bool or false
	
	Hide = Hide or true
	
	R = R or 125
	G = G or 125
	B = B or 125
	
	local Insert = {Text = Text, Button = true, Command = Command, Active = false, X = 0, Y = 0, W = 0, H = 0, Red = R, Green = G, Blue = B, Bool = Bool, Hide = Hide}
	
	for K, V in pairs(self.Buttons) do
		if (V.Text == Text) then
			return
		end
	end
	
	if (table.Count(self.Buttons) > MM.Panel.Limit) and not (Bool) then
		table.insert(self.More, Insert)
	else
		table.insert(self.Buttons, Insert)
	end
end

// Words

function MM.Panel:Words(Text, R, G, B)
	R = R or 255
	G = G or 255
	B = B or 255
	
	local Insert = {Text = Text, Button = false, Active = false, X = 0, Y = 0, W = 0, H = 0, Red = R, Green = G, Blue = B}
	
	if (table.Count(self.Buttons) > MM.Panel.Limit) then
		table.insert(self.More, Insert)
	else
		table.insert(self.Buttons, Insert)
	end
end

// Create

function MM.Panel:Create()
	if (table.Count(self.More) > 0) then
		local function More()
			local Panel = MM.Panel:New(self.Title)
			
			for K, V in pairs(self.More) do
				if (V.Button) then
					Panel:Button(V.Text, V.Command, V.Bool, V.Red, V.Green, V.Blue, V.Hide)
				else
					Panel:Words(V.Text, V.Red, V.Green, V.Blue)
				end
			end
			
			local function Function()
				MM.Panel.Show(self)
			end
			
			Panel:Button("Previous", Function, true, 150, 150, 150)
			
			Panel:Create()
		end
		
		self:Button("Next", More, true, 150, 150, 150)
	end
	
	MM.Panel.Current = self
	
	gui.EnableScreenClicker(true)
end

// Show

function MM.Panel.Show(Table)
	local Panel = MM.Panel:New(Table.Title)
	
	for K, V in pairs(Table.Buttons) do
		if (V.Button) then
			Panel:Button(V.Text, V.Command, V.Bool, V.Red, V.Green, V.Blue, V.Hide)
		else
			Panel:Words(V.Text)
		end
	end
	
	Panel.More = Table.More
	
	Panel:Create()
end

// Hide

function MM.Panel.Hide()
	MM.Panel.Current = {}
	
	gui.EnableScreenClicker(false)
end

// Draw

function MM.Panel.Box(X, Y, W, H, Colour, Border)
	Border = Border or 2
	
	draw.RoundedBox(4, X, Y, W, H, Colour)
	
	return {X = X, Y = Y, W = W, H = H}
end

// Text

function MM.Panel.Text(X, Y, Text, R, G, B, AX, AY)
	// Colour
	
	R = R or 255
	G = G or 255
	B = B or 255
	
	// Align
	
	AX = AX or 0
	AY = AY or 0
	
	draw.SimpleText(Text, MM.Panel.Font, X + 1, Y + 1, Color(0, 0, 0, 255), AX, AY)
	draw.SimpleText(Text, MM.Panel.Font, X, Y, Color(R, G, B, 255), AX, AY)
end

// Table

function MM.Panel.Largest(Table)
	local Width = 0
	local Height = 1
	
	surface.SetFont(MM.Panel.Font)
	
	local X, Y = surface.GetTextSize(Table.Title)
	
	if (X > Width) then
		Width = X
	end
	
	for K, V in pairs(Table.Buttons) do
		local X, Y = surface.GetTextSize(V.Text)
		
		if (X > Width) then
			Width = X
		end
		
		Height = Height + 1
	end
	
	Height = 32 * Height
	
	return Width, Height
end

// Draw

function MM.Panel.Draw()
	if (MM.Panel.Current.Active) then
		local Width, Height = MM.Panel.Largest(MM.Panel.Current)
		
		Width = Width + 64
		Height = Height
		
		MM.Panel.Current.W = Width
		MM.Panel.Current.H = Height
		
		MM.Panel.Box(MM.Panel.Current.X, MM.Panel.Current.Y, MM.Panel.Current.W, MM.Panel.Current.H, Color(0, 0, 0, 125))
		
		local Colour = Color(100, 100, 100, 150)
		
		MM.Panel.Box(MM.Panel.Current.X, MM.Panel.Current.Y, Width, 24, Colour)
		
		MM.Panel.Text(MM.Panel.Current.X + 10, MM.Panel.Current.Y + 6, MM.Panel.Current.Title, 255, 255, 255)
		
		for B, J in pairs(MM.Panel.Current.Buttons) do
			local Colour = Color(J.Red, J.Green, J.Blue, 255)
			
			if (J.Active) then
				local R = math.min(J.Red + 25, 255)
				local G = math.min(J.Green + 25, 255)
				local B = math.min(J.Blue + 25, 255)
				
				Colour = Color(R, G, B, 255)
			end
			
			J.X = MM.Panel.Current.X + 8
			J.Y = MM.Panel.Current.Y + (32 * B)
			J.W = Width - 16
			J.H = 24
			
			if (J.Button) then
				MM.Panel.Box(J.X, J.Y, J.W, J.H, Colour)
				
				MM.Panel.Text(J.X + 6, J.Y + 5, J.Text, 255, 255, 255)
			else
				MM.Panel.Text(J.X + 6, J.Y + 5, J.Text, J.Red, J.Green, J.Blue)
			end
		end
		
		Colour = Color(255, 0, 0, 100)
		
		if (MM.Panel.Current.Close.Highlight) then
			Colour = Color(255, 0, 0, 125)
		end
		
		MM.Panel.Current.Close.Box = MM.Panel.Box((MM.Panel.Current.X + MM.Panel.Current.W) - 20, MM.Panel.Current.Y + 5, 15, 15, Colour, 1)
		
		MM.Panel.Text(MM.Panel.Current.Close.Box.X + (15 / 2), MM.Panel.Current.Close.Box.Y + (15 / 2), "X", 255, 255, 255, 1, 1)
	end
end

hook.Add("HUDPaint", "MM.Panel.Draw", MM.Panel.Draw)

// Think

function MM.Panel.Think()
	if (MM.Panel.Current.Active) then
		if not (MM.Panel.Clicker) then
			gui.EnableScreenClicker(true)
		end
		
		if gui.MouseX() > MM.Panel.Current.Close.Box.X and gui.MouseX() < (MM.Panel.Current.Close.Box.X + MM.Panel.Current.Close.Box.W) and gui.MouseY() > MM.Panel.Current.Close.Box.Y and gui.MouseY() < (MM.Panel.Current.Close.Box.Y + MM.Panel.Current.Close.Box.H) then
			if not (MM.Panel.Current.Close.Highlight) then
				surface.PlaySound("common/talk.wav")
			end
			
			MM.Panel.Current.Close.Highlight = true
		else
			MM.Panel.Current.Close.Highlight = false
		end
		
		for B, J in pairs(MM.Panel.Current.Buttons) do
			if J.Button then
				if gui.MouseX() > J.X and gui.MouseX() < (J.X + J.W) and gui.MouseY() > J.Y and gui.MouseY() < (J.Y + J.H) then
					if not (J.Active) then
						surface.PlaySound("common/talk.wav")
					end
					
					J.Active = true
				else
					J.Active = false
				end
			end
		end
	end
end

hook.Add("Think", "MM.Panel.Think", MM.Panel.Think)

// Key pressed

function MM.Panel.Pressed(Key)
	if (Key == MOUSE_LEFT) then
		if (MM.Panel.Current.Active) then
			if (gui.MouseX() > MM.Panel.Current.Close.Box.X and gui.MouseX() < (MM.Panel.Current.Close.Box.X + MM.Panel.Current.Close.Box.W)) and (gui.MouseY() > MM.Panel.Current.Close.Box.Y) and (gui.MouseY() < (MM.Panel.Current.Close.Box.Y + MM.Panel.Current.Close.Box.H)) then
				MM.Panel.Hide()
				
				surface.PlaySound("buttons/button24.wav")
				
				return
			end
			
			for B, J in pairs(MM.Panel.Current.Buttons) do
				if (J.Button) then
					if gui.MouseX() > J.X and gui.MouseX() < (J.X + J.W) and gui.MouseY() > J.Y and gui.MouseY() < (J.Y + J.H) then
						if type(J.Command) == "string" then
							if (J.Hide) then MM.Panel.Hide() end
							
							User:ConCommand(J.Command.."\n")
						else
							if (J.Hide) then MM.Panel.Hide() end
							
							J.Command()
						end
						
						surface.PlaySound("buttons/button24.wav")
					end
				end
			end
		end
	end
end

hook.Add("GUIMousePressed", "MM.Panel.Pressed", MM.Panel.Pressed)

// Hooks

MM.Panel.Prog  = {}
MM.Panel.Hooks = {}

// Start

function MM.Panel.Hooks.Start(Message)
	MM.Panel.Prog = MM.Panel:New(Message:ReadString())
end

usermessage.Hook("Panel.Create", MM.Panel.Hooks.Start)

// Buttons

function MM.Panel.Hooks.Buttons(Message)
	local Text    = Message:ReadString()
	local Command = Message:ReadString()
	
	local R = Message:ReadShort()
	local G = Message:ReadShort()
	local B = Message:ReadShort()
	
	local Bool = Message:ReadBool()
	
	MM.Panel.Prog:Button(Text, Command, false, R, G, B, Bool)
end

usermessage.Hook("Panel.Button", MM.Panel.Hooks.Buttons)

// Text

function MM.Panel.Hooks.Text(Message)
	local Text = Message:ReadString()
	
	local R = Message:ReadShort()
	local G = Message:ReadShort()
	local B = Message:ReadShort()
	
	MM.Panel.Prog:Words(Text, R, G, B)
end

usermessage.Hook("Panel.Words", MM.Panel.Hooks.Text)

// Finish

function MM.Panel.Hooks.Finish(Message)
	MM.Panel.Prog:Create()
end

usermessage.Hook("Panel.Finish", MM.Panel.Hooks.Finish)