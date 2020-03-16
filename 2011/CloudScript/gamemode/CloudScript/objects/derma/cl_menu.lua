--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local GRADIENT = surface.GetTextureID("gui/gradient");
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	if ( !CloudScript.theme:Call("PreMainMenuInit", self) ) then
		local smallTextFont = CloudScript.option:GetFont("menu_text_small");
		local tinyTextFont = CloudScript.option:GetFont("menu_text_tiny");
		local scrW = ScrW();
		local scrH = ScrH();
		
		self:SetPos(0, 0);
		self:SetSize( ScrW(), ScrH() );
		self:SetDrawOnTop(false);
		self:SetPaintBackground(false);
		self:SetMouseInputEnabled(true);
		self:SetKeyboardInputEnabled(true);
		
		self.closeMenuLabel = vgui.Create("cloud_LabelButton", self);
		self.closeMenuLabel:SetFont(smallTextFont);
		self.closeMenuLabel:SetText("LEAVE MENU");
		self.closeMenuLabel:SetCallback(function(button)
			self:SetOpen(false);
		end);
		self.closeMenuLabel:SetToolTip("Click here to close the menu.");
		self.closeMenuLabel:SizeToContents();
		self.closeMenuLabel:OverrideTextColor( CloudScript.option:GetColor("information") );
		self.closeMenuLabel:SetMouseInputEnabled(true);
		self.closeMenuLabel:SetPos(scrW * 0.1, scrH * 0.1);
		
		self.characterMenuLabel = vgui.Create("cloud_LabelButton", self);
		self.characterMenuLabel:SetFont(smallTextFont);
		self.characterMenuLabel:SetText("CHARACTERS");
		self.characterMenuLabel:SetCallback(function(button)
			self:SetOpen(false);
			CloudScript.character:SetPanelOpen(true);
		end);
		self.characterMenuLabel:SetToolTip("Click here to view the character menu.");
		self.characterMenuLabel:SizeToContents();
		self.characterMenuLabel:SetMouseInputEnabled(true);
		self.characterMenuLabel:SetPos(scrW * 0.1, self.closeMenuLabel.y + self.closeMenuLabel:GetTall() + 8);
		
		CloudScript:SetNoticePanel(self);
		
		self.CreateTime = SysTime();
		self.activePanel = nil;
		
		CloudScript.theme:Call("PostMainMenuInit", self);
		
		self:Rebuild();
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu(performCheck)
	if (!performCheck) then
		if ( IsValid(self.activePanel) and self.activePanel:IsVisible() ) then
			self.activePanel:MakePopup();
			self:FadeOut(0.5, self.activePanel, function()
				self.activePanel = nil;
			end);
		end;
	elseif ( IsValid(self.activePanel) and self.activePanel:IsVisible() ) then
		self.activePanel:MakePopup();
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	if ( !CloudScript.theme:Call("PreMainMenuRebuild", self) ) then
		local activePanel = CloudScript.menu:GetActivePanel();
		local isVisible = false;
		local width = self.characterMenuLabel:GetWide();
		local scrH = ScrH();
		local scrW = ScrW();
		local oy = self.characterMenuLabel.y + self.characterMenuLabel:GetTall() + 16;
		local ox = ScrW() * 0.1;
		local y = oy;
		local x = ox;
		
		for k, v in pairs(CloudScript.menu.stored) do
			if ( IsValid(v.button) ) then
				v.button:Remove();
			end;
		end;
		
		CloudScript.MenuItems.items = {};
		CloudScript.plugin:Call("MenuItemsAdd", CloudScript.MenuItems);
		CloudScript.plugin:Call("MenuItemsDestroy", CloudScript.MenuItems);
		
		table.sort(CloudScript.MenuItems.items, function(a, b)
			return a.text < b.text;
		end);
		
		for k, v in ipairs(CloudScript.MenuItems.items) do
			local button, panel = nil, nil;
			
			if ( CloudScript.menu.stored[v.panel] ) then
				panel = CloudScript.menu.stored[v.panel].panel;
			else
				panel = vgui.Create(v.panel, self);
				panel:SetVisible(false);
				panel:SetSize( CloudScript.menu:GetWidth(), panel:GetTall() );
				panel:SetPos(0, 0);
			end;
			
			if ( !panel.IsButtonVisible or panel:IsButtonVisible() ) then
				button = vgui.Create("cloud_LabelButton", self);
			end;
			
			if (button) then
				button:SetFont( CloudScript.option:GetFont("menu_text_tiny") );
				button:SetText( string.upper(v.text) );
				button:SetAlpha(0);
				button:FadeIn(0.5);
				button:SetToolTip(v.tip);
				button:SetCallback(function(button)
					if (CloudScript.menu:GetActivePanel() != panel) then
						self:OpenPanel(panel);
					end;
				end);
				button:SizeToContents();
				button:SetMouseInputEnabled(true);
				button:SetPos(x, y);
				
				y = y + button:GetTall() + 8;
				isVisible = true;
				
				if (button:GetWide() > width) then
					width = button:GetWide();
				end;
			end;
			
			CloudScript.menu.stored[v.panel] = {
				button = button,
				panel = panel
			};
		end;
		
		for k, v in pairs(CloudScript.menu.stored) do
			if (activePanel == v.panel) then
				if ( !IsValid(v.button) ) then
					self:FadeOut(0.5, activePanel, function()
						self.activePanel = nil;
					end);
				end;
			end;
		end;
		
		CloudScript.theme:Call("PostMainMenuRebuild", self);
	end;
