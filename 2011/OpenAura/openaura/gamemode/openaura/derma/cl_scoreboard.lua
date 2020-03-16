--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle("Scoreboard");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.scoreboard = self;
	openAura.scoreboard:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local availableClasses = {};
	local classes = {};
	
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			local class = openAura.plugin:Call("GetPlayerScoreboardClass", v);
			
			if (class) then
				if ( !availableClasses[class] ) then
					availableClasses[class] = {};
				end;
				
				if ( openAura.plugin:Call("PlayerShouldShowOnScoreboard", v) ) then
					availableClasses[class][#availableClasses[class] + 1] = v;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return openAura.plugin:Call("ScoreboardSortClassPlayers", k, a, b);
		end);
		
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	if (table.Count(classes) > 0) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Clicking a player's model icon may bring up some options.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(classes) do
			local characterForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			for k2, v2 in pairs(v.players) do
				self.currentAvatarImage = true;
				self.currentSteamName = v2:SteamName();
				self.currentFaction = openAura.player:GetFaction(v2);
				self.currentPlayer = v2;
				self.currentClass = _team.GetName( v2:Team() );
				self.currentModel = v2:GetModel();
				self.currentSkin = v2:GetSkin();
				self.currentName = v2:Name();
				
				panelList:AddItem( vgui.Create("aura_ScoreboardItem", self) ) ;
			end;
			
			self.panelList:AddItem(characterForm);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			characterForm:SetName(v.name);
			characterForm:AddItem(panelList);
			characterForm:SetPadding(4); 
		end;
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("There are no players to display.");
			label:SetInfoColor("orange");
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
	self:InvalidateLayout(true);
end;

vgui.Register("aura_Scoreboard", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	SCOREBOARD_PANEL = true;
		self:SetSize(self:GetParent():GetWide(), 32);
		
		local colorWhite = openAura.option:GetColor("white");
		local parent = self:GetParent();
		local info = {
			doesRecognise = openAura.player:DoesRecognise(parent.currentPlayer),
			avatarImage = parent.currentAvatarImage,
			steamName = parent.currentSteamName,
			faction = parent.currentFaction,
			player = parent.currentPlayer,
			class = parent.currentClass,
			model = parent.currentModel,
			skin = parent.currentSkin,
			name = parent.currentName
		};
		
		info.text = openAura.plugin:Call("GetPlayerScoreboardText", info.player);
		
		openAura.plugin:Call("ScoreboardAdjustPlayerInfo", info);
		
		self.toolTip = info.toolTip;
		self.player = info.player;
		
		self.nameLabel = vgui.Create("DLabel", self);
		self.nameLabel:SetText(info.name);
		self.nameLabel:SetTextColor(colorWhite);
		self.nameLabel:SizeToContents();
		
		self.factionLabel = vgui.Create("DLabel", self); 
		self.factionLabel:SetText(info.faction);
		self.factionLabel:SetTextColor(colorWhite);
		self.factionLabel:SizeToContents();
		
		if (type(info.text) == "string") then
			self.factionLabel:SetText(info.text);
			self.factionLabel:SizeToContents();
		end;
		
		if (info.doesRecognise) then
			self.spawnIcon = vgui.Create("SpawnIcon", self);
			self.spawnIcon:SetModel(info.model, info.skin);
			self.spawnIcon:SetIconSize(30);
		else
			self.spawnIcon = vgui.Create("DImageButton", self);
			self.spawnIcon:SetImage("openaura/unknown");
			self.spawnIcon:SetSize(30, 30);
		end;
		
		-- Called when the spawn icon is clicked.
		function self.spawnIcon.DoClick(spawnIcon)
			local options = {};
				openAura.plugin:Call("GetPlayerScoreboardOptions", info.player, options);
			openAura:AddMenuFromData(nil, options);
		end;
		
		self.avatarImage = vgui.Create("AvatarImage", self);
		self.avatarImage:SetSize(30, 30);
		
		if (info.avatarImage) then
			self.avatarImage:SetPlayer(info.player);
			self.avatarImage:SetToolTip("This player's name is "..info.steamName..".\nThis player's Steam ID is "..info.player:SteamID()..".");
		end;
	SCOREBOARD_PANEL = nil;
end;

-- Called each frame.
function PANEL:Think()
	if ( IsValid(self.player) ) then
		if (self.toolTip) then
			self.spawnIcon:SetToolTip(self.toolTip);
		else
			self.spawnIcon:SetToolTip("This player's ping is "..self.player:Ping()..".");
		end;
	end;
	
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(30, 30);
end;
-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.factionLabel:SizeToContents();
	
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(30, 30);
	self.avatarImage:SetPos(40, 1);
	self.avatarImage:SetSize(30, 30);
	
	self.nameLabel:SetPos(80, 2);
	self.factionLabel:SetPos( 80, 30 - self.factionLabel:GetTall() );
end;

vgui.Register("aura_ScoreboardItem", PANEL, "DPanel");