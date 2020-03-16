--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_boot");

--[[ Define some member variables for the schema. --]]
Schema.thirdPersonAmount = 0;
Schema.heatwaveMaterial = Material("sprites/heatwave");
Schema.heatwaveMaterial:SetMaterialFloat("$refractamount", 0);
Schema.fishEyeTexture = Material("models/props_c17/fisheyelens");
Schema.shinyMaterial = Material("models/shiny");
Schema.targetOutlines = {};
Schema.ownedVehicles = {};
Schema.damageNotify = {};
Schema.stunEffects = {};
Schema.ownedDoors = {};

-- A function to create a hotkey spawn icon.
function Schema:CreateHotkeySpawnIcon(itemTable)
	local spawnIcon = Clockwork:CreateCustomSpawnIcon();
	
	-- A function to set the spawn icon's item table.
	spawnIcon.SetItemTable = function(spawnIcon, itemTable)
		spawnIcon.itemTable = itemTable;
	end;
	
	-- A function to set the spawn icon's hotkey data.
	spawnIcon.SetHotkeyData = function(spawnIcon, hotkeyData)
		spawnIcon.hotkeyData = hotkeyData;
	end;
	
	-- Called when the spawn icon's menu is opened.
	spawnIcon.OpenMenu = function(spawnIcon)
		Clockwork:HandleItemSpawnIconRightClick(spawnIcon.itemTable, spawnIcon);
	end;
	
	-- Called when the spawn icon is clicked.
	spawnIcon.DoClick = function(spawnIcon)
		HIDE_HOTKEY_OPTION = true;
		Clockwork:HandleItemSpawnIconClick(spawnIcon.itemTable, spawnIcon, function(itemMenu)
			itemMenu:AddOption("Unhotkey", function()
				self:RemoveHotkey(spawnIcon.itemTable);
			end);
		end);
		HIDE_HOTKEY_OPTION = nil;
	end;
	
	local model, skin = Clockwork.item:GetIconInfo(itemTable);
		spawnIcon:SetModel(model, skin);
		spawnIcon:SetIconSize(32);
	return spawnIcon;
end;

