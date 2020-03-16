--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the menu's items should be destroyed.
function openAura.schema:MenuItemsDestroy(menuItems)
	if ( !openAura.player:HasFlags(openAura.Client, "T") ) then
		menuItems:Destroy( openAura.option:GetKey("name_business") );
	end;
	
	menuItems:Destroy( openAura.option:GetKey("name_attributes") );
end;

-- Called when a player's scoreboard options are needed.
function openAura.schema:GetPlayerScoreboardOptions(player, options, menu)
	if ( openAura.command:Get("CharSetCustomClass") ) then
		if ( openAura.player:HasFlags(openAura.Client, openAura.command:Get("CharSetCustomClass").access) ) then
			options["Custom Class"] = {};
			options["Custom Class"]["Set"] = function()
				Derma_StringRequest(player:Name(), "What would you like to set their custom class to?", player:GetSharedVar("customClass"), function(text)
					openAura:RunCommand("CharSetCustomClass", player:Name(), text);
				end);
			end;
			
			if (player:GetSharedVar("customClass") != "") then
				options["Custom Class"]["Take"] = function()
					openAura:RunCommand( "CharTakeCustomClass", player:Name() );
				end;
			end;
		end;
	end;
end;

-- Called when the local player is created.
function openAura.schema:LocalPlayerCreated()
	openAura:RegisterNetworkProxy(openAura.Client, "clothes", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			openAura.inventory:Rebuild();
		end;
	end);
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when a player's scoreboard class is needed.
function openAura.schema:GetPlayerScoreboardClass(player)
	local customClass = player:GetSharedVar("customClass");
	
	if (customClass != "") then
		return customClass;
	end;
end;

-- Called when the local player's item functions should be adjusted.
function openAura.schema:PlayerAdjustItemFunctions(itemTable, itemFunctions)
	if (openAura.player:HasFlags(openAura.Client, "T") and itemTable.cost) then
		itemFunctions[#itemFunctions + 1] = "Caps";
	end;
end;

-- Called when the local player's character screen faction is needed.
function openAura.schema:GetPlayerCharacterScreenFaction(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass;
	end;
end;

-- Called when the local player's default color modify should be set.
function openAura.schema:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.02;
	colorModify["$pp_colour_contrast"] = 1.1;
	colorModify["$pp_colour_colour"] = 0.6;
end;

-- Called when the local player's color modify should be adjusted.
function openAura.schema:PlayerAdjustColorModify(colorModify)
	local choosingCharacter = openAura:IsChoosingCharacter();
	local frameTime = FrameTime();
	local interval = frameTime * 0.05;
	
	if (!self.colorModify) then
		self.colorModify = {
			brightness = colorModify["$pp_colour_brightness"],
			contrast = colorModify["$pp_colour_contrast"],
			color = colorModify["$pp_colour_colour"]
		};
	end;
	
	if ( choosingCharacter or openAura.menu:GetOpen() ) then
		if (choosingCharacter) then
			interval = frameTime * 0.25;
		end;
		
		self.colorModify.brightness = math.Approach(self.colorModify.brightness, -0.2,interval);
		self.colorModify.contrast = math.Approach(self.colorModify.contrast, 2, interval);
		self.colorModify.color = math.Approach(self.colorModify.color, 0, interval);
	else
		self.colorModify.brightness = math.Approach(self.colorModify.brightness, colorModify["$pp_colour_brightness"], interval);
		self.colorModify.contrast = math.Approach(self.colorModify.contrast, colorModify["$pp_colour_contrast"], interval);
		self.colorModify.color = math.Approach(self.colorModify.color, colorModify["$pp_colour_colour"], interval);
	end;
	
	colorModify["$pp_colour_brightness"] = self.colorModify.brightness;
	colorModify["$pp_colour_contrast"] = self.colorModify.contrast;
	colorModify["$pp_colour_colour"] = self.colorModify.color;
end;

-- Called when an entity's target ID HUD should be painted.
function openAura.schema:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	
	if (entity:GetClass() == "prop_physics") then
		local physDesc = entity:GetNetworkedString("physDesc");
		
		if (physDesc != "") then
			info.y = openAura:DrawInfo(physDesc, info.x, info.y, colorWhite, info.alpha);
		end;
	end;
end;

-- Called when a text entry has gotten focus.
function openAura.schema:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel;
end;

-- Called when a text entry has lost focus.
function openAura.schema:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil;
end;

-- Called when the cinematic intro info is needed.
function openAura.schema:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self:GetAuthor()..".",
		title = openAura.config:Get("intro_text_big"):Get(),
		text = openAura.config:Get("intro_text_small"):Get()
	};
end;

-- Called when the character background blur should be drawn.
function openAura.schema:ShouldDrawCharacterBackgroundBlur()
	return false;
end;

-- Called when an entity's menu options are needed.
function openAura.schema:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "prop_ragdoll") then
		local player = openAura.entity:GetPlayer(entity);
		
		if ( !player or !player:Alive() ) then
			options["Mutilate"] = "aura_corpseMutilate";
		end;
	elseif (entity:GetClass() == "aura_radio") then
		if ( !entity:IsOff() ) then
			options["Turn Off"] = "aura_radioToggle";
		else
			options["Turn On"] = "aura_radioToggle";
		end;
		
		options["Set Frequency"] = function()
			Derma_StringRequest("Frequency", "What would you like to set the frequency to?", frequency, function(text)
				if ( IsValid(entity) ) then
					openAura.entity:ForceMenuOption(entity, "Set Frequency", text);
				end;
			end);
		end;
		
		options["Take"] = "aura_radioTake";
	end;
end;

-- Called when the target's status should be drawn.
function openAura.schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local colorInformation = openAura.option:GetColor("information");
	local thirdPerson = "him";
	local mainStatus = nil;
	local gender = "He";
	local action = openAura.player:GetAction(target);
	
	if (openAura.player:GetGender(target) == GENDER_FEMALE) then
		thirdPerson = "her";
		gender = "She";
	end;
	
	if ( target:Alive() ) then
		if (action == "die") then
			mainStatus = gender.." is in critical condition.";
		end;
		
		if (target:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
			mainStatus = gender.." is clearly unconscious.";
		end;
		
		if (mainStatus) then
			y = openAura:DrawInfo(mainStatus, x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called when the chat box info should be adjusted.
function openAura.schema:ChatBoxAdjustInfo(info)
	if ( IsValid(info.speaker) ) then
		if (info.data.anon) then
			info.name = "Somebody";
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function openAura.schema:GetPostProgressBarInfo()
	if ( openAura.Client:Alive() ) then
		local action, percentage = openAura.player:GetAction(openAura.Client, true);
		
		if (action == "die") then
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;