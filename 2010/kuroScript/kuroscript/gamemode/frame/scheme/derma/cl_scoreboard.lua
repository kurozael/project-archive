--[[
Name: "cl_scoreboard.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, kuroScript.menu.height);
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	-- Set some information.
	kuroScript.scoreboard = self;
	kuroScript.scoreboard:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	-- Set some information.
	local availableClasses = {};
	local classes = {};
	local k2, v2;
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			local class = hook.Call("GetPlayerScoreboardClass", kuroScript.frame, v);
			
			-- Check if a statement is true.
			if (class) then
				if ( !availableClasses[class] ) then
					availableClasses[class] = {};
				end;
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerShouldShowOnScoreboard", kuroScript.frame, v) ) then
					availableClasses[class][#availableClasses[class] + 1] = v;
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return hook.Call("ScoreboardSortClassPlayers", kuroScript.frame, k, a, b);
		end);
		
		-- Check if a statement is true.
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	-- Sort the classes.
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	-- Set some information.
	local scoreboardForm = vgui.Create("DForm", self);
	
	-- Add an item to the panel list.
	self.panelList:AddItem(scoreboardForm);
	
	-- Set some information.
	scoreboardForm:SetName("Scoreboard");
	scoreboardForm:SetPadding(4);
	
	-- Set some information.
	self.latencyLabel = vgui.Create("ks_ScoreboardText", self);
	self.latencyLabel:SetText("Average Latency: 0.");
	self.latencyLabel:SetTextColor(COLOR_WHITE);
	self.latencyLabel:SizeToContents();

	-- Add an item to the form.
	scoreboardForm:AddItem(self.latencyLabel);
	
	-- Check if a statement is true.
	if (table.Count(classes) > 0) then
		for k, v in pairs(classes) do
			local collapsibleCategory = vgui.Create("DCollapsibleCategory", self);
			local panelList = vgui.Create("DPanelList", self);
			
			-- Loop through each value in a table.
			for k2, v2 in pairs(v.players) do
				self.currentAvatarImage = true;
				self.currentSteamName = v2:SteamName();
				self.currentPlayer = v2;
				self.currentClass = kuroScript.player.GetClass(v2);
				self.currentModel = v2:GetModel();
				self.currentSkin = v2:GetSkin();
				self.currentName = v2:Name();
				
				-- Add an item to the panel list.
				panelList:AddItem( vgui.Create("ks_ScoreboardItem", self) ) ;
			end;
			
			-- Add an item to the panel list.
			self.panelList:AddItem(collapsibleCategory);
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Set some information.
			collapsibleCategory:SetLabel(v.name);
			collapsibleCategory:SetPadding(4); 
			collapsibleCategory:SetContents(panelList);
			collapsibleCategory:SetCookieName("ks_Scoreboard_"..v.name);
		end;
	else
		local label = vgui.Create("ks_ScoreboardText", self);
		
		-- Set some information.
		label:SetText("There are currently no characters roleplaying.");
		label:SetTextColor(COLOR_WHITE);
		label:SizeToContents();
		
		-- Add an item to the form.
		scoreboardForm:AddItem(label);
	end;
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (kuroScript.menu.GetActiveTab() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected as a tab.
function PANEL:OnTabSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Called each frame.
function PANEL:Think()
	if ( self.latencyLabel and self.latencyLabel:IsValid() ) then
		local latency = 0;
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if ( v:HasInitialized() ) then
				latency = latency + v:Ping();
			end;
		end;
		
		-- Set some information.
		self.latencyLabel:SetText("Average Latency: "..math.Round( latency / #g_Player.GetAll() )..".");
		self.latencyLabel:SizeToContents();
	end;
end;

-- Register the panel.
vgui.Register("ks_Scoreboard", PANEL, "Panel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(kuroScript.menu.width, 42);
	self:SetPos(1, 5);
	
	-- Set some information.
	local parent = self:GetParent();
	local info = {
		avatarImage = parent.currentAvatarImage,
		steamName = parent.currentSteamName,
		player = parent.currentPlayer,
		class = parent.currentClass,
		model = parent.currentModel,
		skin = parent.currentSkin,
		name = parent.currentName
	};
	
	-- Set some information.
	info.text = hook.Call("GetPlayerScoreboardText", kuroScript.frame, info.player);
	
	-- Call a gamemode hook.
	hook.Call("ScoreboardAdjustPlayerInfo", kuroScript.frame, info);
	
	-- Set some information.
	self.toolTip = info.toolTip;
	self.player = info.player;
	
	-- Set some information.
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetText(info.name);
	self.nameLabel:SetTextColor(COLOR_WHITE);
	self.nameLabel:SizeToContents();
	
	-- Set some information.
	self.classLabel = vgui.Create("DLabel", self); 
	self.classLabel:SetText(info.class);
	self.classLabel:SetTextColor(COLOR_WHITE);
	self.classLabel:SizeToContents();
	
	-- Check if a statement is true.
	if (type(info.text) == "string") then
		self.classLabel:SetText(info.text);
		self.classLabel:SizeToContents();
	end;
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:SetModel(info.model, info.skin);
	self.spawnIcon:SetIconSize(32);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local options = {};
		
		-- Call a gamemode hook.
		hook.Call("GetPlayerScoreboardOptions", kuroScript.frame, info.player, options);
		
		-- Add a menu from data.
		kuroScript.frame:AddMenuFromData(nil, options);
	end;
	
	-- Set some information.
	self.avatarImage = vgui.Create("AvatarImage", self);
	self.avatarImage:SetSize(32, 32);
	
	-- Check if a statement is true.
	if (info.avatarImage) then
		self.avatarImage:SetPlayer(info.player);
		self.avatarImage:SetToolTip(info.steamName);
	end;
end;

-- Called each frame.
function PANEL:Think()
	if ( ValidEntity(self.player) ) then
		if (self.toolTip) then
			self.spawnIcon:SetToolTip(self.toolTip);
		else
			self.spawnIcon:SetToolTip("Latency: "..self.player:Ping()..".");
		end;
	end;
end;

-- A function to adjust a position.
function PANEL:AdjustPosition(panel, x, y)
	panel:SetPos(x, y);
	
	-- Return the position.
	return x + panel:GetWide() + 8, y;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local x = 4; local y = 5;
	
	-- Set some information.
	x, y = self:AdjustPosition(self.spawnIcon, x, y);
	x, y = self:AdjustPosition(self.avatarImage, x, y);
	
	-- Set some information.
	self.nameLabel:SetPos(x, y);
	self.classLabel:SetPos(x, y + 19);
	self.classLabel:SizeToContents();
end;

-- Register the panel.
vgui.Register("ks_ScoreboardItem", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("N/A");
	self.label:SetTextColor(COLOR_WHITE);
	self.label:SizeToContents();
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(self:GetWide() / 2 - self.label:GetWide() / 2, self:GetTall() / 2 - self.label:GetTall() / 2);
	self.label:SizeToContents();
end;

-- Set some information.
function PANEL:SetText(text)
	self.label:SetText(text);
end;

-- Set some information.
function PANEL:SetTextColor(color)
	self.label:SetTextColor(color);
end;
	
-- Register the panel.
vgui.Register("ks_ScoreboardText", PANEL, "DPanel");