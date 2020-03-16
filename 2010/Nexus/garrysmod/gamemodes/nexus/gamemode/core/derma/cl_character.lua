--[[
Name: "cl_character.lua".
Product: "nexus".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local descriptionFont = nexus.schema.GetFont("schema_description");
	local smallTextFont = nexus.schema.GetFont("menu_text_small");
	local tinyTextFont = nexus.schema.GetFont("menu_text_tiny");
	local bigTextFont = nexus.schema.GetFont("menu_text_big");
	
	self:SetPos(0, 0);
	self:SetSize( ScrW(), ScrH() );
	self:SetDrawOnTop(false);
	self:SetPaintBackground(false);
	self:SetMouseInputEnabled(true);
	self:SetKeyboardInputEnabled(true);
	
	self.faultLabel = vgui.Create("DLabel", self);
	self.faultLabel:SetPos(ScrW() / 2, -128);
	self.faultLabel:SetFont(tinyTextFont);
	self.faultLabel:SetText("");
	self.faultLabel:SizeToContents();
	
	self.titleLabel = vgui.Create("nx_LabelButton", self);
	self.titleLabel:SetFont(bigTextFont);
	self.titleLabel:SetText( string.upper(SCHEMA.name) );
	self.titleLabel:SetAlpha(0);
	self.titleLabel:FadeIn(1);
	self.titleLabel:SetDisabled(true);
	self.titleLabel:SizeToContents();
	self.titleLabel:SetPos( (ScrW() / 2) - (self.titleLabel:GetWide() / 2), ScrH() * 0.1 );
	
	self.subLabel = vgui.Create("nx_LabelButton", self);
	self.subLabel:SetFont(descriptionFont);
	self.subLabel:SetText( string.upper(SCHEMA.description) );
	self.subLabel:SetAlpha(0);
	self.subLabel:FadeIn(1);
	self.subLabel:SetDisabled(true);
	self.subLabel:SizeToContents();
	self.subLabel:SetPos( self.titleLabel.x, self.titleLabel.y + self.titleLabel:GetTall() - 4 );
	
	self.createButton = vgui.Create("nx_LabelButton", self);
	self.createButton:SetFont(smallTextFont);
	self.createButton:SetText("CREATE");
	self.createButton:SetAlpha(0);
	self.createButton:FadeIn(1);
	self.createButton:SetCallback(function(panel)
		if ( table.Count( nexus.character.GetAll() ) >= nexus.player.GetMaximumCharacters() ) then
			nexus.character.SetFault("You cannot create any more characters!");
		else
			self:OpenPanel("nx_CharacterStageOne");
		end;
	end);
	self.createButton:SizeToContents();
	self.createButton:SetMouseInputEnabled(true);
	self.createButton:SetPos(ScrW() * 0.25, ScrH() * 0.9);
	
	self.loadButton = vgui.Create("nx_LabelButton", self);
	self.loadButton:SetFont(smallTextFont);
	self.loadButton:SetText("LOAD");
	self.loadButton:SetAlpha(0);
	self.loadButton:FadeIn(1);
	self.loadButton:SetCallback(function(panel)
		self:OpenPanel("nx_CharacterList", nil, function(panel)
			nexus.character.RefreshPanelList();
		end);
	end);
	self.loadButton:SizeToContents();
	self.loadButton:SetMouseInputEnabled(true);
	self.loadButton:SetPos(ScrW() * 0.75, ScrH() * 0.9);
	
	self.disconnectButton = vgui.Create("nx_LabelButton", self);
	self.disconnectButton:SetFont(smallTextFont);
	self.disconnectButton:SetText("LEAVE");
	self.disconnectButton:SetAlpha(0);
	self.disconnectButton:FadeIn(1);
	self.disconnectButton:SetCallback(function(panel)
		if ( g_LocalPlayer:HasInitialized() ) then
			nexus.character.SetPanelOpen(false);
		else
			RunConsoleCommand("disconnect");
		end;
	end);
	self.disconnectButton:SizeToContents();
	self.disconnectButton:SetPos( (ScrW() / 2) - (self.disconnectButton:GetWide() / 2), ScrH() * 0.9 );
	self.disconnectButton:SetMouseInputEnabled(true);
	
	self.characterModel = vgui.Create("nx_CharacterModel", self);
	self.characterModel:SetAlpha(0);
	self.characterModel:SetModel("models/error.mdl");
	
	self.createTime = SysTime();
end;

-- A function to fade in the model panel.
function PANEL:FadeInModelPanel(model)
	local panel = nexus.character.GetActivePanel();
	local x, y = ScrW() - self.characterModel:GetWide() - 8, 16;
	
	if (panel) then
		x, y = panel.x + panel:GetWide() - 32, panel.y - 32;
	end;
	
	self.characterModel:SetPos(x, y);
	
	if ( self.characterModel:FadeIn(1) ) then
		self:SetModelPanelModel(model);
		
		return true;
	else
		return false;
	end;
end;

-- A function to fade out the model panel.
function PANEL:FadeOutModelPanel()
	self.characterModel:FadeOut(1);
end;

-- A function to set the model panel's model.
function PANEL:SetModelPanelModel(model)
	if (self.characterModel.currentModel != model) then
		self.characterModel.currentModel = model;
		self.characterModel:SetModel(model);
	end;
end;

-- A function to display a character fault.
function PANEL:DisplayCharacterFault(fault)
	if ( !self.animation or !self.animation:Active() ) then
		if (self.faultLabel.y > 0 or !fault) then
			self.animation = Derma_Anim("Fade Panel", self.faultLabel, function(panel, animation, delta, data)
				panel:SetPos( (ScrW() / 2) - (panel:GetWide() / 2), data[1] - (data[2] * delta) );
				
				if (animation.Finished and fault) then
					self:DisplayCharacterFault(fault);
				end;
			end);
			
			if (self.animation) then
				self.animation:Start( 0.4, {self.faultLabel.y, self.faultLabel.y + self.faultLabel:GetTall() + 8} );
			end;
		else
			self.faultLabel:SetText(fault);
			self.faultLabel:SizeToContents();
			
			self.animation = Derma_Anim("Fade Panel", self.faultLabel, function(panel, animation, delta, data)
				panel:SetPos( (ScrW() / 2) - (panel:GetWide() / 2), data[1] + ( ( data[2] - data[1] ) * delta ) );
			end);
			
			if (self.animation) then
				self.animation:Start( 0.4, {self.faultLabel.y, 16} );
			end;
		end;
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu()
	local panel = nexus.character.GetActivePanel();
	
	if (panel) then
		panel:FadeOut(1, function()
			nexus.character.activePanel = nil;
			panel:Remove();
		end);
	end;
	
	self:FadeOutModelPanel();
end;

-- A function to open a panel.
function PANEL:OpenPanel(stage, data, Callback)
	local panel = nexus.character.GetActivePanel();
	
	if (panel) then
		panel:FadeOut(1, function()
			panel:Remove();
			self.stageData = data;
			
			nexus.character.activePanel = vgui.Create(stage, self);
			nexus.character.activePanel:SetAlpha(0);
			nexus.character.activePanel:FadeIn(1);
			nexus.character.activePanel:MakePopup();
			nexus.character.activePanel:SetPos( ScrW() * 0.3, ScrH() * 0.2 );
			
			if (Callback) then
				Callback(nexus.character.activePanel);
			end;
		end);
	else
		self.stageData = data;
		
		nexus.character.activePanel = vgui.Create(stage, self);
		nexus.character.activePanel:SetAlpha(0);
		nexus.character.activePanel:FadeIn(1);
		nexus.character.activePanel:MakePopup();
		nexus.character.activePanel:SetPos( ScrW() * 0.3, ScrH() * 0.2 );
		
		if (Callback) then
			Callback(nexus.character.activePanel);
		end;
	end;
	
	self:FadeOutModelPanel();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Panel", self);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	local characters = table.Count( nexus.character.GetAll() );
	local loading = nexus.character.IsPanelLoading();
	local fault = nexus.character.GetFault();
	
	if ( nexus.mount.Call("ShouldDrawCharacterBackgroundBlur") ) then
		NEXUS:RegisterBackgroundBlur(self, self.createTime);
	else
		NEXUS:RemoveBackgroundBlur(self);
	end;
	
	if (self.characterModel) then
		if (!self.characterModel.currentModel
		or self.characterModel.currentModel == "models/error.mdl") then
			self.characterModel:SetAlpha(0);
		end;
	end;
	
	if (self.faultLabel:GetValue() == fault) then
		if ( nexus.mount.Call("ShouldDrawCharacterFault", fault) ) then
			self.faultLabel:SetVisible(true);
		else
			self.faultLabel:SetVisible(false);
		end;
	end;
	
	if (characters == 0 or loading) then
		self.loadButton:SetDisabled(true);
	else
		self.loadButton:SetDisabled(false);
	end;
	
	if ( characters >= nexus.player.GetMaximumCharacters()
	or nexus.character.IsPanelLoading() ) then
		self.createButton:SetDisabled(true);
	else
		self.createButton:SetDisabled(false);
	end;
	
	if ( g_LocalPlayer:HasInitialized() ) then
		self.disconnectButton:SetText("CANCEL");
		self.disconnectButton:SizeToContents();
	else
		self.disconnectButton:SetText("LEAVE");
		self.disconnectButton:SizeToContents();
	end;
	
	if (self.animation) then
		self.animation:Run();
	end;
	
	self:SetSize( ScrW(), ScrH() );
end;

vgui.Register("nx_CharacterMenu", PANEL, "DPanel");

hook.Add("VGUIMousePressed", "nexus.character.VGUIMousePressed", function(panel, code)
	local characterPanel = nexus.character.GetPanel();
	local activePanel = nexus.character.GetActivePanel();
	
	if (nexus.character.IsPanelOpen() and activePanel and characterPanel == panel) then
		activePanel:MakePopup();
		characterPanel:ReturnToMainMenu();
	end;
end);

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.characterForms = {};
	self.isCharacterList = true;
	
	self:SetTitle("");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
 	self.panelList:SetDrawBackground(false);
	self.panelList:EnableVerticalScrollbar();
end;

-- Called when the panel is painted.
function PANEL:Paint() end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
	self:SetSize( math.min(nexus.character.GetListWidth(), ScrW() - 32), math.min(self.panelList.pnlCanvas:GetTall() + 8, ScrH() * 0.6) );
end;

vgui.Register("nx_CharacterList", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local customData = self:GetParent().customData;
	local colorWhite = nexus.schema.GetColor("white");
	local buttons = {};
	local buttonX = 76;
	
	for k, v in pairs(customData) do
		self[k] = v;
	end;
	
	self:SetSize(self:GetParent():GetWide(), 48);
	self.buttonPanels = {};
	
	self.nameLabel = vgui.Create("DLabel", self);
	self.nameLabel:SetTextColor(colorWhite);
	self.nameLabel:SetText("N/A");
	self.nameLabel:SetPos(52, 2);
	
	self.detailsLabel = vgui.Create("DLabel", self);
	self.detailsLabel:SetTextColor(colorWhite);
	self.detailsLabel:SetText("N/A");
	self.detailsLabel:SetPos(52, 2);
	
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	self.spawnIcon:SetModel("");
	self.spawnIcon:SetIconSize(48);
	
	self.useButton = vgui.Create("DImageButton", self);
	self.useButton:SetToolTip("Use this character.");
	self.useButton:SetImage("gui/silkicons/check_on");
	self.useButton:SetSize(16, 16);
	self.useButton:SetPos(52, 30);
	
	self.deleteButton = vgui.Create("DImageButton", self);
	self.deleteButton:SetToolTip("Delete this character.");
	self.deleteButton:SetImage("gui/silkicons/check_off");
	self.deleteButton:SetSize(16, 16);
	self.deleteButton:SetPos(76, 30);
	
	nexus.mount.Call("GetCustomCharacterButtons", self.characterTable, buttons);
	
	for k, v in pairs(buttons) do
		local button = vgui.Create("DImageButton", self);
			buttonX = buttonX + 20;
			button:SetToolTip(v.toolTip);
			button:SetImage(v.image);
			button:SetSize(16, 16);
			button:SetPos(buttonX, 30);
		table.insert(self.buttonPanels, button);
		
		-- Called when the button is clicked.
		function button.DoClick(button)
			local function Callback()
				NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = k} );
			end;
			
			if (!v.OnClick or v.OnClick(Callback) != false) then
				Callback();
			end;
		end;
	end;
	
	-- Called when the button is clicked.
	function self.useButton.DoClick(spawnIcon)
		NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = "use"} );
	end;
	
	-- Called when the button is clicked.
	function self.deleteButton.DoClick(spawnIcon)
		NEXUS:AddMenuFromData( nil, {
			["Yes"] = function()
				NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = "delete"} );
			end,
			["No"] = function() end
		} );
	end;
	
	-- Called after the spawn icon has been hovered over.
	function self.spawnIcon.PaintOverHovered(spawnIcon)
		local panel = nexus.character.GetPanel();
		
		if ( !panel:FadeInModelPanel(self.model) ) then
			panel:SetModelPanelModel(self.model);
		end;
	end;
	
	-- Called when the spawn icon is clicked.
	function self.spawnIcon.DoClick(spawnIcon)
		local options = {};
		local panel = nexus.character.GetPanel();
		
		options["Use"] = function()
			NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = "use"} );
		end;
		
		options["Delete"] = {};
		options["Delete"]["No"] = function() end;
		options["Delete"]["Yes"] = function()
			NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = "delete"} );
		end;
		
		nexus.mount.Call("GetCustomCharacterOptions", self.characterTable, options, menu);
		
		NEXUS:AddMenuFromData(nil, options, function(menu, key, value)
			menu:AddOption(key, function()
				NEXUS:StartDataStream( "InteractCharacter", {characterID = self.characterID, action = value} );
			end);
		end);
	end;
