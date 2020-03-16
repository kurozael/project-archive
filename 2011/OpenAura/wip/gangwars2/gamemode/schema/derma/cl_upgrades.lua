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
	self:SetTitle("Upgrades");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.upgrades.panel = self;
	
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
	
	local categories = {};
	
	for k, v in pairs( openAura.upgrade:GetAll() ) do
		categories[v.category] = categories[v.category] or {};
		categories[v.category][#categories[v.category] + 1] = v;
	end;
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Upgrades affect your character forever once purchased.");
		label:SetInfoColor("blue");
		label:SetShowIcon(false);
	self.panelList:AddItem(label);
	
	if (#categories > 0) then
		for k, v in ipairs(categories) do
			local categoryForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			table.sort(v, function(a, b) return a.cost > b.cost; end);
			
			for k2, v2 in pairs(v) do
				self.currentUpgrade = v2;
				panelList:AddItem( vgui.Create("aura_Upgrade") );
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			categoryForm:SetName(k);
			categoryForm:AddItem(panelList);
			categoryForm:SetPadding(4);
			
			self.panelList:AddItem(categoryForm);
		end;
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

vgui.Register("aura_Upgrades", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(), 34);
	
	local colorWhite = openAura.option:GetColor("white");
	
	self.upgrade = openAura.upgrades:GetPanel().currentUpgrade;
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.upgrade.name);
	self.nameLabel:SetTextColor(colorWhite);
	self.nameLabel:SizeToContents();
	
	self.costLabel = vgui.Create("DLabel", self); 
	self.costLabel:SetText("Get this upgrade for "..FORMAT_CASH(self.upgrade.cost)..".");
	self.costLabel:SetTextColor(colorWhite);
	self.costLabel:SizeToContents();
	
	self.spawnIcon = vgui.Create("DImageButton", self);
	self.spawnIcon:SetToolTip(self.upgrade.description);
	self.spawnIcon:SetSize(32, 32);
	
	if ( openAura.upgrades:Has(self.upgrade.name, true) ) then
		self.spawnIcon:SetImage("upgrades/upgraded");
		self.costLabel:SetText("You have this upgrade.");
		self.costLabel:SizeToContents();
	else
		self.spawnIcon:SetImage(self.upgrade.image);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		openAura:StartDataStream("GetUpgrade", self.upgrade.uniqueID);
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

vgui.Register("aura_Upgrade", PANEL, "DPanel");