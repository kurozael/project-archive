--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

AccessorFunc(PANEL, "m_bPaintBackground", "PaintBackground");
AccessorFunc(PANEL, "m_bgColor", "BackgroundColor");
AccessorFunc(PANEL, "m_bDisabled", "Disabled");

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle("Achievements");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.achievements.panel = self;
	
	self:Rebuild();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Some achievements give you a reward when you achieve them.");
		label:SetInfoColor("blue");
	self.panelList:AddItem(label);
	
	for k, v in pairs( openAura.achievement:GetAll() ) do
		self.currentAchievement = v;
		self.panelList:AddItem( vgui.Create("aura_Achievement") );
	end;

	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (openAura.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("aura_Achievements", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 34);
	
	local colorWhite = openAura.option:GetColor("white");
	
	self.achievement = openAura.achievements:GetPanel().currentAchievement;
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.achievement.name);
	self.nameLabel:SetTextColor(colorWhite);
	self.nameLabel:SizeToContents();
	
	self.progressBar = vgui.Create("DPanel", self);
	self.progressBar:SetPos(36, 20);
	self.progressBar:SetSize(self:GetWide() - 38, 12);
	
	self.progressLabel = vgui.Create("DLabel", self.progressBar);
	self.progressLabel:SetText("0/0");
	self.progressLabel:SetTextColor(colorWhite);
	self.progressLabel:SizeToContents();
	self.progressLabel:SetExpensiveShadow( 1, Color(0, 0, 0, 150) );
	
	self.spawnIcon = vgui.Create("DImageButton", self);
	self.spawnIcon:SetToolTip(self.achievement.description);
	self.spawnIcon:SetSize(32, 32);
	
	if ( openAura.achievements:Has(self.achievement.name) ) then
		self.spawnIcon:SetImage("achievements/achieved");
	else
		self.spawnIcon:SetImage(self.achievement.image);
	end;
	
	self.spawnIcon.OnCursorEntered = function() end;
	self.spawnIcon.OnMouseReleased = function() end;
	self.spawnIcon.OnCursorExited = function() end;
	self.spawnIcon.OnMousePressed = function() end;
	self.spawnIcon:SetCursor("none");
	
	-- Called when the panel should be painted.
	function self.progressBar.Paint(progressBar)
		local color = table.Copy( derma.Color("bg_color", self) or Color(100, 100, 100, 255) );
		
		if (color) then
			color.r = math.min(color.r - 25, 255);
			color.g = math.min(color.g - 25, 255);
			color.b = math.min(color.b - 25, 255);
		end;
		
		openAura:DrawSimpleGradientBox(0, 0, 0, progressBar:GetWide(), progressBar:GetTall(), color);
		
		local progress = openAura.achievements:Get(self.achievement.name);
		local maximum = self.achievement.maximum;
		local width = math.Clamp( (progressBar:GetWide() / maximum) * progress, 0, progressBar:GetWide() );
		
		openAura:DrawSimpleGradientBox( 0, 0, 0, width, progressBar:GetTall(), Color(139, 215, 113, 255) );
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.progressLabel:SetText(openAura.achievements:Get(self.achievement.name).."/"..self.achievement.maximum);
	self.progressLabel:SizeToContents();
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(32, 32);
	
	self.progressLabel:SetPos(
		self.progressBar:GetWide() - self.progressLabel:GetWide() - 8,
		(self.progressBar:GetTall() / 2) - (self.progressLabel:GetTall() / 2) - 1
	);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(32, 32);
	self.nameLabel:SetPos(36, 2);
	self.nameLabel:SizeToContents();
	self.progressBar:SetSize(self:GetWide() - 38, 12);
end;

vgui.Register("aura_Achievement", PANEL, "DPanel");