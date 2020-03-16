--[[
Name: "cl_character.lua".
Product: "nexus".
--]]

nexus.character = {};
nexus.character.stored = {};
nexus.character.listWidth = 0;
nexus.character.whitelisted = {};

-- A function to get the active panel.
function nexus.character.GetActivePanel()
	if ( IsValid(nexus.character.activePanel) ) then
		return nexus.character.activePanel;
	end;
end;

-- A function to set whether the character panel is loading.
function nexus.character.SetPanelLoading(loading)
	nexus.character.loading = loading;
end;

-- A function to get whether the character panel is loading.
function nexus.character.IsPanelLoading()
	return nexus.character.isLoading;
end;

-- A function to get the character panel list.
function nexus.character.GetPanelList()
	local panel = nexus.character.GetActivePanel();
	
	if (panel and panel.isCharacterList) then
		return panel;
	end;
end;

-- A function to get the list width.
function nexus.character.GetListWidth(realWidth)
	return math.max(nexus.character.listWidth, ScrW() / 6);
end;

-- A function to set the list width.
function nexus.character.SetListWidth(listWidth, force)
	if ( ( listWidth > nexus.character.GetListWidth() ) or force ) then
		nexus.character.listWidth = listWidth;
	end;
end;

-- A function to get the whitelisted factions.
function nexus.character.GetWhitelisted()
	return nexus.character.whitelisted;
end;

-- A function to get whether the local player is whitelisted for a faction.
function nexus.character.IsWhitelisted(faction)
	return table.HasValue(nexus.character.GetWhitelisted(), faction);
end;

-- A function to get the local player's characters.
function nexus.character.GetAll()
	return nexus.character.stored;
end;

-- A function to get the character fault.
function nexus.character.GetFault()
	return nexus.character.fault;
end;

-- A function to set the character fault.
function nexus.character.SetFault(fault)
	if ( nexus.character.GetPanel() ) then
		nexus.character.GetPanel():DisplayCharacterFault(fault);
	end;
	
	nexus.character.fault = fault;
end;

-- A function to get the character panel.
function nexus.character.GetPanel()
	return nexus.character.panel;
end;

-- A function to refresh the character panel list.
function nexus.character.RefreshPanelList()
	local availableFactions = {};
	local factions = {};
	local panel = nexus.character.GetPanelList();
	
	nexus.character.SetListWidth(0, true);
	
	if (panel) then
		if (panel.characterForms) then
			panel.characterForms = {};
		end;
		
		panel.panelList:Clear();
		
		for k, v in pairs( nexus.character.GetAll() ) do
			local faction = nexus.mount.Call("GetPlayerCharacterScreenFaction", v);
			
			if ( !availableFactions[faction] ) then
				availableFactions[faction] = {};
			end;
			
			availableFactions[faction][#availableFactions[faction] + 1] = v;
		end;
		
		for k, v in pairs(availableFactions) do
			table.sort(v, function(a, b)
				return nexus.mount.Call("CharacterScreenSortFactionCharacters", k, a, b);
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
				
				v2.panel = vgui.Create("nx_CharacterPanel", panel);
				
				if ( IsValid(v2.panel) ) then
					panel.characterForms[v.name]:AddItem(v2.panel);
				end;
			end;
		end;
	end;
end;

-- A function to get whether the character panel is open.
function nexus.character.IsPanelOpen()
	return nexus.character.isOpen;
end;

-- A function to set the character panel to the main menu.
function nexus.character.SetPanelMainMenu()
	local panel = nexus.character.GetPanel();
	
	if (panel) then
		panel:ReturnToMainMenu();
	end;
end;

-- A function to set whether the character panel is polling.
function nexus.character.SetPanelPolling(polling)
	nexus.character.isPolling = polling;
end;

-- A function to get whether the character panel is polling.
function nexus.character.IsPanelPolling()
	return nexus.character.isPolling;
end;

-- A function to set whether the character panel is open.
function nexus.character.SetPanelOpen(open, reset)
	local panel = nexus.character.GetPanel();
	
	if (!open) then
		if (!reset) then
			nexus.character.isOpen = false;
		else
			nexus.character.isOpen = true;
		end;
		
		if (panel) then
			panel:SetVisible( nexus.character.IsPanelOpen() );
		end;
	else
		if (panel) then
			panel:SetVisible(true);
			panel.createTime = SysTime();
			nexus.character.isOpen = true;
		else
			nexus.character.SetPanelPolling(true);
		end;
	end;
	
	gui.EnableScreenClicker( nexus.character.IsPanelOpen() );
end;