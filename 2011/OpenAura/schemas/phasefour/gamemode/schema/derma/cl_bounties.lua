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
	self:SetTitle("Bounties");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.schema.bountyPanel = self;
	
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
	
	local highestBounties = {};
	local bountyPlayers = {};
	
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() and v:IsWanted() ) then
			bountyPlayers[#bountyPlayers + 1] = {
				bounty = v:GetBounty(),
				player = v
			};
		end;
	end;
	
	table.sort(bountyPlayers, function(a, b)
		return a.bounty > b.bounty;
	end);
	
	for k, v in ipairs(bountyPlayers) do
		if (k <= 10) then
			highestBounties[#highestBounties + 1] = v;
		end;
	end;
	
	if (#highestBounties > 0) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("You can collect the bounty reward by killing the victim.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("This list only shows the top ten highest bounties.");
			label:SetInfoColor("orange");
		self.panelList:AddItem(label);
		
		local bountyForm = vgui.Create("DForm", self);
		local panelList = vgui.Create("DPanelList", self);
		
		for k, v in ipairs(highestBounties) do
			local label = vgui.Create("aura_InfoText", self);
				label:SetText( v.player:Name() );
				label:SetToolTip("This player has a bounty of "..FORMAT_CASH(v.bounty, nil, true)..".");
				label:SetInfoColor( _team.GetColor( v.player:Team() ) );
			panelList:AddItem(label);
		end;
		
		panelList:SetAutoSize(true);
		panelList:SetPadding(4);
		panelList:SetSpacing(4);
		
		bountyForm:SetName("Top ten bounties");
		bountyForm:AddItem(panelList);
		bountyForm:SetPadding(4);
		
		self.panelList:AddItem(bountyForm);
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("No bounties have currently been assigned to anyone.");
			label:SetInfoColor("orange");
		self.panelList:AddItem(label);
	end;
	
	local addForm = vgui.Create("DForm", self);
	addForm:SetName("Add a bounty");
	addForm:SetPadding(4);
	
	local textEntry = addForm:TextEntry("Name");
		textEntry:SetToolTip("Type part of the player's name here.");
	local bountySlider = addForm:NumSlider("Bounty", nil, 100, 10000, 0);
	local okayButton = addForm:Button("Okay");
		bountySlider:SetValue(100);
	
	-- Called when the button is clicked.
	function okayButton.DoClick(okayButton)
		openAura:StartDataStream( "BountyAdd", {
			name = textEntry:GetValue(),
			bounty = bountySlider:GetValue()
		} );
	end;
	
	self.panelList:AddItem(addForm);
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

vgui.Register("aura_Bounties", PANEL, "DFrame");