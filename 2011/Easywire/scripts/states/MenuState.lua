--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

-- Called when the state is constructed.
function STATE:__init()
	self.m_gradientBlack = Gradient(
		Color(0, 0, 0, 1), Color(0, 0, 0, 1),
		Color(0.2, 0.2, 0.2, 1), Color(0.2, 0.2, 0.2, 1)
	);
	self.m_buttons = {};
	
	g_Fonts:AddSystem("Verdana", "VerdanaSmall", 20);
	g_Fonts:AddSystem("Verdana", "VerdanaLarge", 32);
	g_Fonts:AddSystem("Arial", "DefaultSmall", 14);
	g_Fonts:AddSystem("Arial", "Default", 16);
	
	local scrW = g_Display:GetW();
	local scrH = g_Display:GetH();
	local currentY = 0;
	
	currentY = self:AddMenuButton("New", currentY, function()
		states.SetActive("EditorState");
	end);

	currentY = self:AddMenuButton("Exit", currentY, function()
		g_Game:SetRunning(false);
	end);
	
	g_Display:Window():SetTitle("Easywire");
end;

-- Called when a mouse button is released.
function STATE:MouseButtonRelease(button)
	if (button == MOUSE_LEFT) then
		local mousePos = util.GetMousePos();
		
		for k, v in pairs(self.m_buttons) do
			if ( v.bbox:IsInside(mousePos) ) then
				g_Sounds:PlaySound("confirm", 1);
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
			if ( v.bbox:IsInside(mousePos) ) then
				v.depressed = true;
			end;
		end;
	end;
end;

-- A function to add a menu button.
function STATE:AddMenuButton(text, currentY, Callback)
	local textSize = util.GetTextSize("VerdanaLarge", text);
	local x = (g_Display:GetW() / 2) - (textSize.w / 2);
	local y = (g_Display:GetH() * 0.3) + currentY;
	
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
function STATE:UpdateGame(deltaTime) end;

-- Called when the display should be drawn.
function STATE:DrawDisplay()
	g_Render:DrawGradientFill(0, 0, g_Display:GetW(), g_Display:GetH(), self.m_gradientBlack);
	
	local mousePos = util.GetMousePos();
	
	for k, v in pairs(self.m_buttons) do
		local x, y = v.bbox:MinX(), v.bbox:MinY();
		
		if (v.depressed) then
			x = x + 2; y = y + 2;
		end;
		
		if ( v.bbox:IsInside(mousePos) ) then
			draw.ShadowedText("VerdanaLarge", x, y, v.text, Color(1, 0, 0, 1), Color(0, 0, 0, 0.8), true);
			
			if (not v.hovered) then
				g_Sounds:PlaySound("click", 1);
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
function STATE:OnUnload()  end;

-- Called when the state is loaded.
function STATE:OnLoad() end;