end;

-- Called each frame.
function PANEL:Think()
	self.spawnIcon:SetModel(self.model);
	self.spawnIcon:SetToolTip( nexus.mount.Call("GetCharacterPanelToolTip", self, self.faction, self.characterTable) );
	
	self.nameLabel:SetText(self.name);
	self.nameLabel:SizeToContents();
	
	self.detailsLabel:SetText(self.details or "This character has no details to display.");
	self.detailsLabel:SizeToContents();
	self.detailsLabel:SetPos( 52, self.nameLabel.y + self.nameLabel:GetTall() );
	
	nexus.character.SetListWidth(self.nameLabel:GetWide() + 76);
	nexus.character.SetListWidth( (#self.buttonPanels * 20) + 76 );
	nexus.character.SetListWidth(self.detailsLabel:GetWide() + 76);
end;
	
vgui.Register("nx_CharacterPanel", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local panel = nexus.character.GetActivePanel();
	local size = ScrH() * 0.2;
	
	if (IsValid(panel) and panel:GetTall() > size) then
		size = panel:GetTall();
	end;
	
	self:SetSize(size, size);
	self:SetPaintBackground(false);
	
	self.modelPanel = vgui.Create("DModelPanel", self);
	self.modelPanel:SetPos(4, 4);
	self.modelPanel:SetSize(size, size);
	self.modelPanel:SetCamPos( Vector(0, 128, 64) );
	self.modelPanel:SetLookAt( Vector(0, 0, 80) );
	self.modelPanel:SetAmbientLight( Color(255, 255, 255, 255) );
	self.modelPanel:SetAnimSpeed(0.8);
	
	-- Called when the entity should be laid out.
	function self.modelPanel.LayoutEntity(modelPanel, entity)
		modelPanel:RunAnimation(); entity:SetAngles( Angle( 0, 90, 0) );
	end;
end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
		
		return true;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
		
		return true;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to set the alpha of the panel.
function PANEL:SetAlpha(alpha)
	self.modelPanel:SetColor( Color(255, 255, 255, alpha) );
end;

-- A function to get the alpha of the panel.
function PANEL:GetAlpha(alpha)
	return self.modelPanel:GetColor().a;
end;

-- Called each frame.
function PANEL:Think()
	local entity = self.modelPanel.Entity;
	
	if (self:GetAlpha() == 0) then
		self.modelPanel:SetVisible(false);
	else
		self.modelPanel:SetVisible(true);
	end;
	
	if ( IsValid(entity) ) then
		entity:SetPos( Vector(0, 0, 64) );
	end;
	
	if (self.animation) then
		self.animation:Run();
	end;
	
	self:InvalidateLayout(true);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local panel = nexus.character.GetActivePanel();
	local size = ScrH() * 0.2;
	
	if (IsValid(panel) and panel:GetTall() > size) then
		size = panel:GetTall();
	end;
	
	self:SetSize(size, size);
	self.modelPanel:SetSize(size, size);
end;

-- A function to set the model.
function PANEL:SetModel(model)
	self.modelPanel:SetModel(model);
end;
	
vgui.Register("nx_CharacterModel", PANEL, "DPanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumPoints = nexus.config.Get("default_attribute_points"):Get();
	local smallTextFont = nexus.schema.GetFont("menu_text_small");
	local factionTable;
	local sliderPanels = {};
	local attributes = {};
	local parent = self:GetParent();
	
	if (parent) then
		self.info = parent.stageData;
		
		if (self.info) then
			factionTable = nexus.faction.Get(self.info.faction);
		end;
	end;
	
	self:ShowCloseButton(false);
	self.lblTitle:SetVisible(false);
	
	self:SetDraggable(false);
	
	if (factionTable.attributePointsScale) then
		maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
	end;
	
	if (factionTable.maximumAttributePoints) then
		maximumPoints = factionTable.maximumAttributePoints;
	end;
	
	self.attributesForm = vgui.Create("DForm");
	self.attributesForm:SetName( nexus.schema.GetOption("name_attributes") );
	self.attributesForm:SetPadding(4);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
 	self.panelList:SetDrawBackground(false);
	self.panelList:EnableVerticalScrollbar();
	
	self.continueButton = vgui.Create("nx_LabelButton", self);
	self.continueButton:SetText("CONTINUE");
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SizeToContents();
	self.continueButton:SetMouseInputEnabled(true);
	
	-- Called when the button is clicked.
	function self.continueButton.DoClick(button)
		self.info.attributes = {};
		
		for k, v in ipairs(sliderPanels) do
			local attributeTable = v.attributeTable;
			
			if (attributeTable) then
				self.info.attributes[attributeTable.uniqueID] = v:GetValue();
			end;
		end;
		
		NEXUS:StartDataStream("CreateCharacter", self.info);
	end;
	
	for k, v in pairs( nexus.attribute.GetAll() ) do
		attributes[#attributes + 1] = v;
	end;
	
	table.sort(attributes, function(a, b)
		return a.name < b.name;
	end);
	
	for k, v in pairs(attributes) do
		if (v.characterScreen) then
			local numSlider = self.attributesForm:NumSlider(v.name, nil, 0, math.min(v.maximum, maximumPoints), 0);
			local index = #sliderPanels + 1;
			
			-- Called when the number wang value has changed.
			numSlider.OnValueChanged = function(numSlider, value)
				local pointsUsed = value;
				
				for k2, v2 in ipairs(sliderPanels) do
					if (v2 != numSlider) then
						pointsUsed = pointsUsed + v2:GetValue();
					end;
				end;
				
				for k2, v2 in ipairs(sliderPanels) do
					if (v2 != numSlider) then
						v2:SetMax( math.Clamp(maximumPoints - pointsUsed, 0, maximumPoints) );
					end;
				end;
			end;
			
			sliderPanels[index] = numSlider;
			sliderPanels[index]:SetToolTip(v.description);
			sliderPanels[index].attributeTable = v;
		end;
	end;
	
	self.panelList:AddItem(self.attributesForm);
	self.panelList:AddItem(self.continueButton);
end;

-- Called when the panel is painted.
function PANEL:Paint() end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
	self:SetSize( math.max(ScrW() * 0.25, 400), math.min(self.panelList.pnlCanvas:GetTall() + 8, ScrH() * 0.6) );
end;

vgui.Register("nx_CharacterStageThree", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = nexus.schema.GetFont("menu_text_small");
	local selectModel = nil;
	local physDesc = (nexus.command.Get("CharPhysDesc") != nil);
	local parent = self:GetParent();
	
	self:ShowCloseButton(false);
	self.lblTitle:SetVisible(false);
	
	self:SetDraggable(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
 	self.panelList:SetDrawBackground(false);
	self.panelList:EnableVerticalScrollbar();
	
	self.faction = parent.stageData.faction;
	
	if (!nexus.faction.stored[self.faction].GetModel) then
		selectModel = true;
	end;
	
	if (!nexus.faction.stored[self.faction].GetName) then
		self.nameForm = vgui.Create("DForm");
		self.nameForm:SetPadding(4);
		self.nameForm:SetName("Name");
		
		if (nexus.faction.stored[self.faction].useFullName) then
			self.fullNameTextEntry = self.nameForm:TextEntry("Full Name");
		else
			self.forenameTextEntry = self.nameForm:TextEntry("Forename");
			self.surnameTextEntry = self.nameForm:TextEntry("Surname");
		end;
	end;
	
	if (selectModel or physDesc) then
		self.appearanceForm = vgui.Create("DForm");
		self.appearanceForm:SetPadding(4);
		self.appearanceForm:SetName("Appearance");
		
		if (physDesc and selectModel) then
			self.appearanceForm:Help("Write a physical description for your character in full English, and select an appropriate model.");
		elseif (physDesc) then
			self.appearanceForm:Help("Write a physical description for your character in full English.");
		end;
		
		if (physDesc) then
			self.physDescTextEntry = self.appearanceForm:TextEntry("Physical Description");
		end;
		
		if (selectModel) then
			self.modelItemsList = vgui.Create("DPanelList", self);
			self.modelItemsList:SetPadding(4);
			self.modelItemsList:SetSpacing(16);
			self.modelItemsList:EnableHorizontal(true);
			self.modelItemsList:EnableVerticalScrollbar(true);
			
			self.appearanceForm:AddItem(self.modelItemsList);
		end;
	end;
	
	self.continueButton = vgui.Create("nx_LabelButton", self);
	self.continueButton:SetText("CONTINUE");
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SizeToContents();
	self.continueButton:SetMouseInputEnabled(true);
	
	-- Called when the button is clicked.
	function self.continueButton.DoClick(button)
		local minimumPhysDesc = nexus.config.Get("minimum_physdesc"):Get();
		local attributeTable = nexus.attribute.GetAll();
		local attributes = false;
		local info = {
			faction = self.faction,
			gender = self.gender,
			model = self.model
		};
		
		if (table.Count(attributeTable) > 0) then
			for k, v in pairs(attributeTable) do
				if (v.characterScreen) then
					attributes = true; break;
				end;
			end;
		end;
		
		if (!nexus.faction.stored[self.faction].GetName) then
			if ( IsValid(self.fullNameTextEntry) ) then
				info.fullName = self.fullNameTextEntry:GetValue();
				
				if (info.fullName == "") then
					return nexus.character.SetFault("You did not choose a name, or the name that you chose is not valid!");
				end;
			else
				info.forename = self.forenameTextEntry:GetValue();
				info.surname = self.surnameTextEntry:GetValue();
				
				if (info.forename == "" or info.surname == "") then
					return nexus.character.SetFault("You did not choose a name, or the name that you chose is not valid!");
				end;
				
				if ( string.find(info.forename, "[%p%s%d]") or string.find(info.surname, "[%p%s%d]") ) then
					return nexus.character.SetFault("Your forename and surname must not contain punctuation, spaces or digits!");
				end;
				
				if ( !string.find(info.forename, "[aeiou]") or !string.find(info.surname, "[aeiou]") ) then
					return nexus.character.SetFault("Your forename and surname must both contain at least one vowel!");
				end;
				
				if ( string.len(info.forename) < 2 or string.len(info.surname) < 2) then
					return nexus.character.SetFault( "Your forename and surname must both be at least 2 characters long!");
				end;
				
				if ( string.len(info.forename) > 16 or string.len(info.surname) > 16) then
					return nexus.character.SetFault("Your forename and surname must not be greater than 16 characters long!");
				end;
			end;
		end;
		
		if (selectModel and !info.model) then
			return nexus.character.SetFault("You did not choose a model, or the model that you chose is not valid!");
		end;
		
		if (physDesc) then
			info.physDesc = self.physDescTextEntry:GetValue();
			
			if (string.len(info.physDesc) < minimumPhysDesc) then
				return nexus.character.SetFault("The physical description must be at least "..minimumPhysDesc.." characters long!");
			end;
		end;
		
		nexus.mount.Call("PlayerAdjustCharacterCreationInfo", self, info);
		
		if (attributes) then
			parent:OpenPanel("nx_CharacterStageThree", info);
			
			return;
		end;
		
		NEXUS:StartDataStream("CreateCharacter", info);
	end;
	
	if (self.nameForm) then
		self.panelList:AddItem(self.nameForm);
	end;
	
	if (self.appearanceForm) then
		self.panelList:AddItem(self.appearanceForm);
	end;
	
	nexus.mount.Call("CharacterCreationPanelInitialized", self);
	
	self.panelList:AddItem(self.continueButton);
	
	if (parent and parent.stageData) then
		self:SetInfo(parent.stageData.faction, parent.stageData.gender);
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint() end;

-- A function to set the information
function PANEL:SetInfo(faction, gender)
	local lowerGender = string.lower(gender);
	local spawnIcon;
	local panel = nexus.character.GetPanel();
	
	for k, v in pairs(nexus.faction.stored) do
		if (v.name == faction) then
			self.faction = faction;
			self.gender = gender;
			
			if (self.modelItemsList) then
				if ( v.models[lowerGender] ) then
					for k2, v2 in pairs( v.models[lowerGender] ) do
						spawnIcon = NEXUS:CreateColoredSpawnIcon(self);
						spawnIcon:SetModel(v2);
						
						-- Called when the spawn icon is clicked.
						function spawnIcon.DoClick(spawnIcon)
							if (self.selectedSpawnIcon) then
								self.selectedSpawnIcon:SetColor(nil);
							end;
							
							spawnIcon:SetColor( Color(255, 0, 0, 255) );
							
							if ( !panel:FadeInModelPanel(v2) ) then
								panel:SetModelPanelModel(v2);
							end;
							
							self.selectedSpawnIcon = spawnIcon;
							self.model = v2;
						end;
						
						self.modelItemsList:AddItem(spawnIcon);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
	
	if ( IsValid(self.modelItemsList) ) then
		self.modelItemsList:SetTall(384);
	end;
	
	self:SetSize( math.max(ScrW() * 0.25, 400), math.min(self.panelList.pnlCanvas:GetTall() + 8, ScrH() * 0.6) );
end;

vgui.Register("nx_CharacterStageTwo", PANEL, "DFrame");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local smallTextFont = nexus.schema.GetFont("menu_text_small");
	local forcedFaction = nil;
	local factions = {};
	local parent = self:GetParent();
	
	for k, v in pairs(nexus.faction.stored) do
		if ( !v.whitelist or nexus.character.IsWhitelisted(v.name) ) then
			if ( !nexus.faction.HasReachedMaximum(k) ) then
				factions[#factions + 1] = v.name;
			end;
		end;
	end;
	
	table.sort(factions, function(a, b)
		return a < b;
	end);
	
	self:ShowCloseButton(false);
	self.lblTitle:SetVisible(false);
	
	self:SetDraggable(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
 	self.panelList:SetDrawBackground(false);
	
	self.settingsForm = vgui.Create("DForm");
	self.settingsForm:SetName("Settings");
	self.settingsForm:SetPadding(4);
	
	if (#factions > 1) then
		self.factionMultiChoice = self.settingsForm:MultiChoice("Faction");
		self.factionMultiChoice:SetEditable(false);
		
		-- Called when an option is selected.
		self.factionMultiChoice.OnSelect = function(multiChoice, index, value, data)
			for k, v in pairs(nexus.faction.stored) do
				if (v.name == value) then
					if ( IsValid(self.genderMultiChoice) ) then
						self.genderMultiChoice:Clear();
					else
						self.genderMultiChoice = self.settingsForm:MultiChoice("Gender");
						self.genderMultiChoice:SetEditable(false);
					end;
					
					if (v.singleGender) then
						self.genderMultiChoice:AddChoice(v.singleGender);
					else
						self.genderMultiChoice:AddChoice(GENDER_FEMALE);
						self.genderMultiChoice:AddChoice(GENDER_MALE);
					end;
					
					break;
				end;
			end;
		end;
	elseif (#factions == 1) then
		for k, v in pairs(nexus.faction.stored) do
			if ( v.name == factions[1] ) then
				self.genderMultiChoice = self.settingsForm:MultiChoice("Gender");
				self.genderMultiChoice:SetEditable(false);
				
				if (v.singleGender) then
					self.genderMultiChoice:AddChoice(v.singleGender);
				else
					self.genderMultiChoice:AddChoice(GENDER_FEMALE);
					self.genderMultiChoice:AddChoice(GENDER_MALE);
				end;
				
				forcedFaction = v.name;
				
				break;
			end;
		end;
	end;
	
	self.continueButton = vgui.Create("nx_LabelButton", self);
	self.continueButton:SetText("CONTINUE");
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SizeToContents();
	self.continueButton:SetMouseInputEnabled(true);
	
	-- Called when the button is clicked.
	function self.continueButton.DoClick(button)
		if ( IsValid(self.genderMultiChoice) ) then
			local faction = forcedFaction;
			local gender = self.genderMultiChoice.TextEntry:GetValue();
			
			if (!faction and self.factionMultiChoice) then
				faction = self.factionMultiChoice.TextEntry:GetValue();
			end;
			
			for k, v in pairs(nexus.faction.stored) do
				if (v.name == faction) then
					if ( nexus.faction.IsGenderValid(faction, gender) ) then
						parent:OpenPanel( "nx_CharacterStageTwo", {faction = faction, gender = gender} );
					end;
					
					break;
				end;
			end;
		end;
	end;
	
	if (self.factionMultiChoice) then
		for k, v in pairs(factions) do
			self.factionMultiChoice:AddChoice(v);
		end;
	end;
	
	self.panelList:AddItem(self.settingsForm);
	self.panelList:AddItem(self.continueButton);
end;

-- Called when the panel is painted.
function PANEL:Paint() end;

-- A function to make the panel fade out.
function PANEL:FadeOut(speed, Callback)
	if ( self:GetAlpha() > 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha( 255 - (delta * 255) );
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- A function to make the panel fade in.
function PANEL:FadeIn(speed, Callback)
	if ( self:GetAlpha() == 0 and ( !self.animation or !self.animation:Active() ) ) then
		self.animation = Derma_Anim("Fade Panel", self, function(panel, animation, delta, data)
			panel:SetAlpha(delta * 255);
			
			if (animation.Finished and Callback) then
				Callback();
			end;
		end);
		
		if (self.animation) then
			self.animation:Start(speed);
		end;
	elseif (Callback) then
		Callback();
	end;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
	
	if (self.animation) then
		self.animation:Run();
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(0, 0, 0, 0);
	self:SetSize( math.max(ScrW() * 0.25, 400), math.min(self.panelList.pnlCanvas:GetTall() + 8, ScrH() * 0.6) );
end;

vgui.Register("nx_CharacterStageOne", PANEL, "DFrame");

usermessage.Hook("nx_CharacterRemove", function(msg)
	local characters = nexus.character.GetAll();
	
	if (table.Count(characters) > 0) then
		local characterID = msg:ReadShort();
		
		if ( characters[characterID] ) then
			characters[characterID] = nil;
			
			if ( !nexus.character.IsPanelLoading() ) then
				nexus.character.RefreshPanelList();
			end;
			
			if ( nexus.character.GetPanelList() ) then
				if (table.Count(characters) == 0) then
					nexus.character.GetPanel():ReturnToMainMenu();
				end;
			end;
		end;
	end;
end);

NEXUS:HookDataStream("SetWhitelisted", function(data)
	local whitelisted = nexus.character.GetWhitelisted();
	
	for k, v in pairs(whitelisted) do
		if ( v == data[1] ) then
			if ( !data[2] ) then
				whitelisted[k] = nil;
				
				-- Return to break the function.
				return;
			end;
		end;
	end;
	
	if ( data[2] ) then
		whitelisted[#whitelisted + 1] = data[1];
	end;
end);

NEXUS:HookDataStream("CharacterAdd", function(data)
	nexus.character.GetAll()[data.characterID] = data;
	
	if ( !nexus.character.IsPanelLoading() ) then
		nexus.character.RefreshPanelList();
	end;
end);

NEXUS:HookDataStream("CharacterMenu", function(data)
	if (data == CHARACTER_MENU_LOADED) then
		if ( nexus.character.GetPanel() ) then
			nexus.character.SetPanelLoading(false);
			nexus.character.RefreshPanelList();
		end;
	elseif (data == CHARACTER_MENU_CLOSE) then
		nexus.character.SetPanelOpen(false);
	elseif (data == CHARACTER_MENU_OPEN) then
		nexus.character.SetPanelOpen(true);
	end;
end);

usermessage.Hook("nx_CharacterFinish", function(msg)
	if ( msg:ReadBool() ) then
		nexus.character.SetPanelMainMenu();
		nexus.character.SetPanelOpen(false, true);
		nexus.character.SetFault(nil);
	else
		nexus.character.SetFault( msg:ReadString() );
	end;
end);