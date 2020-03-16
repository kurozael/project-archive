--[[
Name: "cl_menu.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = nexus.schema.GetFont("menu_text_small");
	local tinyTextFont = nexus.schema.GetFont("menu_text_tiny");
	local scrW = ScrW();
	local scrH = ScrH();
	
	self:SetPos(0, 0);
	self:SetSize( ScrW(), ScrH() );
	self:SetDrawOnTop(false);
	self:SetPaintBackground(false);
	self:SetMouseInputEnabled(true);
	self:SetKeyboardInputEnabled(true);
	
	self.characterMenuLabel = vgui.Create("nx_LabelButton", self);
	self.characterMenuLabel:SetFont(smallTextFont);
	self.characterMenuLabel:SetText("CHARACTERS");
	self.characterMenuLabel:SetCallback(function(button)
		self:SetOpen(false);
		nexus.character.SetPanelOpen(true);
	end);
	self.characterMenuLabel:SetToolTip("Click here to view the character menu.");
	self.characterMenuLabel:SizeToContents();
	self.characterMenuLabel:SetMouseInputEnabled(true);
	self.characterMenuLabel:SetPos(scrW * 0.05, scrH * 0.05);
	
	self.closeMenuLabel = vgui.Create("nx_LabelButton", self);
	self.closeMenuLabel:SetFont(smallTextFont);
	self.closeMenuLabel:SetText("CLOSE MENU");
	self.closeMenuLabel:SetCallback(function(button)
		self:SetOpen(false);
	end);
	self.closeMenuLabel:SetToolTip("Click here to close the menu.");
	self.closeMenuLabel:SizeToContents();
	self.closeMenuLabel:SetMouseInputEnabled(true);
	self.closeMenuLabel:SetPos(scrW - self.closeMenuLabel:GetWide() - (scrW * 0.05), scrH * 0.05);
	
	self.noticeLabel = vgui.Create("DLabel", self);
	self.noticeLabel:SetPos(ScrW() / 2, -128);
	self.noticeLabel:SetFont(tinyTextFont);
	self.noticeLabel:SetText("");
	self.noticeLabel:SizeToContents();
	
	self.createTime = SysTime();
	self.activePanel = nil;
	
	self:Rebuild();
end;

-- A function to display a character notice.
function PANEL:DisplayCharacterNotice(notice)
	if ( !self.animation or !self.animation:Active() ) then
		if (self.noticeLabel.y > 0 or !notice) then
			self.animation = Derma_Anim("Slide Panel", self.noticeLabel, function(panel, animation, delta, data)
				panel:SetPos( (ScrW() / 2) - (panel:GetWide() / 2), data[1] - (data[2] * delta) );
				
				if (animation.Finished and notice) then
					self:DisplayCharacterNotice(notice);
				end;
			end);
			
			if (self.animation) then
				self.animation:Start( 0.4, {self.noticeLabel.y, self.noticeLabel.y + self.noticeLabel:GetTall() + 8} );
			end;
		else
			self.noticeLabel:SetText(notice);
			self.noticeLabel:SizeToContents();
			
			self.animation = Derma_Anim("Slide Panel", self.noticeLabel, function(panel, animation, delta, data)
				panel:SetPos( (ScrW() / 2) - (panel:GetWide() / 2), data[1] + ( ( data[2] - data[1] ) * delta ) );
				
				if (animation.Finished) then
					timer.Create("Notice Expire", math.max(4, string.len(notice) * 0.03), 1, function()
						self:DisplayCharacterNotice();
					end);
				end;
			end);
			
			if (self.animation) then
				self.animation:Start( 0.4, { self.noticeLabel.y, 24 - (self.noticeLabel:GetTall() / 2) } );
			end;
		end;
	end;
	
	if ( timer.IsTimer("Notice Expire") ) then
		timer.Destroy("Notice Expire");
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu(performCheck)
	if (!performCheck) then
		if (self.activePanel) then
			self:SlideOut(1, self.activePanel);
			self.activePanel = nil;
			
			if ( IsValid(self.activeButton) ) then
				self.activeButton:SetPos(ScrW() * 0.05, self.activeButton.y);
				self.activeButton:SetText(self.activeButton.oldText);
				self.activeButton:SizeToContents();
				self.activeButton = nil;
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	local activePanel = nexus.menu.GetActivePanel();
	local y = ScrH() * 0.1;
	local x = ScrW() * 0.05;
	
	for k, v in pairs(nexus.menu.stored) do
		if ( IsValid(v.button) ) then
			v.button:Remove();
		end;
	end;
	
	NEXUS.MenuItems.items = {};
	
	nexus.mount.Call("MenuItemsAdd", NEXUS.MenuItems);
	nexus.mount.Call("MenuItemsDestroy", NEXUS.MenuItems);
	
	table.sort(NEXUS.MenuItems.items, function(a, b)
		return a.text < b.text;
	end);
	
	for k, v in ipairs(NEXUS.MenuItems.items) do
		local button, panel = nil, nil;
		
		if ( nexus.menu.stored[v.panel] ) then
			panel = nexus.menu.stored[v.panel].panel;
		else
			panel = vgui.Create(v.panel, self);
			panel:SetVisible(false);
			panel:SetPos(0, 0);
		end;
		
		if ( !panel.IsButtonVisible or panel:IsButtonVisible() ) then
			button = vgui.Create("nx_LabelButton", self);
		end;
		
		if (button) then
			button:SetFont( nexus.schema.GetFont("menu_text_tiny") );
			button:SetText( string.upper(v.text) );
			button:SetPos(x, y);
			button:SetToolTip(v.tip);
			button:SetCallback(function(button)
				if ( !self.slideInAnimation or !self.slideInAnimation:Active() ) then
					if (nexus.menu.GetActivePanel() != panel) then
						self:OpenPanel(panel);
						
						if ( IsValid(self.activeButton) ) then
							self.activeButton:SetPos(x, self.activeButton.y);
							self.activeButton:SetText(self.activeButton.oldText);
							self.activeButton:SizeToContents();
						end;
						
						self.activeButton = button;
						self.activeButton.oldText = button:GetValue();
						self.activeButton:SetPos(button.x + 8, button.y);
						self.activeButton:SetText("> "..button.oldText);
						self.activeButton:SizeToContents();
					end;
				end;
			end);
			button:SizeToContents();
			button:SetMouseInputEnabled(true);
			
			y = y + button:GetTall() + 8;
		end;
		
		nexus.menu.stored[v.panel] = {
			button = button,
			panel = panel
		};
	end;
	
	for k, v in pairs(nexus.menu.stored) do
		if (nexus.menu.GetActivePanel() == v.panel) then
			if ( !IsValid(v.button) ) then
				self.activePanel = nil;
				
				v.panel:SetVisible(false);
				v.panel:SetPos(0, 0);
			end;
		end;
	end;
end;

-- A function to open a panel.
function PANEL:OpenPanel(panelToOpen, Callback)
	if (self.activePanel) then
		self:SlideOut(1, self.activePanel);
	end;
	
	self.activePanel = panelToOpen;
	self.activePanel:SetPos(ScrW() * 1.5, ScrH() * 0.1);
	self.activePanel:SetSize( nexus.menu.GetWidth(), self.activePanel:GetTall() );
	self.activePanel:MakePopup();
	self.activePanel:SetAlpha(255);
	self.activePanel:SetVisible(true);
	
	if (self.activePanel.OnSelected) then
		self.activePanel:OnSelected();
	end;
	
	self:SlideIn( 1, self.activePanel, (ScrW() / 2) - (self.activePanel:GetWide() / 2) );
	
	if (Callback) then
		Callback(self.activePanel);
	end;
end;

-- A function to make the panel slide out.
function PANEL:SlideOut(speed, panel)
	if ( panel.x > 0 and ( !self.slideOutAnimation or !self.slideOutAnimation:Active() ) ) then
		self.slideOutAnimation = Derma_Anim("Slide Out", panel, function(panel, animation, delta, data)
			panel:SetPos(data[1] - (data[2] * delta), panel.y);
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished) then
				panel:SetVisible(false);
			end;
		end);
		
		if (self.slideOutAnimation) then
			self.slideOutAnimation:Start( speed, {panel.x, panel:GetWide() + panel.x + 8} );
		end;
	end;
end;

-- A function to make the panel slide in.
function PANEL:SlideIn(speed, panel, newX)
	if ( panel.x > ScrW() and ( !self.slideInAnimation or !self.slideInAnimation:Active() ) ) then
		self.slideInAnimation = Derma_Anim("Slide In", panel, function(panel, animation, delta, data)
			panel:SetPos(data[1] + ( ( data[2] - data[1] ) * delta ), panel.y);
			panel:SetAlpha(delta * 255);
		end);
		
		if (self.slideInAnimation) then
			self.slideInAnimation:Start( speed, {panel.x, newX} );
		end;
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Panel", self);
	
	return true;
end;

-- Called every fame.
function PANEL:Think()
	if ( nexus.mount.Call("ShouldDrawMenuBackgroundBlur") ) then
		NEXUS:RegisterBackgroundBlur(self, self.createTime);
	else
		NEXUS:RemoveBackgroundBlur(self);
	end;
	
	self:SetVisible( nexus.menu.GetOpen() );
	self:SetSize( ScrW(), ScrH() );
	
	nexus.menu.height = ScrH() * 0.75;
	nexus.menu.width = ScrW() * 0.4;
	
	if (self.slideInAnimation) then
		self.slideInAnimation:Run();
	end;
	
	if (self.slideOutAnimation) then
		self.slideOutAnimation:Run();
	end;
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- A function to set whether the panel is open.
function PANEL:SetOpen(boolean)
	self:SetVisible(boolean);
	self:ReturnToMainMenu(true);
	
	nexus.menu.isOpen = boolean;
	
	gui.EnableScreenClicker(boolean);
	
	if (boolean) then
		self:Rebuild();
		self.createTime = SysTime();
		
		nexus.mount.Call("MenuOpened");
	else
		nexus.mount.Call("MenuClosed");
	end;
end;

vgui.Register("nx_Menu", PANEL, "DPanel");

hook.Add("VGUIMousePressed", "nexus.menu.VGUIMousePressed", function(panel, code)
	local activePanel = nexus.menu.GetActivePanel();
	local menuPanel = nexus.menu.GetPanel();
	
	if (nexus.menu.GetOpen() and activePanel and menuPanel == panel) then
		activePanel:MakePopup(); menuPanel:ReturnToMainMenu();
	end;
end);

usermessage.Hook("nx_MenuOpen", function(msg)
	local panel = nexus.menu.GetPanel();
	
	if (panel) then
		nexus.menu.SetOpen( msg:ReadBool() );
	else
		nexus.menu.Create( msg:ReadBool() );
	end;
end);

usermessage.Hook("nx_MenuToggle", function(msg)
	if ( g_LocalPlayer:HasInitialized() ) then
		local panel = nexus.menu.GetPanel();
		
		if (panel) then
			nexus.menu.ToggleOpen();
		else
			nexus.menu.Create(!nexus.menu.isOpen);
		end;
	end;
end);