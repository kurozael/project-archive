--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when the menu's items should be destroyed.
function openAura.schema:MenuItemsDestroy(menuItems)
	if ( !openAura.player:HasFlags(openAura.Client, "y") ) then
		menuItems:Destroy( openAura.option:GetKey("name_business") );
	end;
end;

-- Called each frame.
function openAura.schema:Think()
	local currentMap = game.GetMap();
	local validMaps = {
		["md_venetianredux_b2"] = Vector(-3985.6904, 1397.9601, 604.0056),
		["rp_necro_urban_v3b"] = Vector(3813.7615, 172.4379, 443.5957),
		["rp_necro_urban_v2"] = Vector(3813.7615, 172.4379, 443.5957),
		["rp_necro_urban_v1"] = Vector(3813.7615, 172.4379, 443.5957)
	};
	
	if ( validMaps[currentMap] and openAura:IsChoosingCharacter() ) then
		local curTime = CurTime();
		
		if (!self.nextDynamicLight or curTime >= self.nextDynamicLight) then
			self.nextDynamicLight = curTime + math.Rand(0, 1);
			
			local dynamicLight = DynamicLight(1337);
			
			if (dynamicLight) then
				dynamicLight.Brightness = 4;
				dynamicLight.DieTime = curTime + 0.1;
				dynamicLight.Decay = 512;
				dynamicLight.Size = 512;
				dynamicLight.Pos = validMaps[currentMap];
				dynamicLight.r = 255;
				dynamicLight.g = 255;
				dynamicLight.b = 255;
			end;
		end;
	end;
end;

-- Called when OpenAura has initialized.
function openAura.schema:OpenAuraInitialized()
	for k, v in pairs( openAura.item:GetAll() ) do
		if (!v.isBaseItem and !v.isRareItem) then
			v.business = true;
			v.access = "y";
			v.batch = 1;
		end;
	end;
end;

-- Called when the local player's character screen faction is needed.
function openAura.schema:GetPlayerCharacterScreenFaction(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass;
	end;
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

-- Called when screen space effects should be rendered.
function openAura.schema:RenderScreenspaceEffects()
	local modify = {};
	
	if ( !openAura:IsScreenFadedBlack() ) then
		local curTime = CurTime();
		
		if (self.flashEffect) then
			local timeLeft = math.Clamp( self.flashEffect[1] - curTime, 0, self.flashEffect[2] );
			local incrementer = 1 / self.flashEffect[2];
			
			if (timeLeft > 0) then
				modify = {};
				
				modify["$pp_colour_brightness"] = 0;
				modify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer);
				modify["$pp_colour_colour"] = 1 - (incrementer * timeLeft);
				modify["$pp_colour_addr"] = incrementer * timeLeft;
				modify["$pp_colour_addg"] = 0;
				modify["$pp_colour_addb"] = 0;
				modify["$pp_colour_mulr"] = 1;
				modify["$pp_colour_mulg"] = 0;
				modify["$pp_colour_mulb"] = 0;
				
				DrawColorModify(modify);
				
				if ( !self.flashEffect[3] ) then
					DrawMotionBlur( 1 - (incrementer * timeLeft), incrementer * timeLeft, self.flashEffect[2] );
				end;
			end;
		end;
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function openAura.schema:PlayerAdjustMotionBlurs(motionBlurs)
	if ( !openAura:IsScreenFadedBlack() ) then
		local curTime = CurTime();
		
		if ( self.flashEffect and self.flashEffect[3] ) then
			local timeLeft = math.Clamp( self.flashEffect[1] - curTime, 0, self.flashEffect[2] );
			local incrementer = 1 / self.flashEffect[2];
			
			if (timeLeft > 0) then
				motionBlurs.blurTable["flash"] = 1 - (incrementer * timeLeft);
			end;
		end;
	end;
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

-- Called when the local player's default color modify should be set.
function openAura.schema:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.03;
	colorModify["$pp_colour_contrast"] = 1.1;
	colorModify["$pp_colour_colour"] = 0.4;
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

-- Called when an entity's menu options are needed.
function openAura.schema:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "prop_ragdoll") then
		local player = openAura.entity:GetPlayer(entity);
		
		if ( !player or !player:Alive() ) then
			options["Loot"] = "aura_corpseLoot";
		end;
	elseif (entity:GetClass() == "aura_belongings") then
		options["Open"] = "aura_belongingsOpen";
	elseif (entity:GetClass() == "aura_breach") then
		options["Charge"] = "aura_breachCharge";
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

-- Called when a player's scoreboard options are needed.
function openAura.schema:GetPlayerScoreboardOptions(player, options, menu)
	if ( openAura.command:Get("CharPermaKill") ) then
		if ( openAura.player:HasFlags(openAura.Client, openAura.command:Get("CharPermaKill").access) ) then
			options["Perma-Kill"] = function()
				RunConsoleCommand( "aura", "CharPermaKill", player:Name() );
			end;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function openAura.schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local colorInformation = openAura.option:GetColor("information");
	local thirdPerson = "him";
	local mainStatus;
	local untieText;
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
		
		if (target:GetSharedVar("tied") != 0) then
			if (openAura.player:GetAction(openAura.Client) == "untie") then
				mainStatus = gender.. " is being untied.";
			else
				local untieText;
				
				if (target:GetShootPos():Distance( openAura.Client:GetShootPos() ) <= 192) then
					if (openAura.Client:GetSharedVar("tied") == 0) then
						mainStatus = "Press :+use: to untie "..thirdPerson..".";
						
						untieText = true;
					end;
				end;
				
				if (!untieText) then
					mainStatus = gender.." has been tied up.";
				end;
			end;
		elseif (openAura.player:GetAction(openAura.Client) == "tie") then
			mainStatus = gender.." is being tied up.";
		end;
		
		if (mainStatus) then
			y = openAura:DrawInfo(openAura:ParseData(mainStatus), x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called when the foreground HUD should be painted.
function openAura.schema:HUDPaintForeground()
	local curTime = CurTime();
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	if (openAura.Client:Alive() and openAura.Client:GetRagdollState() != RAGDOLL_KNOCKEDOUT) then
		if (self.stunEffects) then
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp( ( 255 / v[2] ) * (v[1] - curTime), 0, 255 );
				
				if (alpha == 0) then
					self.stunEffects[k] = nil;
				elseif ( !v[3] ) then
					draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha) );
				else
					v[3](alpha);
				end;
			end;
		end;
	end;
end;

-- Called to get the screen text info.
function openAura.schema:GetScreenTextInfo()
	local blackFadeAlpha = openAura:GetBlackFadeAlpha();
	
	if ( openAura.Client:GetSharedVar("permaKilled") ) then
		return {
			alpha = blackFadeAlpha,
			title = "THIS CHARACTER IS PERMANENTLY KILLED",
			text = "Go to the character menu to make a new one."
		};
	elseif ( openAura.Client:GetSharedVar("beingTied") ) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU ARE BEING TIED UP"
		};
	elseif (openAura.Client:GetSharedVar("tied") != 0) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU HAVE BEEN TIED UP"
		};
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