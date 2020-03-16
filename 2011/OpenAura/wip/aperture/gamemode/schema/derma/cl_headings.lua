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
	self:SetTitle("Headings");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.schema.headingsPanel = self;
	
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
	local bUnlocked = false;
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("Some trophies unlock new headings when you achieve them.");
		label:SetInfoColor("blue");
	self.panelList:AddItem(label);
	
	for k, v in pairs( openAura.trophy:GetAll() ) do
		if ( v.unlockHeading and openAura.trophies:Has(k) ) then
			local label = vgui.Create("aura_InfoText", self);
				label:SetText( string.Replace( v.unlockHeading, "%n", openAura.Client:Name() ) );
				label:SetButton(true);
				label:SetInfoColor("orange");
				label:SetShowIcon(false);
			self.panelList:AddItem(label);
			
			if (openAura.Client:GetSharedVar("heading") == k) then
				label:SetInfoColor("green");
			end;
			
			-- Called when the button is clicked.
			function label.DoClick(button)
				Derma_Query("Are you sure that you want to set your heading to this?", "Set your title.", "Yes", function()
					openAura:StartDataStream("SetHeading", k);
				end, "No", function() end);
			end;
			
			bUnlocked = true;
		end;
	end;
	
	if (!bUnlocked) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("You have not unlocked any headings yet, try achieving some trophies!");
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
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

vgui.Register("aura_Headings", PANEL, "DFrame");