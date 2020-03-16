--[[
	© 2011-2012 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
	Conna Wiles (connawiles@gmail.com)
--]]

-- Called when the state is constructed.
function STATE:__init()
	self.m_gradientBlack = Gradient(
		Color(0, 0, 0, 1), Color(0, 0, 0, 1),
		Color(0.2, 0.2, 0.2, 1), Color(0.2, 0.2, 0.2, 1)
	);
	self.m_buttons = {};
	
	fonts.AddFreetype("AccidentalPresidency.ttf", "VerdanaSmall", 22);
	--fonts.AddFreetype("OldSansBlack.ttf", "VerdanaSmall", 20);
	fonts.AddFreetype("AccidentalPresidency.ttf", "VerdanaLarge", 30);
	fonts.AddFreetype("AccidentalPresidency.ttf", "VerdanaTiny", 20);
	--fonts.AddFreetype("OldSansBlack.ttf", "VerdanaLarge", 32);
	fonts.AddFreetype("AccidentalPresidency.ttf", "Default", 22);
	--fonts.AddFreetype("OldSansBlack.ttf", "Default", 20);
	
	--fonts.AddSystem("Verdana", "VerdanaSmall", 20);
	--fonts.AddSystem("Verdana", "VerdanaLarge", 32);
	--fonts.AddSystem("Arial", "Default", 16);
	
	local scrW = display.GetW();
	local scrH = display.GetH();
	local currentY = 0;
	
	currentY = self:AddMenuButton("Open Editor", currentY, function()
		--states.SetActive("EditorState");
		states.SetActive("EditorStateNew");
	end);
	
	-- currentY = self:AddMenuButton("Init Server", currentY, function()
		-- network.StartServer("4556");
	-- end);
	
	-- currentY = self:AddMenuButton("Init Client", currentY, function()
		-- network.StartClient("localhost", "4556");
	-- end);
	
	-- currentY = self:AddMenuButton("Say Hello", currentY, function()
		-- network.SendEvent("Greeting", "Hello!");
	-- end);
	
	currentY = self:AddMenuButton("Play Demo", currentY, function()
		controls.Clear(); entities.Clear();
			states.SetActive("PlayState");
		levels.Load("example");
	end);
	
	currentY = self:AddMenuButton("Quit", currentY, function()
		game.SetRunning(false);
	end);
end;

-- Called when a mouse button is released.
function STATE:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		local mousePos = util.GetMousePos();
		
		for k, v in pairs(self.m_buttons) do
			if (v.bbox:IsInside(mousePos)) then
				sounds.PlaySound("confirm", 1);
				v.Callback();
			end;
			
			v.depressed = false;
		end;
	end;
end;

-- Called when a mouse button is pressed.
function STATE:MouseButtonPress(button)
	if (button == MOUSE_LEFT) then
		local mousePos = util.GetMousePos();
		
		for k, v in pairs(self.m_buttons) do
			if (v.bbox:IsInside(mousePos)) then
				v.depressed = true;
			end;
		end;
	end;
end;

-- A function to add a menu button.
function STATE:AddMenuButton(text, currentY, Callback)
	local textSize = util.GetTextSize("VerdanaLarge", text);
	local x = (display.GetW() / 2) - (textSize.w / 2);
	local y = (display.GetH() * 0.3) + currentY;
	
	self.m_buttons[text] = {};
	self.m_buttons[text].text = text;
	self.m_buttons[text].bbox = BoundingBox();
	self.m_buttons[text].bbox:SetBounds(x, y, textSize.w, textSize.h);
	self.m_buttons[text].hovered = false;
	self.m_buttons[text].Callback = Callback;
	self.m_buttons[text].depressed = false;
	
	return currentY + textSize.h + 16;
end;

-- Called when the game should be updated.
function STATE:UpdateGame(deltaTime)
	network.Update();
end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	render.DrawGradientFill(0, 0, display.GetW(), display.GetH(), self.m_gradientBlack);
	
	local mousePos = util.GetMousePos();
	
	for k, v in pairs(self.m_buttons) do
		local x, y = v.bbox:MinX(), v.bbox:MinY();
		
		if (v.depressed) then
			x = x + 2; y = y + 2;
		end;
		
		if (v.bbox:IsInside(mousePos)) then
			draw.ShadowedText("VerdanaLarge", x, y, v.text, Color(1, 1, 0.6, 1), Color(0, 0, 0, 0.8), true);
			
			if (not v.hovered) then
				sounds.PlaySound("click", 1);
				v.hovered = true;
			end;
		else
			draw.ShadowedText("VerdanaLarge", x, y, v.text, Color(1, 1, 1, 1), Color(0, 0, 0, 0.8), true);
			
			if (v.hovered) then
				v.hovered = false;
			end;
		end;
	end;
end;

-- Called when the state is unloaded.
function STATE:OnUnload()
	sounds.StopMusic();
end;

-- Called when the state is loaded.
function STATE:OnLoad()
	sounds.PlayMusic("intro", 1, false, 1);
end;

--[[ This is just a networking test. --]]

-- Called when the server has received a network event.
function STATE:ServerEventReceived(connection, name, data)
	lua.Print("[SERVER] Received '"..data.."' from the '"..name.."' event.");
end;
	
-- Called when the client has received a network event.
function STATE:ClientEventReceived(name, data)
	lua.Print("[CLIENT] Received '"..data.."' from the '"..name.."' event.");
end;

-- Called when a client has joined the server.
function STATE:ClientJoin(connection)
	lua.Print("[SERVER] A client has joined the server.");
end;
	
-- Called when a client has left the server.
function STATE:ClientLeave(connection)
	lua.Print("[SERVER] A client has left the server.");
end;

-- Called when the client has connected to the server.
function STATE:Connected()
	lua.Print("[CLIENT] Connected to the server...");
end;
	
-- Called when the client has disconnected from the server.
function STATE:Disconnected()
	lua.Print("[CLIENT] Disconnected to the server...");
end;