--[[
Name: "cl_character.lua".
Product: "kuroScript".
--]]

kuroScript.character = {};
kuroScript.character.width = 300;
kuroScript.character.height = 200;
kuroScript.character.stored = {};
kuroScript.character.whitelisted = {};

-- A function to get the character creation step.
function kuroScript.character.GetCreationStep()
	if ( kuroScript.character.stepTwo and kuroScript.character.stepTwo:IsValid() ) then
		return 3;
	elseif ( kuroScript.character.stepOne and kuroScript.character.stepOne:IsValid() ) then
		return 2;
	elseif ( kuroScript.character.panel and kuroScript.character.panel:IsValid() ) then
		return 1;
	else
		return 0;
	end;
end;

-- A function to get the active character panel.
function kuroScript.character.GetActivePanel()
	local creationStep = kuroScript.character.GetCreationStep();
	
	-- Check if a statement is true.
	if (creationStep == 3) then
		return kuroScript.character.stepTwo;
	elseif (creationStep == 2) then
		return kuroScript.character.stepOne;
	elseif (creationStep == 1) then
		return kuroScript.character.panel;
	end;
end;

-- A function to get whether the character panel is loading.
function kuroScript.character.IsPanelLoading()
	if (kuroScript.character.panel and kuroScript.character.panel.loading) then
		return true;
	end;
end;

-- A function to get the local player's characters.
function kuroScript.character.GetAll()
	return kuroScript.character.stored;
end;

-- A function to refresh the character panel.
function kuroScript.character.RefreshPanel()
	local availableClasses = {};
	local classes = {};
	local panel = kuroScript.character.panel;
	local k3, v3;
	local k2, v2;
	local k, v;
	
	-- Set some information.
	panel.characterForms = {};
	
	-- Set some information.
	panel.panelList:Clear();
	panel.panelList:AddItem(panel.createCharacter);
	
	-- Loop through each value in a table.
	for k, v in pairs( kuroScript.character.GetAll() ) do
		local class = hook.Call("GetPlayerCharacterScreenClass", kuroScript.frame, v);
		
		-- Check if a statement is true.
		if ( !availableClasses[class] ) then
			availableClasses[class] = {};
		end;
		
		-- Set some information.
		availableClasses[class][#availableClasses[class] + 1] = v;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return hook.Call("CharacterScreenSortClassCharacters", kuroScript.frame, k, a, b);
		end);
		
		-- Set some information.
		classes[#classes + 1] = {name = k, characters = v};
	end;
	
	-- Sort the classes.
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	-- Loop through each value in a table.
	for k, v in pairs(classes) do
		panel.characterForms[v.name] = vgui.Create("DForm", self);
		panel.characterForms[v.name]:SetPadding(4);
		panel.characterForms[v.name]:SetName(v.name);
		
		-- Set some information.
		panel.panelList:AddItem( panel.characterForms[v.name] );
		
		-- Loop through each value in a table.
		for k2, v2 in pairs(v.characters) do
			v2.panel = vgui.Create("ks_CharacterPanel", panel);
			v2.panel.tags = v2.tags;
			v2.panel.name = v2.name;
			v2.panel.model = v2.model;
			v2.panel.class = v2.class;
			v2.panel.banned = v2.banned;
			v2.panel.characterID = v2.characterID;
			v2.panel.characterTable = v2;
			
			-- Loop through each value in a table.
			for k3, v3 in pairs(v2.panel.tags) do
				v2.panel:AddTag(k3, v3);
			end;
			
			-- Set some information.
			panel.characterForms[v.name]:AddItem(v2.panel);
		end;
	end;
end;

-- A function to set whether the character panel is open.
function kuroScript.character.SetPanelOpen(open, reset)
	if (!open) then
		if ( kuroScript.character.stepTwo and kuroScript.character.stepTwo:IsValid() ) then
			kuroScript.character.stepTwo:Remove();
		end;
		
		-- Check if a statement is true.
		if ( kuroScript.character.stepOne and kuroScript.character.stepOne:IsValid() ) then
			kuroScript.character.stepOne:Remove();
		end;
		
		-- Check if a statement is true.
		if (!reset) then
			kuroScript.character.open = false;
			
			-- Check if a statement is true.
			if ( kuroScript.character.panel and kuroScript.character.panel:IsValid() ) then
				kuroScript.character.panel:SetVisible(false);
			end;
		elseif ( kuroScript.character.panel and kuroScript.character.panel:IsValid() ) then
			kuroScript.character.panel:SetVisible(true);
			
			-- Set some information.
			kuroScript.character.open = true;
		end;
	else
		kuroScript.character.open = true;
		
		-- Check if a statement is true.
		if (kuroScript.character.panel) then
			kuroScript.character.panel:SetVisible(true);
		else
			kuroScript.character.panel = vgui.Create("ks_CharacterMenu");
			kuroScript.character.panel:MakePopup();
			
			-- Call a gamemode hook.
			hook.Call("PlayerCharacterScreenCreated", kuroScript.frame, kuroScript.character.panel);
		end;
	end;
	
	-- Set whether the screen clicker is enabled.
	gui.EnableScreenClicker(kuroScript.character.open);
end;

-- A function to get whether the character panel is open.
function kuroScript.character.IsPanelOpen()
	return kuroScript.character.open;
end;