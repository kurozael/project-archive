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
	self:SetTitle("Augments");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.augments.panel = self;
	
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
	
	local permaPanels = {};
	local goodPanels = {};
	local evilPanels = {};
	
	for k, v in pairs( openAura.augment:GetAll() ) do
		if (v.karma == "perma") then
			permaPanels[#permaPanels + 1] = v;
		elseif (v.karma == "good") then
			goodPanels[#goodPanels + 1] = v;
		elseif (v.karma == "evil") then
			evilPanels[#evilPanels + 1] = v;
		end;
	end;
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Yellow augments give you an advantage regardless of karma.");
		label:SetInfoColor("orange");
		label:SetShowIcon(false);
	self.panelList:AddItem(label);
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Red augments give you an advantage as long as you are evil.");
		label:SetInfoColor("red");
		label:SetShowIcon(false);
	self.panelList:AddItem(label);
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Blue augments give you an advantage as long as you are good.");
		label:SetInfoColor("blue");
		label:SetShowIcon(false);
	self.panelList:AddItem(label);
	
	table.sort(permaPanels, function(a, b) return a.cost > b.cost; end);
	table.sort(goodPanels, function(a, b) return a.cost > b.cost; end);
	table.sort(evilPanels, function(a, b) return a.cost > b.cost; end);
	
	if (#permaPanels > 0) then
		local permaForm = vgui.Create("DForm", self);
		local panelList = vgui.Create("DPanelList", self);
		
		for k, v in pairs(permaPanels) do
			self.currentAugment = v;
			panelList:AddItem( vgui.Create("aura_Augment") );
		end;
		
		panelList:SetAutoSize(true);
		panelList:SetPadding(4);
		panelList:SetSpacing(4);
		
		permaForm:SetName("Permanent");
		permaForm:AddItem(panelList);
		permaForm:SetPadding(4);
		
		self.panelList:AddItem(permaForm);
	end;
	
	if (#goodPanels > 0) then
		local goodForm = vgui.Create("DForm", self);
		local panelList = vgui.Create("DPanelList", self);
		
		for k, v in pairs(goodPanels) do
			self.currentAugment = v;
			panelList:AddItem( vgui.Create("aura_Augment") );
		end;
		
		panelList:SetAutoSize(true);
		panelList:SetPadding(4);
		panelList:SetSpacing(4);
		
		goodForm:SetName("Good Karma");
		goodForm:AddItem(panelList);
		goodForm:SetPadding(4);
		
		self.panelList:AddItem(goodForm);
	end;
	
	if (#evilPanels > 0) then
		local evilForm = vgui.Create("DForm", self);
		local panelList = vgui.Create("DPanelList", self);
		
		for k, v in pairs(evilPanels) do
			self.currentAugment = v;
			panelList:AddItem( vgui.Create("aura_Augment") );
		end;
		
		panelList:SetAutoSize(true);
		panelList:SetPadding(4);
		panelList:SetSpacing(4);
		
		evilForm:SetName("Evil Karma");
		evilForm:AddItem(panelList);
		evilForm:SetPadding(4);
		
		self.panelList:AddItem(evilForm);
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

vgui.Register("aura_Augments", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 34);
	
	local colorWhite = openAura.option:GetColor("white");
	
	self.augment = openAura.augments:GetPanel().currentAugment;
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.augment.name);
	self.nameLabel:SetTextColor(colorWhite);
	self.nameLabel:SizeToContents();
	
	self.costLabel = vgui.Create("DLabel", self); 
	self.costLabel:SetText("Get this augment for "..FORMAT_CASH(self.augment.cost)..".");
	self.costLabel:SetTextColor(colorWhite);
	self.costLabel:SizeToContents();
	
	self.spawnIcon = vgui.Create("DImageButton", self);
	self.spawnIcon:SetToolTip(self.augment.description);
	self.spawnIcon:SetSize(32, 32);
	
	if ( openAura.augments:Has(self.augment.name, true) ) then
		self.spawnIcon:SetImage("aperture/augments/augmented");
		self.costLabel:SetText("You have this augment.");
		self.costLabel:SizeToContents();
	else
		self.spawnIcon:SetImage(self.augment.image);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		openAura:StartDataStream("GetAugment", self.augment.uniqueID);
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(32, 32);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(32, 32);
	self.nameLabel:SetPos(36, 2);
	self.costLabel:SetPos( 36, 32 - self.costLabel:GetTall() );
	self.nameLabel:SizeToContents();
	self.costLabel:SizeToContents();
end;

vgui.Register("aura_Augment", PANEL, "DPanel");