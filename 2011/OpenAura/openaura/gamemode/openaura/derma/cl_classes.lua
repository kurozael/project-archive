--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle("Classes");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	self:Rebuild();
end;

-- A function to get whether the button is visible.
function PANEL:IsButtonVisible()
	for k, v in pairs(openAura.class.stored) do
		if ( openAura:HasObjectAccess(openAura.Client, v) ) then
			if ( openAura.plugin:Call("PlayerCanSeeClass", v) ) then
				if (openAura.Client:Team() != v.index) then
					return true;
				end;
			end;
		end;
	end;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	self.class = nil;
	
	local available = nil;
	local classes = {};
	
	for k, v in pairs(openAura.class.stored) do
		classes[#classes + 1] = v;
	end;
	
	table.sort(classes, function(a, b)
		local aWages = a.wages or 0;
		local bWages = b.wages or 0;
		
		if (aWages == bWages) then
			return a.name < b.name;
		else
			return aWages > bWages;
		end;
	end);
	
	if (#classes > 0) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Classes you choose do not stay with your character.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in ipairs(classes) do
			if ( openAura:HasObjectAccess(openAura.Client, v) ) then
				if ( openAura.plugin:Call("PlayerCanSeeClass", v) ) then
					self.class = openAura.class.stored[v.name];
					self.panelList:AddItem( vgui.Create("aura_ClassesItem", self) );
				end;
			end;
		end;
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("You do not have access to any classes!");
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

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	local team = openAura.Client:Team();
	
	self:InvalidateLayout(true);
	
	if (!self.playerClass) then
		self.playerClass = team;
	end;
	
	if (team != self.playerClass) then
		self.playerClass = team;
		self:Rebuild();
	end;
end;

vgui.Register("aura_Classes", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local colorWhite = openAura.option:GetColor("white");
	
	self.class = self:GetParent().class;
	self:SetSize(self:GetParent():GetWide(), 32);
	
	local players = _team.NumPlayers(self.class.index);
	local limit = openAura.class:GetLimit(self.class.name);
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(self.class.name);
	self.nameLabel:SetTextColor(colorWhite);
	
	self.information = vgui.Create("DLabel", self);
	self.information:SetText("There are "..players.."/"..limit.." characters with this class.");
	self.information:SetTextColor(colorWhite);
	self.information:SizeToContents();
	
	local model, skin = openAura.class:GetAppropriateModel(self.class.index, openAura.Client);
	local info = {
		model = model,
		skin = skin
	};
	
	openAura.plugin:Call("PlayerAdjustClassModelInfo", self.class.index, info);
	
	if (!self.class.image) then
		self.spawnIcon = vgui.Create("SpawnIcon", self);
		self.spawnIcon:SetModel(info.model, info.skin);
		self.spawnIcon:SetToolTip(self.class.description);
		self.spawnIcon:SetIconSize(32);
	else
		self.spawnIcon = vgui.Create("DImageButton", self);
		self.spawnIcon:SetToolTip(self.class.description);
		self.spawnIcon:SetImage(self.class.image);
		self.spawnIcon:SetSize(32, 32);
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		openAura:RunCommand( "SetClass", tonumber(self.class.index) );
	end;
end;

-- Called each frame.
function PANEL:Think()
	if (self.class) then
		self.information:SetText("There are ".._team.NumPlayers(self.class.index).."/"..openAura.class:GetLimit(self.class.name).." characters with this class.");
		self.information:SizeToContents();
	end;
	
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(30, 30);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.nameLabel:SizeToContents();
	self.information:SizeToContents();

	self.spawnIcon:SetPos(1, 1);
	self.nameLabel:SetPos(40, 2);
	self.spawnIcon:SetSize(30, 30);
	self.information:SetPos( 40, 30 - self.information:GetTall() );
end;
	
vgui.Register("aura_ClassesItem", PANEL, "DPanel");