--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.character = {};
CloudScript.character.stored = {};
CloudScript.character.listWidth = 0;
CloudScript.character.whitelisted = {};

-- A function to get the active panel.
function CloudScript.character:GetActivePanel()
	if ( IsValid(self.activePanel) ) then
		return self.activePanel;
	end;
end;

-- A function to set whether the character panel is loading.
function CloudScript.character:SetPanelLoading(loading)
	self.loading = loading;
end;

-- A function to get whether the character panel is loading.
function CloudScript.character:IsPanelLoading()
	return self.isLoading;
end;

-- A function to get the character panel list.
function CloudScript.character:GetPanelList()
	local panel = self:GetActivePanel();
	
	if (panel and panel.isCharacterList) then
		return panel;
	end;
end;

-- A function to get the list width.
function CloudScript.character:GetListWidth(realWidth)
	return math.max(self.listWidth, ScrW() / 6);
end;

-- A function to set the list width.
function CloudScript.character:SetListWidth(listWidth, force)
	if ( ( listWidth > self:GetListWidth() ) or force ) then
		self.listWidth = listWidth;
	end;
end;

-- A function to get the whitelisted factions.
function CloudScript.character:GetWhitelisted()
	return self.whitelisted;
end;

-- A function to get whether the local player is whitelisted for a faction.
function CloudScript.character:IsWhitelisted(faction)
	return table.HasValue(self:GetWhitelisted(), faction);
end;

-- A function to get the local player's characters.
function CloudScript.character:GetAll()
	return self.stored;
end;

-- A function to get the character fault.
function CloudScript.character:GetFault()
	return self.fault;
end;

-- A function to set the character fault.
function CloudScript.character:SetFault(fault)
	if (type(fault) == "string") then
		CloudScript:AddCinematicText(fault, Color(255, 255, 255, 255), 32, 6, CloudScript.option:GetFont("menu_text_tiny"), true);
	end;
	
	self.fault = fault;
end;

-- A function to get the character panel.
function CloudScript.character:GetPanel()
	return self.panel;
end;

-- A function to refresh the character panel list.
function CloudScript.character:RefreshPanelList()
	local availableFactions = {};
	local factions = {};
	local panel = self:GetPanelList();
	
	self:SetListWidth(0, true);
	
	if (panel) then
		if (panel.characterForms) then
			panel.characterForms = {};
		end;
		
		panel.panelList:Clear();
		
		for k, v in pairs( self:GetAll() ) do
			local faction = CloudScript.plugin:Call("GetPlayerCharacterScreenFaction", v);
			
			if ( !availableFactions[faction] ) then
				availableFactions[faction] = {};
			end;
			
			availableFactions[faction][#availableFactions[faction] + 1] = v;
		end;
		
		for k, v in pairs(availableFactions) do
			table.sort(v, function(a, b)
				return CloudScript.plugin:Call("CharacterScreenSortFactionCharacters", k, a, b);
			end);
			
			factions[#factions + 1] = {name = k, characters = v};
		end;
		
		table.sort(factions, function(a, b)
			return a.name < b.name;
		end);
		
		for k, v in pairs(factions) do
			panel.characterForms[v.name] = vgui.Create("DForm", self);
			panel.characterForms[v.name]:SetDrawBackground(false);
			panel.characterForms[v.name]:SetPadding(4);
			panel.characterForms[v.name]:SetName(v.name);
			
			panel.panelList:AddItem( panel.characterForms[v.name] );
			
			for k2, v2 in pairs(v.characters) do
				panel.customData = {
					name = v2.name,
					model = v2.model,
					banned = v2.banned,
					faction = v2.faction,
					details = v2.details,
					characterID = v2.characterID,
					characterTable = v2
				};
				
				v2.panel = vgui.Create("cloud_CharacterPanel", panel);
				
				if ( IsValid(v2.panel) ) then
					panel.characterForms[v.name]:AddItem(v2.panel);
				end;
			end;
		end;
	end;
end;

-- A function to get whether the character panel is open.
function CloudScript.character:IsPanelOpen()
	return self.isOpen;
end;

-- A function to set the character panel to the main menu.
function CloudScript.character:SetPanelMainMenu()
	local panel = self:GetPanel();
	
	if (panel) then
		panel:ReturnToMainMenu();
	end;
end;

-- A function to set whether the character panel is polling.
function CloudScript.character:SetPanelPolling(polling)
	self.isPolling = polling;
end;

-- A function to get whether the character panel is polling.
function CloudScript.character:IsPanelPolling()
	return self.isPolling;
end;

-- A function to get whether the character menu is reset.
function CloudScript.character:IsMenuReset()
	return self.isMenuReset;
end;

-- A function to set whether the character panel is open.
function CloudScript.character:SetPanelOpen(open, bReset)
	local panel = self:GetPanel();
	
	if (!open) then
		if (!bReset) then
			self.isOpen = false;
		else
			self.isOpen = true;
		end;
		
		if (panel) then
			panel:SetVisible( self:IsPanelOpen() );
		end;
	elseif (panel) then
		panel:SetVisible(true);
		panel.createTime = SysTime();
		self.isOpen = true;
	else
		self:SetPanelPolling(true);
	end;
	
	gui.EnableScreenClicker( self:IsPanelOpen() );
end;