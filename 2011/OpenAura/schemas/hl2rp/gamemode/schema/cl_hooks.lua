--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when the local player's business is rebuilt.
function openAura.schema:PlayerBusinessRebuilt(panel, categories)
	local businessName = openAura.option:GetKey("name_business", true);
	
	if (!self.businessPanel) then
		self.businessPanel = panel;
	end;
	
	if (openAura.config:Get("permits"):Get() and openAura.player:GetFaction(openAura.Client) == FACTION_CITIZEN) then
		local permits = {};
		
		for k, v in pairs( openAura.item:GetAll() ) do
			if ( v.cost and v.access and !openAura:HasObjectAccess(openAura.Client, v) ) then
				if ( string.find(v.access, "1") ) then
					permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch);
				else
					for k2, v2 in pairs(openAura.schema.customPermits) do
						if ( string.find(v.access, v2.flag) ) then
							permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch);
							
							break;
						end;
					end;
				end;
			end;
		end;
		
		if (table.Count(permits) > 0) then
			local panelList = vgui.Create("DPanelList", panel);
			
			panel.permitsForm = vgui.Create("DForm");
			panel.permitsForm:SetName("Permits");
			panel.permitsForm:SetPadding(4);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			if ( openAura.player:HasFlags(openAura.Client, "x") ) then
				for k, v in pairs(permits) do
					panel.customData = {information = v};
					
					if (k == "generalGoods") then
						panel.customData.description = "Purchase a permit to add general goods to your "..businessName..".";
						panel.customData.Callback = function()
							openAura:RunCommand("PermitBuy", "generalgoods");
						end;
						panel.customData.model = "models/props_junk/cardboard_box004a.mdl";
						panel.customData.name = "General Goods";
					else
						for k2, v2 in pairs(openAura.schema.customPermits) do
							if (v2.key == k) then
								panel.customData.description = "Purchase a permit to add "..string.lower(v2.name).." to your "..businessName..".";
								panel.customData.Callback = function()
									openAura:RunCommand("PermitBuy", k2);
								end;
								panel.customData.model = v2.model;
								panel.customData.name = v2.name;
								
								break;
							end;
						end;
					end;
					
					panelList:AddItem( vgui.Create("aura_BusinessCustom", panel) );
				end;
			else
				panel.customData = {
					description = "Create a "..businessName.." which allows you to purchase permits.",
					information = openAura.config:Get("business_cost"):Get(),
					Callback = function()
						openAura:RunCommand("PermitBuy", "business");
					end,
					model = "models/props_c17/briefcase001a.mdl",
					name = "Create "..openAura.option:GetKey("name_business")
				};
				
				panelList:AddItem( vgui.Create("aura_BusinessCustom", panel) );
			end;
			
			panel.permitsForm:AddItem(panelList);
			panel.panelList:AddItem(panel.permitsForm);
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

-- Called when the target player's fade distance is needed.
function openAura.schema:GetTargetPlayerFadeDistance(player)
	if ( IsValid( self:GetScannerEntity(openAura.Client) ) ) then
		return 512;
	end;
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

-- Called when a player's typing display position is needed.
function openAura.schema:GetPlayerTypingDisplayPosition(player)
	local scannerEntity = self:GetScannerEntity(player);
	
	if ( IsValid(scannerEntity) ) then
		local position = scannerEntity:GetBonePosition( scannerEntity:LookupBone("Scanner.Body") );
		local curTime = CurTime();
		
		if (!position) then
			return scannerEntity:GetPos() + Vector(0, 0, 8);
		else
			return position;
		end;
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
	elseif ( entity:IsNPC() ) then
		local name = entity:GetNetworkedString("aura_Name");
		local title = entity:GetNetworkedString("aura_Title");
		
		if (name != "" and title != "") then
			info.y = openAura:DrawInfo(name, info.x, info.y, Color(255, 255, 100, 255), info.alpha);
			info.y = openAura:DrawInfo(title, info.x, info.y, Color(255, 255, 255, 255), info.alpha);
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
		
		if ( self:PlayerIsCombine(openAura.Client) ) then
			render.UpdateScreenEffectTexture();
			
			self.combineOverlay:SetMaterialFloat("$refractamount", 0.3);
			self.combineOverlay:SetMaterialFloat("$envmaptint", 0);
			self.combineOverlay:SetMaterialFloat("$envmap", 0);
			self.combineOverlay:SetMaterialFloat("$alpha", 0.5);
			self.combineOverlay:SetMaterialInt("$ignorez", 1);
			
			render.SetMaterial(self.combineOverlay);
			render.DrawScreenQuad();
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