end;

-- A function to open a panel.
function PANEL:OpenPanel(panelToOpen)
	if ( !CloudScript.theme:Call("PreMainMenuOpenPanel", self, panelToOpen) ) then
		local scrW = ScrW();
		local scrH = ScrH();
		
		if ( IsValid(self.activePanel) ) then
			self:FadeOut(0.5, self.activePanel, function()
				self.activePanel = nil;
				self:OpenPanel(panelToOpen);
			end);
			
			return;
		end;
		
		self.activePanel = panelToOpen;
		self.activePanel:SetAlpha(0);
		self.activePanel:SetSize( CloudScript.menu:GetWidth(), self.activePanel:GetTall() );
		self.activePanel:MakePopup();
		self.activePanel:SetPos( (scrW * 0.9) - self.activePanel:GetWide(), scrH * 0.1 );
		
		self:FadeIn(0.5, self.activePanel, function()
			timer.Simple(FrameTime() * 0.5, function()
				if ( IsValid(self.activePanel) ) then
					if (self.activePanel.OnSelected) then
						self.activePanel:OnSelected();
					end;
				end;
			end);
		end);
		
		CloudScript.theme:Call("PostMainMenuOpenPanel", self, panelToOpen);
	end;
end;

-- A function to make a panel fade out.
function PANEL:FadeOut(speed, panel, Callback)
	if ( panel:GetAlpha() > 0 and ( !self.fadeOutAnimation or !self.fadeOutAnimation:Active() ) ) then
		self.fadeOutAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished) then
				self.fadeOutAnimation = nil;
				panel:SetVisible(false);
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Start(speed);
		end;
		
		CloudScript.option:PlaySound("rollover");
	else
		panel:SetVisible(false);
		panel:SetAlpha(0);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- A function to make a panel fade in.
function PANEL:FadeIn(speed, panel, Callback)
	if ( panel:GetAlpha() == 0 and ( !self.fadeInAnimation or !self.fadeInAnimation:Active() ) ) then
		self.fadeInAnimation = Derma_Anim("Fade Panel", panel, function(panel, animation, delta, data)
			panel:SetVisible(true);
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished) then
				self.fadeInAnimation = nil;
			end;
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.fadeInAnimation) then
			self.fadeInAnimation:Start(speed);
		end;
		
		CloudScript.option:PlaySound("click_release");
	else
		panel:SetVisible(true);
		panel:SetAlpha(255);
		
		if (Callback) then
			Callback();
		end;
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint()
	if ( !CloudScript.theme:Call("PreMainMenuPaint", self) ) then
		derma.SkinHook("Paint", "Panel", self);
		CloudScript.theme:Call("PostMainMenuPaint", self);
	end;
	
	return true;
end;

-- Called every fame.
function PANEL:Think()
	if ( !CloudScript.theme:Call("PreMainMenuThink", self) ) then
		if ( CloudScript.plugin:Call("ShouldDrawMenuBackgroundBlur") ) then
			CloudScript:RegisterBackgroundBlur(self, self.CreateTime);
		else
			CloudScript:RemoveBackgroundBlur(self);
		end;
		
		self:SetVisible( CloudScript.menu:GetOpen() );
		self:SetSize( ScrW(), ScrH() );
		
		CloudScript.menu.height = ScrH() * 0.75;
		CloudScript.menu.width = ScrW() * 0.6;
		
		if (self.fadeOutAnimation) then
			self.fadeOutAnimation:Run();
		end;
		
		if (self.fadeInAnimation) then
			self.fadeInAnimation:Run();
		end;
		
		CloudScript.theme:Call("PostMainMenuThink", self);
	end;
end;

-- A function to set whether the panel is open.
function PANEL:SetOpen(isOpen)
	self:SetVisible(isOpen);
	self:ReturnToMainMenu(true);
	
	CloudScript.menu.isOpen = isOpen;
	gui.EnableScreenClicker(isOpen);
	
	if (isOpen) then
		self:Rebuild();
		self.CreateTime = SysTime();
		
		CloudScript.plugin:Call("MenuOpened");
	else
		CloudScript.plugin:Call("MenuClosed");
	end;
end;

vgui.Register("cloud_Menu", PANEL, "DPanel");

hook.Add("VGUIMousePressed", "CloudScript.menu:VGUIMousePressed", function(panel, code)
	local activePanel = CloudScript.menu:GetActivePanel();
	local menuPanel = CloudScript.menu:GetPanel();
	
	if (CloudScript.menu:GetOpen() and activePanel and menuPanel == panel) then
		menuPanel:ReturnToMainMenu();
	end;
end);

usermessage.Hook("cloud_MenuOpen", function(msg)
	local panel = CloudScript.menu:GetPanel();
	
	if (panel) then
		CloudScript.menu:SetOpen( msg:ReadBool() );
	else
		CloudScript.menu:Create( msg:ReadBool() );
	end;
end);

usermessage.Hook("cloud_MenuToggle", function(msg)
	if ( CloudScript.Client:HasInitialized() ) then
		if ( !CloudScript.menu:GetPanel() ) then
			CloudScript.menu:Create(false);
		end;
		
		local panel = CloudScript.menu:GetPanel();
		
		if (panel) then
			CloudScript.menu:ToggleOpen();
		end;
	end;
end);