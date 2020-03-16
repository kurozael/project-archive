--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

--[[
	This process must be performed in every schema's cl_init.lua
	to initialize Clockwork properly and derive from sub-gamemodes
	effectively.
--]]
Clockwork = GM; DeriveGamemode("Clockwork");

--[[ Include the shared schema file. --]]
include("shared.lua");

--[[ Define some member variables for the schema. --]]
Clockwork.schema.thirdPersonAmount = 0;
Clockwork.schema.heatwaveMaterial = Material("sprites/heatwave");
Clockwork.schema.heatwaveMaterial:SetMaterialFloat("$refractamount", 0);
Clockwork.schema.fishEyeTexture = Material("models/props_c17/fisheyelens");
Clockwork.schema.shinyMaterial = Material("models/shiny");
Clockwork.schema.targetOutlines = {};
Clockwork.schema.damageNotify = {};
Clockwork.schema.stunEffects = {};

-- A function to create a hotkey spawn icon.
function Clockwork.schema:CreateHotkeySpawnIcon(itemTable)
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
function Clockwork.schema:AddHotkey(itemTable)
	if (#self.hotkeyItems < 10) then
		table.insert(self.hotkeyItems, {
			uniqueID = itemTable("uniqueID"), name = itemTable("name")
		});
		
		self:SaveHotkeys();
	end;
end;

-- A function to remove a hotkey.
function Clockwork.schema:RemoveHotkey(itemTable)
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
function Clockwork.schema:SaveHotkeys()
	local hotkeyItems = {};
		for k, v in pairs(self.hotkeyItems) do
			table.insert(hotkeyItems, {uniqueID = v.uniqueID, name = v.name});
		end;
	Clockwork:SaveSchemaData("hotkeys/"..self.hotkeyFile, hotkeyItems);
end;

-- A function to load the hotkeys.
function Clockwork.schema:LoadHotkeys(iCharacterKey)
	if (self.hotkeyItems) then
		for k, v in pairs(self.hotkeyItems) do
			v.panel:Remove();
		end;
	end;
	
	self.hotkeyFile = "hotkeys/"..iCharacterKey;
	self.hotkeyItems = Clockwork:RestoreSchemaData(self.hotkeyFile);
end;

-- A function to get whether a text entry is being used.
function Clockwork.schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if (self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;

local OUTLINE_MATERIAL = Material("white_outline");

-- A function to draw a basic outline.
function Clockwork.schema:DrawBasicOutline(entity, forceColor, throughWalls)
	local r, g, b, a = entity:GetColor();
	local outlineColor = forceColor or Color(255, 0, 255, 255);
	
	if (throughWalls) then
		cam.IgnoreZ(true);
	end;
	
	render.SuppressEngineLighting(true);
	render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
	render.SetAmbientLight(1, 1, 1);
	render.SetBlend(outlineColor.a / 255);
	entity:SetModelScale(Vector() * 1.025);
	
	SetMaterialOverride(OUTLINE_MATERIAL);
		entity:DrawModel();
	SetMaterialOverride(nil);
	
	entity:SetModelScale(Vector());
	render.SetBlend(1);
	render.SetColorModulation(r / 255, g / 255, b / 255);
	render.SuppressEngineLighting(false);
	
	if (!throughWalls) then
		entity:DrawModel();
	else
		cam.IgnoreZ(false);
	end;
end;

Clockwork.config:AddToSystem("intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("intro_text_big", "The big text displayed for the introduction.");
Clockwork.config:AddToSystem("max_safebox_weight", "The maximum weight a player's safebox can hold.");

--[[ Remove the setting for enabling/disabling the top bars, as we're showing them anyway! --]]
Clockwork.setting:Remove(nil, nil, nil, "cwTopBars");

Clockwork.chatBox:RegisterClass("destroyed_item", "ooc", function(info)
	local itemColor = Color(255, 206, 73, 255);
	local itemTable = Clockwork.item:FindInstance(info.text);
	local rarityName = "unique";
	
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
		info.filtered, nil, "A "..rarityName.." item ", itemColor,
		OnHoverCallback, "["..itemTable("name").."]", " has been destroyed!"
	);
end);

Clockwork.chatBox:RegisterClass("found_item", "ooc", function(info)
	local itemColor = nil;
	local itemTable = Clockwork.item:FindInstance(info.text);
	local rarityName = nil;
	
	if (!itemTable) then return; end;
	
	if (itemTable:GetData("Rarity") == 2) then
		itemColor = Color(255, 85, 85, 255);
		rarityName = "legendary";
	elseif (itemTable:GetData("Rarity") == 3) then
		itemColor = Color(255, 206, 73, 255);
		rarityName = "unique";
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
			info.filtered, nil, "A "..rarityName.." item ", itemColor,
			OnHoverCallback, "["..itemTable("name").."]", " has been discovered by "..info.name.."."
		);
	end;
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
	
	if (Clockwork.schema.notepadPanel
	and Clockwork.schema.notepadPanel:IsValid()) then
		Clockwork.schema.notepadPanel:Close();
		Clockwork.schema.notepadPanel:Remove();
	end;
	
	Clockwork.schema.notepadPanel = vgui.Create("cwNotepad");
	Clockwork.schema.notepadPanel:Populate(data.text, itemTable);
	Clockwork.schema.notepadPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

usermessage.Hook("cwDealDmg", function(msg)
	local duration = 2;
	local curTime = UnPredictedCurTime();
	local entity = msg:ReadEntity();
	local amount = msg:ReadShort();
	
	if (IsValid(entity) and entity:IsPlayer()) then
		Clockwork.schema.damageNotify[#Clockwork.schema.damageNotify + 1] = {
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
		Clockwork.schema.damageNotify[#Clockwork.schema.damageNotify + 1] = {
			position = entity:GetShootPos() + (Vector() * math.random(-5, 5)),
			duration = duration,
			endTime = curTime + duration,
			color = Color(139, 174, 179, 255),
			text = amount.."dmg"
		};
		
		Clockwork.schema.targetOutlines[entity] = curTime + 60;
	end;
end);

usermessage.Hook("cwDeath", function(msg)
	local weapon = msg:ReadEntity();
	
	if (!IsValid(weapon)) then
		Clockwork.schema.deathType = "UNKNOWN CAUSES";
	else
		local itemTable = Clockwork.item:GetByWeapon(weapon);
		local class = weapon:GetClass();
		
		if (itemTable) then
			Clockwork.schema.deathType = "A "..string.upper(itemTable("name"));
		elseif (class == "cw_hands") then
			Clockwork.schema.deathType = "BEING PUNCHED TO DEATH";
		else
			Clockwork.schema.deathType = "UNKNOWN CAUSES";
		end;
	end;
end);

usermessage.Hook("cwShotEffect", function(msg)
	local duration = msg:ReadFloat();
	local curTime = CurTime();
	
	if (!duration or duration == 0) then
		duration = 0.5;
	end;
	
	Clockwork.schema.shotEffect = {curTime + duration, duration};
end);

usermessage.Hook("cwTearGassed", function(msg)
	Clockwork.schema.tearGassed = CurTime() + 20;
end);

usermessage.Hook("cwFlashed", function(msg)
	local curTime = CurTime();
	
	Clockwork.schema.stunEffects[#Clockwork.schema.stunEffects + 1] = {curTime + 10, 10};
	Clockwork.schema.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

usermessage.Hook("cwStartGroup", function(msg)
	Derma_Query("Are you sure you want to start this group for "..FORMAT_CASH(2000, nil, true).."?", "Start the group.", "Yes", function()
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
	Clockwork.schema.suppressEffect = nil;
	Clockwork.schema.stunEffects = {};
	Clockwork.schema.flashEffect = nil;
	Clockwork.schema.tearGassed = nil;
	Clockwork.schema.shotEffect = nil;
end);

usermessage.Hook("cwNearMiss", function(msg)
	local nearMiss = {
		"03", "04", "05", "06", "07", "09", "10", "11", "12", "13", "14"
	};
	
	surface.PlaySound("weapons/fx/nearmiss/bulletltor"..nearMiss[math.random(1, #nearMiss)]..".wav");
	Clockwork.schema.suppressEffect = CurTime() + 10;
end);

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Clockwork.schema:Register();