-- Called when the scoreboard's class players should be sorted.
function openAura.schema:ScoreboardSortClassPlayers(class, a, b)
	if (class == "Civil Protection" or class == "Overwatch Transhuman Arm") then
		local rankA = self:GetPlayerCombineRank(a);
		local rankB = self:GetPlayerCombineRank(b);
		
		if (rankA == rankB) then
			return a:Name() < b:Name();
		else
			return rankA > rankB;
		end;
	end;
end;

-- Called when a player's scoreboard class is needed.
function openAura.schema:GetPlayerScoreboardClass(player)
	local customClass = player:GetSharedVar("customClass");
	local faction = openAura.player:GetFaction(player);
	
	if (customClass != "") then
		return customClass;
	end;
	
	if (faction == FACTION_MPF) then
		return "Civil Protection";
	elseif (faction == FACTION_OTA) then
		return "Overwatch Transhuman Arm";
	end;
end;

-- Called when the local player's character screen faction is needed.
function openAura.schema:GetPlayerCharacterScreenFaction(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass;
	end;
end;

-- Called when the local player attempts to zoom.
function openAura.schema:PlayerCanZoom()
	if ( !self:PlayerIsCombine(openAura.Client) ) then
		return false;
	end;
end;

-- Called when a player's scoreboard options are needed.
function openAura.schema:GetPlayerScoreboardOptions(player, options, menu)
	if ( openAura.command:Get("PlyAddServerWhitelist")
	or openAura.command:Get("PlyRemoveServerWhitelist") ) then
		if ( openAura.player:HasFlags(openAura.Client, openAura.command:Get("PlyAddServerWhitelist").access) ) then
			options["Server Whitelist"] = {};
			
			if ( openAura.command:Get("PlyAddServerWhitelist") ) then
				options["Server Whitelist"]["Add"] = function()
					Derma_StringRequest(player:Name(), "What server whitelist would you like to add them to?", "", function(text)
						openAura:RunCommand("PlyAddServerWhitelist", player:Name(), text);
					end);
				end;
			end;
			
			if ( openAura.command:Get("PlyRemoveServerWhitelist") ) then
				options["Server Whitelist"]["Remove"] = function()
					Derma_StringRequest(player:Name(), "What server whitelist would you like to remove them from?", "", function(text)
						openAura:RunCommand("PlyRemoveServerWhitelist", player:Name(), text);
					end);
				end;
			end;
		end;
	end;
	
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
	
	if ( openAura.command:Get("CharPermaKill") ) then
		if ( openAura.player:HasFlags(openAura.Client, openAura.command:Get("CharPermaKill").access) ) then
			options["Perma-Kill"] = function()
				RunConsoleCommand( "aura", "CharPermaKill", player:Name() );
			end;
		end;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function openAura.schema:ScoreboardAdjustPlayerInfo(info)
	if ( self:IsPlayerCombineRank(info.player, "SCN") ) then
		if ( self:IsPlayerCombineRank(info.player, "SYNTH") ) then
			info.model = "models/shield_scanner.mdl";
		else
			info.model = "models/combine_scanner.mdl";
		end;
	end;
end;

-- Called when the local player's class model info should be adjusted.
function openAura.schema:PlayerAdjustClassModelInfo(class, info)
	if (class == CLASS_MPS) then
		if ( self:IsPlayerCombineRank(openAura.Client, "SCN")
		and self:IsPlayerCombineRank(openAura.Client, "SYNTH") ) then
			info.model = "models/shield_scanner.mdl";
		else
			info.model = "models/combine_scanner.mdl";
		end;
	end;
end;

-- Called when the local player's default colorify should be set.
function openAura.schema:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.02;
	colorModify["$pp_colour_contrast"] = 1.2;
	colorModify["$pp_colour_colour"] = 0.5;
end;

-- Called when the local player's colorify should be adjusted.
function openAura.schema:PlayerAdjustColorModify(colorModify)
	local antiDepressants = openAura.Client:GetSharedVar("antidepressants");
	local frameTime = FrameTime();
	local interval = FrameTime() / 10;
	local curTime = CurTime();
	
	if (!self.colorModify) then
		self.colorModify = {
			brightness = colorModify["$pp_colour_brightness"],
			contrast = colorModify["$pp_colour_contrast"],
			color = colorModify["$pp_colour_colour"]
		};
	end;
	
	if (antiDepressants > curTime) then
		self.colorModify.brightness = math.Approach(self.colorModify.brightness, 0,interval);
		self.colorModify.contrast = math.Approach(self.colorModify.contrast, 1, interval);
		self.colorModify.color = math.Approach(self.colorModify.color, 1, interval);
	else
		self.colorModify.brightness = math.Approach(self.colorModify.brightness, colorModify["$pp_colour_brightness"], interval);
		self.colorModify.contrast = math.Approach(self.colorModify.contrast, colorModify["$pp_colour_contrast"], interval);
		self.colorModify.color = math.Approach(self.colorModify.color, colorModify["$pp_colour_colour"], interval);
	end;
	
	colorModify["$pp_colour_brightness"] = self.colorModify.brightness;
	colorModify["$pp_colour_contrast"] = self.colorModify.contrast;
	colorModify["$pp_colour_colour"] = self.colorModify.color;
end;

-- Called when the local player attempts to see a class.
function openAura.schema:PlayerCanSeeClass(class)
	if ( class.index == CLASS_MPS and !self:IsPlayerCombineRank(openAura.Client, "SCN") ) then
		return false;
	elseif ( class.index == CLASS_MPR and !self:IsPlayerCombineRank(openAura.Client, "RCT") ) then
		return false;
	elseif ( class.index == CLASS_EMP and !self:IsPlayerCombineRank(openAura.Client, "EpU") ) then
		return false;
	elseif ( class.index == CLASS_OWS and !self:IsPlayerCombineRank(openAura.Client, "OWS") ) then
		return false;
	elseif ( class.index == CLASS_EOW and !self:IsPlayerCombineRank(openAura.Client, "EOW") ) then
		return false;
	elseif (class.index == CLASS_MPU) then
		if ( self:IsPlayerCombineRank(openAura.Client, "SCN") or self:IsPlayerCombineRank(openAura.Client, "EpU")
		or self:IsPlayerCombineRank(openAura.Client, "RCT") ) then
			return false;
		end;
	end;
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when the target's status should be drawn.
function openAura.schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local informationColor = openAura.option:GetColor("information");
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
			y = openAura:DrawInfo(openAura:ParseData(mainStatus), x, y, informationColor, alpha);
		end;
		
		return y;
	end;
end;

-- Called when the player info text is needed.
function openAura.schema:GetPlayerInfoText(playerInfoText)
	local citizenID = openAura.Client:GetSharedVar("citizenID");
	
	if (citizenID) then
		if (openAura.player:GetFaction(openAura.Client) == FACTION_CITIZEN) then
			playerInfoText:Add("CITIZEN_ID", "Citizen ID: #"..citizenID);
		end;
	end;
end;

-- Called to check if a player does have an flag.
function openAura.schema:PlayerDoesHaveFlag(player, flag)
	if ( !openAura.config:Get("permits"):Get() ) then
		if (flag == "x" or flag == "1") then
			return false;
		end;
		
		for k, v in pairs(self.customPermits) do
			if (v.flag == flag) then
				return false;
			end;
		end;
	end;
end;

-- Called to check if a player does recognise another player.
function openAura.schema:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	if (self:PlayerIsCombine(player) or openAura.player:GetFaction(player) == FACTION_ADMIN) then
		return true;
	end;
end;

-- Called each tick.
function openAura.schema:Tick()
	if ( IsValid(openAura.Client) ) then
		if ( self:PlayerIsCombine(openAura.Client) ) then
			local curTime = CurTime();
			local health = openAura.Client:Health();
			local armor = openAura.Client:Armor();

			if (!self.nextHealthWarning or curTime >= self.nextHealthWarning) then
				if (self.lastHealth) then
					if (health < self.lastHealth) then
						if (health == 0) then
							self:AddCombineDisplayLine( "ERROR! Shutting down...", Color(255, 0, 0, 255) );
						else
							self:AddCombineDisplayLine( "WARNING! Physical bodily trauma detected...", Color(255, 0, 0, 255) );
						end;
						
						self.nextHealthWarning = curTime + 2;
					elseif (health > self.lastHealth) then
						if (health == 100) then
							self:AddCombineDisplayLine( "Physical body systems restored...", Color(0, 255, 0, 255) );
						else
							self:AddCombineDisplayLine( "Physical body systems regenerating...", Color(0, 0, 255, 255) );
						end;
						
						self.nextHealthWarning = curTime + 2;
					end;
				end;
				
				if (self.lastArmor) then
					if (armor < self.lastArmor) then
						if (armor == 0) then
							self:AddCombineDisplayLine( "WARNING! External protection exhausted...", Color(255, 0, 0, 255) );
						else
							self:AddCombineDisplayLine( "WARNING! External protection damaged...", Color(255, 0, 0, 255) );
						end;
						
						self.nextHealthWarning = curTime + 2;
					elseif (armor > self.lastArmor) then
						if (armor == 100) then
							self:AddCombineDisplayLine( "External protection systems restored...", Color(0, 255, 0, 255) );
						else
							self:AddCombineDisplayLine( "External protection systems regenerating...", Color(0, 0, 255, 255) );
						end;
						
						self.nextHealthWarning = curTime + 2;
					end;
				end;
			end;
			
			if (!self.nextRandomLine or curTime >= self.nextRandomLine) then
				local text = self.randomDisplayLines[ math.random(1, #self.randomDisplayLines) ];
				
				if (text and self.lastRandomDisplayLine != text) then
					self:AddCombineDisplayLine(text);
					
					self.lastRandomDisplayLine = text;
				end;
				
				self.nextRandomLine = curTime + 3;
			end;
			
			self.lastHealth = health;
			self.lastArmor = armor;
		end;
	end;
end;

-- Called when the foreground HUD should be painted.
function openAura.schema:HUDPaintForeground()
	local curTime = CurTime();
	
	if ( openAura.Client:Alive() ) then
		if (self.stunEffects) then
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp( ( 255 / v[2] ) * (v[1] - curTime), 0, 255 );
				
				if (alpha != 0) then
					draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha) );
				else
					table.remove(self.stunEffects, k);
				end;
			end;
		end;
	end;
end;

-- Called when the top screen HUD should be painted.
function openAura.schema:HUDPaintTopScreen(info)
	local blackFadeAlpha = openAura:GetBlackFadeAlpha();
	local colorWhite = openAura.option:GetColor("white");
	local curTime = CurTime();
	
	if (self:PlayerIsCombine(openAura.Client) and self.combineDisplayLines) then
		local height = draw.GetFontHeight("BudgetLabel");
		
		for k, v in ipairs(self.combineDisplayLines) do
			if ( curTime >= v[2] ) then
				table.remove(self.combineDisplayLines, k);
			else
				local color = v[4] or colorWhite;
				local textColor = Color(color.r, color.g, color.b, 255 - blackFadeAlpha);
				
				draw.SimpleText(string.sub( v[1], 1, v[3] ), "BudgetLabel", info.x, info.y, textColor);
				
				if ( v[3] < string.len( v[1] ) ) then
					v[3] = v[3] + 1;
				end;
				
				info.y = info.y + height;
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

-- Called when the chat box info should be adjusted.
function openAura.schema:ChatBoxAdjustInfo(info)
	if ( IsValid(info.speaker) ) then
		if (info.data.anon) then
			info.name = "Somebody";
		end;
		
		if ( self:PlayerIsCombine(info.speaker) ) then
			if ( self:IsPlayerCombineRank(info.speaker, "SCN") ) then
				if (info.class == "radio" or info.class == "radio_eavesdrop") then
					info.name = "Dispatch";
				end;
			end;
		end;
	end;
end;