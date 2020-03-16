--[[
Name: "cl_character.lua".
Product: "kuroScript".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.loading = true;
	self.characterForms = {};
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	
	-- Set some information.
	self.createCharacter = vgui.Create("DButton", self);
	self.createCharacter:SetDisabled(true);
	self.createCharacter:SetWide(kuroScript.character.width);
	self.createCharacter:SetText("Loading Characters");
	
	-- Called when the button is clicked.
	function self.createCharacter.DoClick(button)
		kuroScript.character.panel:SetVisible(false);
		
		-- Set some information.
		kuroScript.character.stepOne = vgui.Create("ks_CharacterStepOne");
		kuroScript.character.stepOne:MakePopup();
	end;
	
	-- Add an item to the panel list.
	self.panelList:AddItem(self.createCharacter);
end;

-- Called each frame.
function PANEL:Think()
	if (table.Count( kuroScript.character.GetAll() ) == 0) then
		kuroScript.character.height = 26;
		kuroScript.character.width = 300;
	else
		local height = 0;
		local width = 300;
		
		-- Loop through each value in a table.
		for k, v in pairs( kuroScript.character.GetAll() ) do
			if (v.panel and v.panel:IsValid() and v.panel.realSize) then
				if (v.panel.realSize > width) then
					width = v.panel.realSize;
				end;
			end;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(self.characterForms) do
			height = height + v:GetTall() + 3;
		end;
		
		-- Set some information.
		kuroScript.character.height = math.min( 26 + height, (ScrH() - ScrH() / 10) );
		kuroScript.character.width = math.min( width, (ScrW() - ScrW() / 10) );
	end;
	
	-- Set some information.
	self:SetSize(kuroScript.character.width, kuroScript.character.height);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
	
	-- Set some information.
	local maximum = kuroScript.player.GetMaximumCharacters();
	
	-- Check if a statement is true.
	if (self.loading) then
		self.createCharacter:SetDisabled(true);
		self.createCharacter:SetText("Loading Characters");
	else
		self.createCharacter:SetText("Create Character");
		
		-- Check if a statement is true.
		if (table.Count( kuroScript.character.GetAll() ) >= maximum) then
			self.createCharacter:SetDisabled(true);
		else
			self.createCharacter:SetDisabled(false);
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("ks_CharacterMenu", PANEL, "DFrame");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.tagLabels = {};
	
	-- Set some information.
	self:SetSize(kuroScript.character.width, 42);
	
	-- Set some information.
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetTextColor(COLOR_WHITE);
	self.nameLabel:SetText("N/A");
	
	-- Set some information.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:SetModel("");
	self.spawnIcon:SetIconSize(32);
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local options = {};
		
		-- Check if a statement is true.
		if (!self.banned) then
			options["Use"] = function()
				datastream.StreamToServer( "ks_InteractCharacter", {characterID = self.characterID, action = "use"} );
			end;
		end;
		
		-- Set some information.
		options["Delete"] = {};
		options["Delete"]["No"] = function() end;
		options["Delete"]["Yes"] = function()
			datastream.StreamToServer( "ks_InteractCharacter", {characterID = self.characterID, action = "delete"} );
		end;
		
		-- Call a gamemode hook.
		hook.Call("GetCustomCharacterOptions", kuroScript.frame, self.characterTable, options, menu);
		
		-- Add a menu from data.
		kuroScript.frame:AddMenuFromData(nil, options, function(menu, key, value)
			menu:AddOption(key, function()
				datastream.StreamToServer( "ks_InteractCharacter", {characterID = self.characterID, action = value} );
			end);
		end);
	end;
end;

-- Called each frame.
function PANEL:Think()
	local x, y = self:AdjustPosition(self.spawnIcon, 4, 5);
	local k, v;
	
	-- Set some information.
	self.spawnIcon:SetModel(self.model);
	self.spawnIcon:SetToolTip( hook.Call("GetCharacterPanelToolTip", kuroScript.frame, self, self.class, self.characterTable) );
	
	-- Set some information.
	self.nameLabel:SetPos(x, y);
	self.nameLabel:SetText(self.name);
	self.nameLabel:SizeToContents();
	
	-- Loop through each value in a table.
	for k, v in pairs(self.tagLabels) do
		v[1]:SetPos(x, 24);
		v[1]:SizeToContents();
		v[2]:SizeToContents();
		
		-- Set some information.
		x = x + v[1]:GetWide() + 4;
		
		-- Check if a statement is true.
		if (k != #self.tagLabels) then
			v[2]:SetVisible(true);
			v[2]:SetPos(x, 24);
			
			-- Set some information.
			x = x + v[2]:GetWide() + 4;
		else
			v[2]:SetVisible(false);
		end;
	end;
	
	-- Set some information.
	self.realSize = math.max(x + 16, self.nameLabel.x + self.nameLabel:GetWide() + 12);
	
	-- Set some information.
	local cursorHasEntered = true;
	local rx, ry = self:GetRealPos();
	local x, y = gui.MousePos();
	
	-- Check if a statement is true.
	if (x >= rx and y >= ry) then
		if ( x <= rx + self:GetWide() and y <= ry + self:GetTall() ) then
			if (self:GetParent().cursorHasEntered != self) then
				if (self:GetParent().cursorHasEntered) then
					local panel = self:GetParent().cursorHasEntered;
					
					-- Check if a statement is true.
					if ( panel and panel:IsValid() ) then
						hook.Call("OnCursorExitCharacterPanel", kuroScript.frame, panel, panel.characterTable);
					end;
				end;
				
				-- Set some information.
				self:GetParent().cursorHasEntered = self;
				
				-- Call a gamemode hook.
				hook.Call("OnCursorEnterCharacterPanel", kuroScript.frame, self, self.characterTable);
			end;
		else
			cursorHasEntered = false;
		end;
	else
		cursorHasEntered = false;
	end;
	
	-- Check if a statement is true.
	if (self:GetParent().cursorHasEntered == self and !cursorHasEntered) then
		hook.Call("OnCursorExitCharacterPanel", kuroScript.frame, self, self.characterTable);
		
		-- Set some information.
		self:GetParent().cursorHasEntered = nil;
	end;
end;

-- A function to adjust a position.
function PANEL:AdjustPosition(panel, x, y)
	panel:SetPos(x, y);
	
	-- Return the position.
	return x + panel:GetWide() + 8, y;
end;

-- A function to get the real position.
function PANEL:GetRealPos()
	local parent = self:GetParent();
	local x = self.x;
	local y = self.y;
	
	-- Loop while a statement is true.
	while (parent) do
		x = parent.x + x;
		y = parent.y + y;
		
		-- Set some information.
		parent = parent:GetParent();
	end;
	
	-- Return the real position.
	return x, y;
end;

-- A function to add a tag.
function PANEL:AddTag(text, color)
	local tagLabel = vgui.Create("DLabel", self);
	local seperator = vgui.Create("DLabel", self);
	
	-- Check if a statement is true.
	if (type(color) == "boolean") then
		tagLabel:SetTextColor(COLOR_WHITE);
	else
		tagLabel:SetTextColor(color);
		tagLabel.isColored = true;
	end;
	
	-- Set some information.
	tagLabel:SetText(text);
	seperator:SetText("|");
	seperator:SetTextColor(COLOR_WHITE);
	
	-- Set some information.
	self.tagLabels[#self.tagLabels + 1] = {
		tagLabel,
		seperator
	};
end;
	
-- Register the panel.
vgui.Register("ks_CharacterPanel", PANEL, "DPanel");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	-- Set some information.
	self.model = "";
	self.class = kuroScript.character.stepOne.class;
	
	-- Set some information.
	self.backButton = vgui.Create("DButton", self);
	self.backButton:SetText("Back");
	self.backButton:SetWide(408);
	
	-- Called when the button is clicked.
	function self.backButton.DoClick(button)
		self:Remove(); kuroScript.character.stepTwo = nil;
		
		-- Set some information.
		kuroScript.character.panel:SetVisible(true);
		kuroScript.character.fault = nil;
	end;
	
	-- Check if a statement is true.
	if (!kuroScript.class.stored[self.class].GetName) then
		self.nameForm = vgui.Create("DForm");
		self.nameForm:SetPadding(4);
		self.nameForm:SetName("Name");
		
		-- Check if a statement is true.
		if (kuroScript.class.stored[self.class].useFullName) then
			self.fullNameTextEntry = self.nameForm:TextEntry("Full Name");
		else
			self.forenameTextEntry = self.nameForm:TextEntry("Forename");
			self.surnameTextEntry = self.nameForm:TextEntry("Surname");
		end;
	end;
	
	-- Check if a statement is true.
	if (!kuroScript.class.stored[self.class].GetModel) then
		self.appearanceForm = vgui.Create("DForm");
		self.appearanceForm:SetPadding(4);
		self.appearanceForm:SetName("Appearance");
		
		-- Set some information.
		self.modelItemsList = vgui.Create("DPanelList", self);
		self.modelItemsList:SetAutoSize(true);
		self.modelItemsList:SetSpacing(2);
		self.modelItemsList:EnableHorizontal(true);
		self.modelItemsList:EnableVerticalScrollbar(true);
		
		-- Add an item to the panel list.
		self.appearanceForm:AddItem(self.modelItemsList);
	end;
	
	-- Set some information.
	self.okayButton = vgui.Create("DButton", self);
	self.okayButton:SetText("Okay");
	self.okayButton:SetWide(408);
	
	-- Called when the button is clicked.
	function self.okayButton.DoClick(button)
		local info = {
			gender = self.gender,
			class = self.class
		};
		
		-- Check if a statement is true.
		if (!kuroScript.class.stored[self.class].GetName) then
			if ( self.fullNameTextEntry and self.fullNameTextEntry:IsValid() ) then
				info.fullName = self.fullNameTextEntry:GetValue();
			else
				info.forename = self.forenameTextEntry:GetValue();
				info.surname = self.surnameTextEntry:GetValue();
			end;
		end;
		
		-- Check if a statement is true.
		if (!kuroScript.class.stored[self.class].GetModel) then
			info.model = self.model;
		end;
		
		-- Start a data stream.
		datastream.StreamToServer("ks_CreateCharacter", info);
	end;
	
	-- Check if a statement is true.
	if (!kuroScript.class.stored[self.class].GetName) then
		self.panelList:AddItem(self.nameForm);
	end;
	
	-- Check if a statement is true.
	if (!kuroScript.class.stored[self.class].GetModel) then
		self.panelList:AddItem(self.appearanceForm);
	end;
	
	-- Add some panels to the list.
	self.panelList:AddItem(self.backButton);
	self.panelList:AddItem(self.okayButton);
end;

-- A function to set the information
function PANEL:SetInfo(class, gender)
	for k, v in pairs(kuroScript.class.stored) do
		if (v.name == class) then
			self.class = class;
			self.gender = gender;
			
			-- Check if a statement is true.
			if (self.modelItemsList) then
				if ( v.models[ string.lower(gender) ] ) then
					for k2, v2 in pairs( v.models[ string.lower(gender) ] ) do
						local spawnIcon = vgui.Create("SpawnIcon");
						
						-- Called when the spawn icon is clicked.
						function spawnIcon.DoClick(spawnIcon)
							self.model = v2;
						end;
						
						-- Set some information.
						spawnIcon:SetModel(v2);
						
						-- Add an item to the panel list.
						self.modelItemsList:AddItem(spawnIcon);
					end;
				end;
			end;
		end;
	end;
end;

-- Called each frame.
function PANEL:Think()
	local height = 54;
	
	-- Check if a statement is true.
	if (self.nameForm) then
		height = height + self.nameForm:GetTall() + 4;
	end;
	
	-- Check if a statement is true.
	if (self.appearanceForm) then
		height = height + self.appearanceForm:GetTall();
	else
		height = height - 4;
	end;
	
	-- Set some information.
	self:SetSize(406, height);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("ks_CharacterStepTwo", PANEL, "DFrame");

-- Set some information.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local k, v;
	
	-- Set some information.
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	
	-- Set some information.
	self.backButton = vgui.Create("DButton", self);
	self.backButton:SetText("Back");
	self.backButton:SetWide(400);
	
	-- Called when the button is clicked.
	function self.backButton.DoClick(button)
		self:Remove(); kuroScript.character.stepOne = nil;
		
		-- Set some information.
		kuroScript.character.panel:SetVisible(true);
		kuroScript.character.fault = nil;
	end;
	
	-- Set some information.
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetPadding(4);
	self.settingsForm:SetName("Settings");
	
	-- Set some information.
	self.classMultiChoice = self.settingsForm:MultiChoice("Class");
	self.classMultiChoice:SetEditable(false);
	
	-- Called when an option is selected.
	self.classMultiChoice.OnSelect = function(multiChoice, index, value, data)
		for k, v in pairs(kuroScript.class.stored) do
			if (v.name == value) then
				if ( self.genderMultiChoice and self.genderMultiChoice:IsValid() ) then
					self.genderMultiChoice:Clear();
				else
					self.genderMultiChoice = self.settingsForm:MultiChoice("Gender");
					self.genderMultiChoice:SetEditable(false);
				end;
				
				-- Check if a statement is true.
				if (v.singleGender) then
					self.genderMultiChoice:AddChoice(v.singleGender);
				else
					self.genderMultiChoice:AddChoice(GENDER_FEMALE);
					self.genderMultiChoice:AddChoice(GENDER_MALE);
				end;
				
				-- Break the loop.
				break;
			end;
		end;
	end;
	
	-- Set some information.
	self.okayButton = vgui.Create("DButton", self);
	self.okayButton:SetText("Okay");
	self.okayButton:SetWide(400);
	
	-- Called when the button is clicked.
	function self.okayButton.DoClick(button)
		if ( self.genderMultiChoice and self.genderMultiChoice:IsValid() ) then
			local class = self.classMultiChoice.TextEntry:GetValue();
			local gender = self.genderMultiChoice.TextEntry:GetValue();
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.class.stored) do
				if (v.name == class) then
					if ( kuroScript.class.IsGenderValid(class, gender) ) then
						if (kuroScript.class.stored[class].GetName and kuroScript.class.stored[class].GetModel) then
							datastream.StreamToServer( "ks_CreateCharacter", {
								gender = gender,
								class = class
							} );
						else
							kuroScript.character.stepOne.class = class;
							
							-- Set some information.
							kuroScript.character.stepTwo = vgui.Create("ks_CharacterStepTwo");
							kuroScript.character.stepTwo:SetInfo(class, gender);
							kuroScript.character.stepTwo:MakePopup();
							
							-- Remove the panel.
							self:Remove(); kuroScript.character.stepOne = nil;
						end;
					end;
					
					-- Break the loop.
					break;
				end;
			end;
		end;
	end;
	
	-- Set some information.
	local classes = {};
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.class.stored) do
		if ( !v.whitelist or table.HasValue(kuroScript.character.whitelisted, v.name) ) then
			classes[#classes + 1] = v.name;
		end;
	end;
	
	-- Sort the classes.
	table.sort(classes, function(a, b) return a < b; end);
	
	-- Loop through each value in a table.
	for k, v in pairs(classes) do
		self.classMultiChoice:AddChoice(v);
	end;
	
	-- Add some panels to the list.
	self.panelList:AddItem(self.settingsForm);
	self.panelList:AddItem(self.backButton);
	self.panelList:AddItem(self.okayButton);
end;

-- Called each frame.
function PANEL:Think()
	self:SetSize(400, self.settingsForm:GetTall() + 54);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("ks_CharacterStepOne", PANEL, "DFrame");

-- Hook a user message.
usermessage.Hook("ks_CharacterRemove", function(msg)
	local characters = kuroScript.character.GetAll();
	
	-- Check if a statement is true.
	if (table.Count(characters) > 0) then
		local characterID = msg:ReadShort();
		
		-- Check if a statement is true.
		if ( characters[characterID] ) then
			characters[characterID] = nil;
			
			-- Check if a statement is true.
			if ( !kuroScript.character.IsPanelLoading() ) then
				kuroScript.character.RefreshPanel();
			end;
		end;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_CharacterAdd", function(handler, uniqueID, rawData, procData)
	local characters = kuroScript.character.GetAll();
	
	-- Check if a statement is true.
	if (procData.banned) then
		procData.tags["Banned"] = Color(255, 0, 0, 255);
	end;
	
	-- Set some information.
	characters[procData.characterID] = procData;
	
	-- Check if a statement is true.
	if ( !kuroScript.character.IsPanelLoading() ) then
		kuroScript.character.RefreshPanel();
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_CharacterMenu", function(handler, uniqueID, rawData, procData)
	if ( !g_LocalPlayer:HasInitialized() ) then
		if (procData) then
			if ( kuroScript.character.panel and kuroScript.character.panel:IsValid() ) then
				kuroScript.character.panel.loading = nil;
				
				-- Refresh the character panel.
				kuroScript.character.RefreshPanel();
			end;
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_CharacterFinish", function(msg)
	if ( msg:ReadBool() ) then
		kuroScript.character.SetPanelOpen(false, true);
		
		-- Set some information.
		kuroScript.character.fault = nil;
	else
		kuroScript.character.fault = msg:ReadString();
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_CharacterClose", function(msg)
	kuroScript.character.SetPanelOpen(false);
end);

-- Hook a user message.
usermessage.Hook("ks_CharacterMenu", function(msg)
	if ( !g_LocalPlayer:HasInitialized() ) then
		if ( !msg:ReadBool() ) then
			kuroScript.character.SetPanelOpen(true);
		elseif ( kuroScript.character.panel and kuroScript.character.panel:IsValid() ) then
			kuroScript.character.panel.loading = nil;
			
			-- Refresh the character panel.
			kuroScript.character.RefreshPanel();
		end;
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_CharacterWhitelist", function(msg)
	local class = msg:ReadString();
	
	-- Check if a statement is true.
	if ( !table.HasValue(kuroScript.character.whitelisted, class) ) then
		kuroScript.character.whitelisted[#kuroScript.character.whitelisted + 1] = class;
	end;
end);