-- A function to add a new hotkey.
function Schema:AddHotkey(itemTable)
	if (#self.hotkeyItems < 10) then
		table.insert(self.hotkeyItems, {
			uniqueID = itemTable("uniqueID"), name = itemTable("name")
		});
		
		self:SaveHotkeys();
	end;
end;

-- A function to remove a hotkey.
function Schema:RemoveHotkey(itemTable)
	for k, v in pairs(self.hotkeyItems) do
		if (v.uniqueID == itemTable("uniqueID")
		and v.name == itemTable("name")) then
			table.remove(self.hotkeyItems, k);
			v.panel:Remove();
		end;
	end;
	
	self:SaveHotkeys();
end;

-- A function to save the hotkeys.
function Schema:SaveHotkeys()
	local hotkeyItems = {};
		for k, v in pairs(self.hotkeyItems) do
			table.insert(hotkeyItems, {uniqueID = v.uniqueID, name = v.name});
		end;
	Clockwork:SaveSchemaData("hotkeys/"..self.hotkeyFile, hotkeyItems);
end;

-- A function to load the hotkeys.
function Schema:LoadHotkeys(iCharacterKey)
	if (self.hotkeyItems) then
		for k, v in pairs(self.hotkeyItems) do
			v.panel:Remove();
		end;
	end;
	
	self.hotkeyFile = "hotkeys/"..iCharacterKey;
	self.hotkeyItems = Clockwork:RestoreSchemaData(self.hotkeyFile);
end;

-- A function to print text to the center of the screen.
function Schema:PrintTextCenter(text, subText, soundName, bSmallTitle)
	if (!self.centerTexts) then
		self.centerTexts = {};
	end;
	
	self.centerTexts[#self.centerTexts + 1] = {
		bSmallTitle = bSmallTitle,
		targetAlpha = 255,
		soundName = soundName,
		subText = subText,
		alpha = 0,
		text = text
	};
end;

-- A function to get whether a text entry is being used.
function Schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if (self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;

Clockwork.config:AddToSystem("intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("intro_text_big", "The big text displayed for the introduction.");
Clockwork.config:AddToSystem("max_safebox_weight", "The maximum weight a player's safebox can hold.");

--[[ Remove the setting for enabling/disabling the top bars, as we're showing them anyway! --]]
Clockwork.setting:Remove(nil, nil, nil, "cwTopBars");

Clockwork.chatBox:RegisterClass("discovered_item", "ooc", function(info)
	local itemColor = nil;
	local itemTable = Clockwork.item:FindInstance(info.text);
	local rarityName = nil;
	
	if (!itemTable) then return; end;
	
	if (itemTable:GetData("Rarity") == 2) then
		itemColor = Color(255, 85, 85, 255);
		rarityName = "A legendary";
	elseif (itemTable:GetData("Rarity") == 3) then
		itemColor = Color(255, 206, 73, 255);
		rarityName = "The unique";
	end;
	
	local OnHoverCallback = function(textInfo)
		local x, y = gui.MouseX(), gui.MouseY();
		local markupObject = markup.Parse(
			Clockwork.item:GetMarkupToolTip(itemTable), ScrW() * 0.25
		
		);
		
		y = y - markupObject:GetHeight() - 32;
		Clockwork:OverrideMarkupDraw(markupObject);
		Clockwork:DrawMarkupToolTip(markupObject, x, y, 255);
	end;
	
	if (itemColor and rarityName) then
		Clockwork.chatBox:Add(
			info.filtered, nil, rarityName.." item ", itemColor,
			OnHoverCallback, "["..itemTable("name").."]", " has been discovered by "..info.name.."."
		);
	end;
end);

Clockwork.chatBox:RegisterClass("destroyed_unique", "ooc", function(info)
	local itemColor = Color(255, 206, 73, 255);
	local itemTable = Clockwork.item:FindInstance(info.text);
	
	if (!itemTable) then return; end;
	
	local OnHoverCallback = function(textInfo)
		local x, y = gui.MouseX(), gui.MouseY();
		local markupObject = markup.Parse(
			Clockwork.item:GetMarkupToolTip(itemTable), ScrW() * 0.25
		
		);
		
		y = y - markupObject:GetHeight() - 32;
		Clockwork:OverrideMarkupDraw(markupObject);
		Clockwork:DrawMarkupToolTip(markupObject, x, y, 255);
	end;
	
	Clockwork.chatBox:Add(
		info.filtered, nil, "The unique item ", itemColor,
		OnHoverCallback, "["..itemTable("name").."]", " has been destroyed!"
	);
end);

Clockwork.chatBox:RegisterClass("found_unique", "ooc", function(info)
	local itemColor = Color(255, 206, 73, 255);
	local itemTable = Clockwork.item:FindInstance(info.text);
	
	if (!itemTable) then return; end;
	
	local OnHoverCallback = function(textInfo)
		local x, y = gui.MouseX(), gui.MouseY();
		local markupObject = markup.Parse(
			Clockwork.item:GetMarkupToolTip(itemTable), ScrW() * 0.25
		
		);
		
		y = y - markupObject:GetHeight() - 32;
		Clockwork:OverrideMarkupDraw(markupObject);
		Clockwork:DrawMarkupToolTip(markupObject, x, y, 255);
	end;
	
	Clockwork.chatBox:Add(
		info.filtered, nil, "The unique item ", itemColor,
		OnHoverCallback, "["..itemTable("name").."]", " is now possessed by "..info.name.."."
	);
end);

Clockwork.chatBox:RegisterClass("broadcast", "ic", function(info)
	if (IsValid(info.data.entity)) then
		if (info.data.entity:GetNetworkedString("Name") != "") then
			info.name = info.data.entity:GetNetworkedString("Name");
		end;
	end;
	
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("radio", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

usermessage.Hook("cwStorageMessage", function(msg)
	local entity = msg:ReadEntity();
	local message = msg:ReadString();
	
	if (IsValid(entity)) then
		entity.cwMessage = message;
	end;
end);

usermessage.Hook("cwContainerPassword", function(msg)
	local entity = msg:ReadEntity();
	
	Derma_StringRequest("Password", "What is the password for this container?", nil, function(text)
		Clockwork:StartDataStream("ContainerPassword", {text, entity});
	end);
end);

usermessage.Hook("cwFrequency", function(msg)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", msg:ReadString(), function(text)
		Clockwork:RunCommand("SetFreq", text);
	end);
end);

Clockwork:HookDataStream("Notepad", function(data)
	local itemTable = Clockwork.item:CreateInstance(
		data.definition.index, data.definition.itemID,
		data.definition.data
	);
	
	if (Schema.notepadPanel
	and Schema.notepadPanel:IsValid()) then
		Schema.notepadPanel:Close();
		Schema.notepadPanel:Remove();
	end;
	
	Schema.notepadPanel = vgui.Create("cwNotepad");
	Schema.notepadPanel:Populate(data.text, itemTable);
	Schema.notepadPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

Clockwork:HookDataStream("GroupNotes", function(data)
	Schema.groupNotes = data;
	
	if (IsValid(Schema.groupPanel)) then
		Schema.groupPanel:Rebuild();
	end;
end);

usermessage.Hook("cwDealDmg", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	local amount = msg:ReadShort();
	
	if (IsValid(entity) and entity:IsPlayer()) then
		Schema.damageNotify[#Schema.damageNotify + 1] = {
			position = entity:GetShootPos() + (Vector() * math.random(-5, 5)),
			duration = duration,
			endTime = curTime + duration,
			color = Color(179, 46, 49, 255),
			text = amount.."dmg"
		};
	end;
end);

usermessage.Hook("cwTakeDmg", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	local amount = msg:ReadShort();
	
	if (IsValid(entity) and entity:IsPlayer()) then
		Schema.damageNotify[#Schema.damageNotify + 1] = {
			position = entity:GetShootPos() + (Vector() * math.random(-5, 5)),
			duration = duration,
			endTime = curTime + duration,
			color = Color(139, 174, 179, 255),
			text = amount.."dmg"
		};
		
		Schema.targetOutlines[entity] = curTime + 4;
	end;
end);

usermessage.Hook("cwDeath", function(msg)
	local weapon = msg:ReadEntity();
	
	if (!IsValid(weapon)) then
		Schema.deathType = "UNKNOWN CAUSES";
	else
		local itemTable = Clockwork.item:GetByWeapon(weapon);
		local class = weapon:GetClass();
		
		if (itemTable) then
			Schema.deathType = "A "..string.upper(itemTable("name"));
		elseif (class == "cw_hands") then
			Schema.deathType = "BEING PUNCHED TO DEATH";
		else
			Schema.deathType = "UNKNOWN CAUSES";
		end;
	end;
end);

usermessage.Hook("cwShotEffect", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 0.5;
	end;
	
	Schema.shotEffect = {curTime + duration, duration};
end);

usermessage.Hook("cwTearGassed", function(msg)
	Schema.tearGassed = CurTime() + 20;
end);

usermessage.Hook("cwFlashed", function(msg)
	local curTime = CurTime();
	
	Schema.stunEffects[#Schema.stunEffects + 1] = {curTime + 10, 10};
	Schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("cwStartGroup", function(msg)
	Derma_Query("Are you sure you want to start this group for "..FORMAT_CASH(1000, nil, true).."?", "Start the group.", "Yes", function()
		Clockwork:StartDataStream("StartGroup");
		gui.EnableScreenClicker(false);
	end, "No", function()
		gui.EnableScreenClicker(false);
	end);
end);

usermessage.Hook("cwGroupInvite", function(msg)
	Derma_Query("You have been invited to the "..msg:ReadString().." group.", "Join the group.", "Accept", function()
		Clockwork:StartDataStream("JoinGroup");
		gui.EnableScreenClicker(false);
	end, "Decline", function()
		gui.EnableScreenClicker(false);
	end);
end);

usermessage.Hook("cwClearEffects", function(msg)
	Schema.suppressEffect = nil;
	Schema.stunEffects = {};
	Schema.flashEffect = nil;
	Schema.tearGassed = nil;
	Schema.shotEffect = nil;
end);

usermessage.Hook("cwPrintCenter", function(msg)
	Schema:PrintTextCenter(
		msg:ReadString(), msg:ReadString(), "hl1/fvox/bell.wav", true
	);
end);

usermessage.Hook("cwNearMiss", function(msg)
	local nearMiss = {
		"03", "04", "05", "06", "07", "09", "10", "11", "12", "13", "14"
	};
	
	surface.PlaySound("weapons/fx/nearmiss/bulletltor"..nearMiss[math.random(1, #nearMiss)]..".wav");
	Schema.suppressEffect = CurTime() + 5;
end);

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Schema:Register();