--[[
Name: "cl_hooks.lua".
Product: "HL2 RP".
--]]

function kuroScript.game:KuroScriptInitialized()
	KS_CONVAR_HIDEDISPLAY = kuroScript.frame:CreateClientConVar("ks_hidedisplay", 1, true, true);
	KS_CONVAR_DONATORICON = kuroScript.frame:CreateClientConVar("ks_donatoricon", "", true, true);
end;

-- Called when the context menu is opened.
function kuroScript.game:OnContextMenuOpen()
	timer.Simple(FrameTime() * 0.5, function()
		if ( vgui.CursorVisible() ) then
			local target = g_LocalPlayer:GetEyeTraceNoCursor().Entity;
			
			-- Check if a statement is true.
			if ( self.voiceMenu and self.voiceMenu:IsValid() ) then
				self.voiceMenu:Remove();
			end;
			
			-- Check if a statement is true.
			if (ValidEntity(target) and target:IsPlayer() and target:GetPos():Distance( g_LocalPlayer:GetPos() ) <= 192) then
				local playerIsCombine = self:PlayerIsCombine(g_LocalPlayer);
				local targetIsCombine = self:PlayerIsCombine(target);
				local options = {};
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in pairs(self.menuVoices) do
					if ( (v[1] == "Combine" and playerIsCombine) or (v[1] == "Human" and !playerIsCombine) ) then
						if ( (v[2] == "Combine" and targetIsCombine) or (v[2] == "Human" and !targetIsCombine) ) then
							local command = k;
							local phrase = v[3];
							
							-- Set some information.
							options[phrase] = function()
								RunConsoleCommand("say", command);
							end;
						end;
					end;
				end;
				
				-- Check if a statement is true.
				if (table.Count(options) > 0) then
					self.voiceMenu = kuroScript.frame:AddMenuFromData(nil, options);
				end;
			end;
		end;
	end);
end;

-- Called when the context menu is closed.
function kuroScript.game:OnContextMenuClose()
	if ( self.voiceMenu and self.voiceMenu:IsValid() ) then
		self.voiceMenu:Remove();
	end;
end;

-- Called when the local player's business is rebuilt.
function kuroScript.game:PlayerBusinessRebuilt(panel, categories)
	if (!self.businessPanel) then
		self.businessPanel = panel;
	end;
	
	-- Check if a statement is true.
	if (kuroScript.config.Get("permits"):Get() and kuroScript.player.GetClass(g_LocalPlayer) == CLASS_CIT) then
		local permits = {};
		local k2, v2;
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.item.stored) do
			if ( v.cost and v.access and !kuroScript.frame:HasObjectAccess(g_LocalPlayer, v) ) then
				if ( string.find(v.access, "1") ) then
					permits.perpetuities = (permits.perpetuities or 0) + (v.cost * v.batch);
				elseif ( string.find(v.access, "2") ) then
					permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch);
				else
					for k2, v2 in pairs(kuroScript.game.customPermits) do
						if ( string.find(v.access, v2.flag) ) then
							permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch);
							
							-- Break the loop.
							break;
						end;
					end;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (table.Count(permits) > 0) then
			local panelList = vgui.Create("DPanelList", panel);
			
			-- Set some information.
			panel.permitsForm = vgui.Create("DForm");
			panel.permitsForm:SetName("Permits");
			panel.permitsForm:SetPadding(4);
			
			-- Set some information.
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			-- Check if a statement is true.
			if ( kuroScript.player.HasAccess(g_LocalPlayer, "x") ) then
				for k, v in pairs(permits) do
					panel.customData = {cost = v * 2};
					
					-- Check if a statement is true.
					if (k == "perpetuities") then
						panel.customData.description = "Purchase a permit to add perpetuities to your business.";
						panel.customData.callback = function()
							RunConsoleCommand("ks", "permit", "perpetuities");
						end;
						panel.customData.model = "models/props_junk/cardboard_box004a.mdl";
						panel.customData.name = "Perpetuities";
					elseif (k == "generalGoods") then
						panel.customData.description = "Purchase a permit to add general goods to your business.";
						panel.customData.callback = function()
							RunConsoleCommand("ks", "permit", "generalgoods");
						end;
						panel.customData.model = "models/props_junk/garbage_metalcan002a.mdl";
						panel.customData.name = "General Goods";
					else
						for k2, v2 in pairs(kuroScript.game.customPermits) do
							if (v2.key == k) then
								panel.customData.description = "Purchase a permit to add "..string.lower(v2.name).." to your business.";
								panel.customData.callback = function()
									RunConsoleCommand("ks", "permit", k2);
								end;
								panel.customData.model = v2.model;
								panel.customData.name = v2.name;
								
								-- Break the loop.
								break;
							end;
						end;
					end;
					
					-- Add an item to the panel list.
					panelList:AddItem( vgui.Create("ks_BusinessCustom", panel) );
				end;
			else
				panel.customData = {
					description = "Create a business which allows you to purchase permits.",
					callback = function()
						RunConsoleCommand("ks", "permit", "business");
					end,
					model = "models/props_c17/briefcase001a.mdl",
					name = "Create Business",
					cost = kuroScript.config.Get("business_cost"):Get()
				};
				
				-- Add an item to the panel list.
				panelList:AddItem( vgui.Create("ks_BusinessCustom", panel) );
			end;
			
			-- Add an item to the panel list.
			panel.permitsForm:AddItem(panelList);
			panel.panelList:AddItem(panel.permitsForm);
		end;
	end;
end;

-- Called when the target player's fade distance is needed.
function kuroScript.game:GetTargetPlayerFadeDistance(player)
	if ( ValidEntity( self:GetScannerEntity(g_LocalPlayer) ) ) then
		return 512;
	end;
end;

-- Called when a player's typing display position is needed.
function kuroScript.game:GetPlayerTypingDisplayPosition(player)
	local scannerEntity = self:GetScannerEntity(player);
	
	-- Check if a statement is true.
	if ( ValidEntity(scannerEntity) ) then
		local position = scannerEntity:GetBonePosition( scannerEntity:LookupBone("Scanner.Body") );
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if (position) then
			return position + Vector( 0, 0, 16 + (math.sin(curTime) * 2) );
		else
			return scannerEntity:GetPos() + Vector( 0, 0, 32 + (math.sin(curTime) * 2) );
		end;
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function kuroScript.game:HUDPaintEntityTargetID(entity, info)
	if (entity:GetClass() == "prop_ragdoll") then
		if ( entity:GetNetworkedBool("ks_Decaying") or entity:GetNetworkedBool("ks_PermaKilled") ) then
			local name = entity:GetNetworkedString("ks_Name");
			
			-- Check if a statement is true.
			if (name and name != "") then
				info.y = kuroScript.frame:DrawInfo(name, info.x, info.y, Color(255, 255, 100, 255), info.alpha);
			else
				info.y = kuroScript.frame:DrawInfo("Corpse", info.x, info.y, Color(255, 255, 100, 255), info.alpha);
			end;
			
			-- Check if a statement is true.
			if ( entity:GetNetworkedBool("ks_PermaKilled") ) then
				info.y = kuroScript.frame:DrawInfo("Permanently Killed", info.x, info.y, COLOR_WHITE, info.alpha);
			else
				info.y = kuroScript.frame:DrawInfo("Decaying", info.x, info.y, COLOR_WHITE, info.alpha);
			end;
		end;
	elseif ( entity:IsNPC() ) then
		local name = entity:GetNetworkedString("ks_Name");
		local title = entity:GetNetworkedString("ks_Title");
		
		-- Check if a statement is true.
		if (name != "" and title != "") then
			info.y = kuroScript.frame:DrawInfo(name, info.x, info.y, Color(255, 255, 100, 255), info.alpha);
			info.y = kuroScript.frame:DrawInfo(title, info.x, info.y, Color(255, 255, 255, 255), info.alpha);
		end;
	end;
end;

-- Called when a Derma skin should be forced.
function kuroScript.game:ForceDermaSkin()
	return "steam_flat";
end;

-- Called when a text entry has gotten focus.
function kuroScript.game:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel;
end;

-- Called when a text entry has lost focus.
function kuroScript.game:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil;
end;

-- Called when screen space effects should be rendered.
function kuroScript.game:RenderScreenspaceEffects()
	if ( !kuroScript.frame:IsScreenFadedBlack() ) then
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if (self.flashEffect) then
			local timeLeft = math.Clamp( self.flashEffect[1] - curTime, 0, self.flashEffect[2] );
			local incrementer = 1 / self.flashEffect[2];
			
			-- Check if a statement is true.
			if (timeLeft > 0) then
				local modify = {};
				
				-- Set some information.
				modify["$pp_colour_brightness"] = 0;
				modify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer);
				modify["$pp_colour_colour"] = 1 - (incrementer * timeLeft);
				modify["$pp_colour_addr"] = incrementer * timeLeft;
				modify["$pp_colour_addg"] = 0;
				modify["$pp_colour_addb"] = 0;
				modify["$pp_colour_mulr"] = 1;
				modify["$pp_colour_mulg"] = 0;
				modify["$pp_colour_mulb"] = 0;
				
				-- Draw the modified color.
				DrawColorModify(modify);
				DrawMotionBlur(1 - (incrementer * timeLeft), 1, 0);
			end;
		end;
		
		-- Check if a statement is true.
		if (self.tearGassed) then
			local timeLeft = self.tearGassed - curTime;
			
			-- Check if a statement is true.
			if (timeLeft > 0) then
				if (timeLeft >= 15) then
					DrawMotionBlur(0.1 + ( 0.9 / (20 - timeLeft) ), 1, 0);
				else
					DrawMotionBlur(0.1, 1, 0);
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if ( self:PlayerIsCombine(g_LocalPlayer) ) then
			render.UpdateScreenEffectTexture();
			
			-- Set some information.
			self.combineOverlay:SetMaterialFloat("$refractamount", 0.3);
			self.combineOverlay:SetMaterialFloat("$envmaptint", 0);
			self.combineOverlay:SetMaterialFloat("$envmap", 0);
			self.combineOverlay:SetMaterialFloat("$alpha", 0.8);
			self.combineOverlay:SetMaterialInt("$ignorez", 1);
			
			-- Set some information.
			render.SetMaterial(self.combineOverlay);
			render.DrawScreenQuad();
		end;
	end;
end;

-- Called when the cinematic intro info is needed.
function kuroScript.game:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self.author..".",
		title = kuroScript.config.Get("intro_text_big"):Get(),
		text = kuroScript.config.Get("intro_text_small"):Get()
	};
end;

-- Called when a player's scoreboard class is needed.
function kuroScript.game:GetPlayerScoreboardClass(player)
	local class = player:GetSharedVar("ks_CustomClass");
	
	-- Check if a statement is true.
	if (class != "") then return class; end;
end;

-- Called when the local player's character screen class is needed.
function kuroScript.game:GetPlayerCharacterScreenClass(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass;
	end;
end;

-- Called when the local player attempts to see the player info.
function kuroScript.game:PlayerCanSeePlayerInfo(alignment)
	local hideDisplay = (KS_CONVAR_HIDEDISPLAY:GetInt() == 1);
	
	-- Check if a statement is true.
	if (hideDisplay) then
		if ( !input.IsKeyDown(KEY_X) or self:IsTextEntryBeingUsed() ) then
			return false;
		end;
	end;
end;

-- Called when the local player attempts to see the top bars.
function kuroScript.game:PlayerCanSeeTopBars()
	local hideDisplay = (KS_CONVAR_HIDEDISPLAY:GetInt() == 1);
	
	-- Check if a statement is true.
	if (hideDisplay) then
		if ( !input.IsKeyDown(KEY_X) or self:IsTextEntryBeingUsed() ) then
			return false;
		end;
	end;
end;

-- Called when the local player attempts to see the top text.
function kuroScript.game:PlayerCanSeeTopText()
	local hideDisplay = (KS_CONVAR_HIDEDISPLAY:GetInt() == 1);
	
	-- Check if a statement is true.
	if (hideDisplay) then
		if ( !input.IsKeyDown(KEY_X) or self:IsTextEntryBeingUsed() ) then
			return false;
		end;
	end;
end;

-- Called when the local player attempts to zoom.
function kuroScript.game:PlayerCanZoom()
	if ( !self:PlayerIsCombine(g_LocalPlayer) ) then
		return false;
	end;
end;

-- Called when the scoreboard's class players should be sorted.
function kuroScript.game:ScoreboardSortClassPlayers(class, a, b)
	if ( kuroScript.game:IsCombineClass(class) ) then
		local lengthA = string.len( a:Name() );
		local lengthB = string.len( b:Name() );
		local rankA = kuroScript.game:GetPlayerCombineRank(a);
		local rankB = kuroScript.game:GetPlayerCombineRank(b);
		
		-- Check if a statement is true.
		if (lengthA != lengthB) then
			return lengthA > lengthB;
		else
			return rankA > rankB;
		end;
	end;
end;

-- Called when the score board should be drawn.
function kuroScript.game:HUDDrawScoreBoard()
	if ( self:PlayerIsCombine(g_LocalPlayer) ) then
		if (self.combineDisplayLines) then
			local height = draw.GetFontHeight("BudgetLabel");
			local curTime = CurTime();
			local x = kuroScript.frame.TopBars.x;
			local y = kuroScript.frame.TopBars.y;
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs(self.combineDisplayLines) do
				if ( curTime >= v[2] ) then
					table.remove(self.combineDisplayLines, k);
				else
					draw.SimpleText( string.sub( v[1], 1, v[3] ), "BudgetLabel", x, y, v[4] or Color(255, 255, 255, 255) );
					
					-- Check if a statement is true.
					if ( v[3] < string.len( v[1] ) ) then
						v[3] = v[3] + 1;
					end;
					
					-- Set some information.
					y = y + height;
				end;
			end;
			
			-- Check if a statement is true.
			if (y > kuroScript.frame.TopBars.y) then
				kuroScript.frame.TopBars.y = y;
			end;
		end;
	end;
end;

-- Called when a player's scoreboard options are needed.
function kuroScript.game:GetPlayerScoreboardOptions(player, options, menu)
	if ( kuroScript.command.Get("seticon") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("seticon").access) ) then
			options["Icon"] = {};
			
			-- Set some information.
			options["Icon"]["Set"] = function()
				Derma_StringRequest(player:Name(), "What would you like to set their icon to?", player:GetSharedVar("ks_Icon"), function(text)
					RunConsoleCommand("ks", "seticon", player:Name(), text);
				end);
			end;
			
			-- Check if a statement is true.
			if (player:GetSharedVar("ks_Icon") != "") then
				options["Icon"]["Remove"] = function()
					RunConsoleCommand("ks", "seticon", player:Name(), "none");
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("serverwhitelist") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("serverwhitelist").access) ) then
			options["Server Whitelist"] = {};
			
			-- Set some information.
			options["Server Whitelist"]["Add"] = function()
				Derma_StringRequest(player:Name(), "What server whitelist would you like to add them to?", "", function(text)
					RunConsoleCommand("ks", "serverwhitelist", player:Name(), text);
				end);
			end;
			
			-- Set some information.
			options["Server Whitelist"]["Remove"] = function()
				Derma_StringRequest(player:Name(), "What server whitelist would you like to remove them from?", "", function(text)
					RunConsoleCommand("ks", "unserverwhitelist", player:Name(), text);
				end);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("setcustomclass") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("setcustomclass").access) ) then
			options["Custom Class"] = {};
			
			-- Set some information.
			options["Custom Class"]["Set"] = function()
				Derma_StringRequest(player:Name(), "What would you like to set their custom class to?", player:GetSharedVar("ks_CustomClass"), function(text)
					RunConsoleCommand("ks", "setcustomclass", player:Name(), text);
				end);
			end;
			
			-- Check if a statement is true.
			if (player:GetSharedVar("ks_CustomClass") != "") then
				options["Custom Class"]["Remove"] = function()
					RunConsoleCommand("ks", "setcustomclass", player:Name(), "none");
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( kuroScript.command.Get("permakill") ) then
		if ( kuroScript.player.HasAccess(g_LocalPlayer, kuroScript.command.Get("permakill").access) ) then
			options["Perma-Kill"] = function()
				RunConsoleCommand( "ks", "permakill", player:Name() );
			end;
		end;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function kuroScript.game:ScoreboardAdjustPlayerInfo(info)
	if ( kuroScript.config.Get("hide_different_clothes"):Get() ) then
		info.model = kuroScript.player.GetDefaultModel(info.player);
		info.skin = kuroScript.player.GetDefaultSkin(info.player);
	end;
	
	-- Check if a statement is true.
	if ( self:IsPlayerCombineRank(info.player, "SCANNER") ) then
		if ( self:IsPlayerCombineRank(info.player, "SYNTH") ) then
			info.model = "models/shield_scanner.mdl";
		else
			info.model = "models/combine_scanner.mdl";
		end;
	end;
end;

-- Called when the local player's vocation model info should be adjusted.
function kuroScript.game:PlayerAdjustVocationModelInfo(vocation, info)
	if (vocation == VOC_CPA_SCN) then
		if ( self:IsPlayerCombineRank(g_LocalPlayer, "SCANNER")
		and self:IsPlayerCombineRank(g_LocalPlayer, "SYNTH") ) then
			info.model = "models/shield_scanner.mdl";
		else
			info.model = "models/combine_scanner.mdl";
		end;
	end;
end;

-- Called when the menu's property sheet tabs should be adjusted.
function kuroScript.game:MenuPropertySheetTabsAdd(propertySheetTabs)
	propertySheetTabs:Add("Donate", "ks_Donate", "gui/silkicons/heart", "Get information on how to donate.");
end;

-- Called when the local player's color modify should be adjusted.
function kuroScript.game:PlayerAdjustColorModify(colorModify)
	local depressionMethod = kuroScript.config.Get("depression_method"):Get(1);
	local antidepressants = g_LocalPlayer:GetSharedVar("ks_Antidepressants");
	local brightness = 0;
	local contrast = 1;
	local color = 1;
	
	-- Check if a statement is true.
	if (depressionMethod == 1) then
		brightness = -0.03;
		contrast = 1.6;
		color = 0.3;
	elseif (depressionMethod == 2) then
		brightness = -0.02;
		contrast = 1.3;
		color = 0.4;
	elseif (depressionMethod == 3) then
		brightness = -0.01;
		contrast = 1.1;
		color = 0.5;
	elseif (depressionMethod == 4) then
		color = 0.7;
	end;
	
	-- Set some information.
	self.currentBrightness = self.currentBrightness or brightness;
	self.currentContrast = self.currentContrast or contrast;
	self.currentColor = self.currentColor or color;
	
	-- Set some information.
	local frameTime = FrameTime() / 10;
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (antidepressants > curTime) then
		self.currentBrightness = math.Approach(self.currentBrightness, 0, frameTime);
		self.currentContrast = math.Approach(self.currentContrast, 1, frameTime);
		self.currentColor = math.Approach(self.currentColor, 1, frameTime);
	else
		self.currentBrightness = math.Approach(self.currentBrightness, brightness, frameTime);
		self.currentContrast = math.Approach(self.currentContrast, contrast, frameTime);
		self.currentColor = math.Approach(self.currentColor, color, frameTime);
	end;
	
	-- Check if a statement is true.
	if (self.currentBrightness != 0) then
		colorModify["$pp_colour_brightness"] = self.currentBrightness;
	end;
	
	-- Check if a statement is true.
	if (self.currentContrast != 1) then
		colorModify["$pp_colour_contrast"] = self.currentContrast;
	end;
	
	-- Check if a statement is true.
	if (self.currentColor != 1) then
		colorModify["$pp_colour_colour"] = self.currentColor;
	end;
end;

-- Called when the local player attempts to see a vocation.
function kuroScript.game:PlayerCanSeeVocation(vocation)
	if ( vocation.index == VOC_CPA_SCN and !self:IsPlayerCombineRank(g_LocalPlayer, "SCANNER") ) then
		return false;
	elseif ( vocation.index == VOC_CPA_RCT and !self:IsPlayerCombineRank(g_LocalPlayer, "RCT") ) then
		return false;
	elseif ( vocation.index == VOC_CPA_EPU and !self:IsPlayerCombineRank(g_LocalPlayer, "EpU") ) then
		return false;
	elseif ( vocation.index == VOC_OTA_OWS and !self:IsPlayerCombineRank(g_LocalPlayer, "OWS") ) then
		return false;
	elseif ( vocation.index == VOC_OTA_EOW and !self:IsPlayerCombineRank(g_LocalPlayer, "EOW") ) then
		return false;
	elseif ( vocation.index == VOC_OTA_OWC and !self:IsPlayerCombineRank(g_LocalPlayer, "COMM") ) then
		return false;
	elseif (vocation.index == VOC_CPA_PRO) then
		if ( self:IsPlayerCombineRank(g_LocalPlayer, "SCANNER") or self:IsPlayerCombineRank(g_LocalPlayer, "EpU")
		or self:IsPlayerCombineRank(g_LocalPlayer, "RCT") ) then
			return false;
		end;
	end;
end;

-- Called when a player's footstep sound should be played.
function kuroScript.game:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when the target's status should be drawn.
function kuroScript.game:DrawTargetPlayerStatus(target, alpha, x, y)
	local action = kuroScript.player.GetAction(g_LocalPlayer);
	
	-- Check if a statement is true.
	if ( target:Alive() ) then
		if (target:GetSharedVar("ks_Tied") != 0) then
			if (action == "untie") then
				return kuroScript.frame:DrawInfo("Being Untied", x, y, COLOR_INFORMATION, alpha);
			elseif (g_LocalPlayer:GetSharedVar("ks_Tied") != 0) then
				return kuroScript.frame:DrawInfo("Tied", x, y, COLOR_INFORMATION, alpha);
			elseif (target:GetShootPos():Distance( g_LocalPlayer:GetShootPos() ) <= 192) then
				return kuroScript.frame:DrawInfo("Untie: Sprint + Use", x, y, COLOR_INFORMATION, alpha);
			else
				return kuroScript.frame:DrawInfo("Tied", x, y, COLOR_INFORMATION, alpha);
			end;
		elseif (action == "tie") then
			return kuroScript.frame:DrawInfo("Being Tied", x, y, COLOR_INFORMATION, alpha);
		elseif (target:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
			return kuroScript.frame:DrawInfo("Unconscious", x, y, COLOR_INFORMATION, alpha);
		end;
	elseif ( target:GetSharedVar("ks_PermaKilled") ) then
		return kuroScript.frame:DrawInfo("Permanently Killed", x, y, COLOR_INFORMATION, alpha);
	elseif ( self:PlayerIsCombine(target, false) ) then
		return kuroScript.frame:DrawInfo("Offline", x, y, COLOR_INFORMATION, alpha);
	else
		return kuroScript.frame:DrawInfo("Dead", x, y, COLOR_INFORMATION, alpha);
	end;
end;

-- Called when the player info text is needed.
function kuroScript.game:GetPlayerInfoText(playerInfoText)
	local citizenID = g_LocalPlayer:GetSharedVar("ks_CitizenID");
	local scannerIsValid = ValidEntity( self:GetScannerEntity(g_LocalPlayer) );
	
	-- Check if a statement is true.
	if (citizenID) then
		if (kuroScript.player.GetClass(g_LocalPlayer) == CLASS_CIT) then
			playerInfoText:Add("CITIZEN_ID", "Citizen ID: #"..citizenID, "gui/silkicons/check_on");
		end;
	end;
	
	-- Check if a statement is true.
	if ( g_LocalPlayer:Alive() ) then
		local maxHealth = g_LocalPlayer:GetMaxHealth();
		local maxArmor = g_LocalPlayer:GetMaxArmor();
		
		-- Check if a statement is true.
		if (g_LocalPlayer:Health() >= maxHealth) then
			if (scannerIsValid) then
				playerInfoText:Add("VITAL_SIGNS", "Armor Condition: Excellent", "gui/silkicons/shield");
			else
				playerInfoText:Add("VITAL_SIGNS", "Vital Signs: Healthy", "gui/silkicons/add");
			end;
		elseif (g_LocalPlayer:Health() >= maxHealth / 2) then
			if (scannerIsValid) then
				playerInfoText:Add("VITAL_SIGNS", "Armor Condition: Mediocre", "gui/silkicons/shield");
			else
				playerInfoText:Add("VITAL_SIGNS", "Vital Signs: Injured", "gui/silkicons/add");
			end;
		elseif (g_LocalPlayer:Health() > 0) then
			if (scannerIsValid) then
				playerInfoText:Add("VITAL_SIGNS", "Armor Condition: Poor", "gui/silkicons/add");
			else
				playerInfoText:Add("VITAL_SIGNS", "Vital Signs: Critical", "gui/silkicons/exclamation");
			end;
		end;
		
		-- Check if a statement is true.
		if (!scannerIsValid) then
			if (g_LocalPlayer:Armor() >= maxArmor) then
				playerInfoText:Add("ARMOR_CONDITION", "Armor Condition: Excellent", "gui/silkicons/shield");
			elseif (g_LocalPlayer:Armor() >= maxArmor / 2) then
				playerInfoText:Add("ARMOR_CONDITION", "Armor Condition: Mediocre", "gui/silkicons/shield");
			elseif (g_LocalPlayer:Armor() > 0) then
				playerInfoText:Add("ARMOR_CONDITION", "Armor Condition: Poor", "gui/silkicons/exclamation");
			end;
		end;
	elseif (scannerIsValid) then
		playerInfoText:Add("VITAL_SIGNS", "Armor Condition: Defunct", "gui/silkicons/exclamation");
	else
		playerInfoText:Add("VITAL_SIGNS", "Vital Signs: Dead", "gui/silkicons/exclamation");
	end;
	
	-- Set some information.
	local weapon = g_LocalPlayer:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local secondaryAmmo = g_LocalPlayer:GetAmmoCount( weapon:GetSecondaryAmmoType() );
		local primaryAmmo = g_LocalPlayer:GetAmmoCount( weapon:GetPrimaryAmmoType() );
		
		-- Check if a statement is true.
		if (secondaryAmmo > 0) then
			playerInfoText:Add("SECONDARY_AMMO", "Secondary Ammo: "..secondaryAmmo, "gui/silkicons/picture_edit", ALIGN_RIGHT);
		end;
		
		-- Check if a statement is true.
		if (primaryAmmo > 0) then
			playerInfoText:Add("PRIMARY_AMMO", "Primary Ammo: "..primaryAmmo, "gui/silkicons/bomb", ALIGN_RIGHT);
		end;
	end;
end;

-- Called when the target player's text should be destroyed.
function kuroScript.game:DestroyTargetPlayerText(entity, targetPlayerText)
	if ( targetPlayerText:Get("CLASS") and targetPlayerText:Get("STATUS") ) then
		targetPlayerText:Destroy("CLASS");
	end;
end;

-- Called when the target player's text is needed.
function kuroScript.game:GetTargetPlayerText(player, targetPlayerText)
	local scannerIsValid = ValidEntity( self:GetScannerEntity(player) );
	
	-- Check if a statement is true.
	if (player:Alive() and !scannerIsValid) then
		local maxHealth = player:GetMaxHealth();
		local weapons = {};
		local weapon = player:GetActiveWeapon();
		local text = {};
		
		-- Loop through each value in a table.
		for k, v in pairs( player:GetWeapons() ) do
			if (weapon != v) then
				local itemTable = kuroScript.item.GetWeapon(v);
				
				-- Check if a statement is true.
				if (itemTable) then
					if (itemTable.weight > 2) then
						weapons[#weapons + 1] = {
							itemTable.name,
							itemTable.weight
						};
					end;
				end;
			end;
		end;
		
		-- Sort the weapons.
		table.sort(weapons, function(a, b) return a[2] > b[2]; end);
		
		-- Check if a statement is true.
		if (player:Health() < maxHealth) then
			if (player:Health() >= maxHealth / 2) then
				text[#text + 1] = "Injured";
			elseif (player:Health() > 0) then
				text[#text + 1] = "Critical";
			end;
		end;
		
		-- Check if a statement is true.
		if ( !g_LocalPlayer:IsRagdolled() and ValidEntity(weapon) ) then
			if ( weapons[1] ) then text[#text + 1] = weapons[1][1]; end;
			if ( weapons[2] ) then text[#text + 1] = weapons[2][1]; end;
		end;
		
		-- Check if a statement is true.
		if (#text > 0) then
			targetPlayerText:Add( "STATUS", table.concat(text, " | ") );
		end;
	end;
end;

-- Called when a player's name should be shown as anonymous.
function kuroScript.game:PlayerCanShowAnonymous(player, x, y, name, vocationColor, alpha)
	if ( self:PlayerIsCombine(g_LocalPlayer) ) then
		if ( !kuroScript.player.KnowsPlayer(player, KNOWN_PARTIAL) ) then
			if (g_LocalPlayer:GetSharedVar("ks_Tied") == 0) then
				if (player:GetSharedVar("ks_Tied") != 0) then
					if ( g_LocalPlayer:GetSharedVar("ks_NameScan") ) then
						return kuroScript.frame:DrawInfo(name.." | Scanning", x, y, vocationColor, alpha);
					else
						return kuroScript.frame:DrawInfo(name.." | Press Use", x, y, vocationColor, alpha);
					end;
				end;
			end;
		end;
	end;
end;

-- Called to check if a player does have an access flag.
function kuroScript.game:PlayerDoesHaveAccessFlag(player, flag)
	local k, v;
	
	-- Check if a statement is true.
	if ( !kuroScript.config.Get("permits"):Get() ) then
		if (flag == "x" or flag == "i") then
			return false;
		else
			for k, v in pairs(self.customPermits) do
				if (v.flag == flag) then
					return false;
				end;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if (flag != "x") then
		for k, v in pairs(self.customPermits) do
			if ( v.flag == flag and !kuroScript.player.HasAccess(player, "x") ) then
				return false;
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( string.find("petw", flag) ) then
		if ( player:GetSharedVar("ks_Donator") ) then
			return true;
		end;
	end;
end;

-- Called to check if a player does know another player.
function kuroScript.game:PlayerDoesKnowPlayer(player, status, simple, default)
	if (self:PlayerIsCombine(player) or kuroScript.player.GetClass(player) == CLASS_CAD) then
		return true;
	end;
end;

-- Called when the top bars should be destroyed.
function kuroScript.game:DestroyTopBars(topBars)
	topBars:Destroy("SECONDARY_AMMO");
	topBars:Destroy("PRIMARY_AMMO");
	topBars:Destroy("HEALTH");
	topBars:Destroy("ARMOR");
end;

-- Called when the top text is needed.
function kuroScript.game:GetTopText(topText)
	local beingSearched = g_LocalPlayer:GetSharedVar("ks_BeingSearched");
	local beingUntied = g_LocalPlayer:GetSharedVar("ks_BeingUntied");
	local hiddenItem = g_LocalPlayer:GetSharedVar("ks_HiddenItem");
	local beingTied = g_LocalPlayer:GetSharedVar("ks_BeingTied");
	local clothes = g_LocalPlayer:GetSharedVar("ks_Clothes");
	
	-- Check if a statement is true.
	if (hiddenItem != "") then
		local itemTable = kuroScript.item.Get(hiddenItem);
		
		-- Check if a statement is true.
		if (itemTable) then
			local name = itemTable.name;
			
			-- Check if a statement is true.
			if (string.sub(name, -1) == "s") then
				topText:Add("HIDDEN_ITEM", "+", "You are hiding some "..name);
			else
				topText:Add("HIDDEN_ITEM", "+", "You are hiding a "..name);
			end;
		end;
	end;
	
	-- Check if a statement is true.
	if ( clothes and kuroScript.item.stored[clothes] ) then
		topText:Add("WEARING_CLOTHES", "+", "You are wearing a "..kuroScript.item.stored[clothes].name);
	end;
	
	-- Check if a statement is true.
	if (beingSearched) then
		topText:Add("BEING_SEARCHED", "-", "You are being searched");
	end;
	
	-- Check if a statement is true.
	if (g_LocalPlayer:GetSharedVar("ks_Tied") != 0) then
		if (beingUntied) then
			topText:Add("BEING_UNTIED", "+", "You are being untied");
		else
			topText:Add("TIED", "-", "You have been tied");
		end;
	elseif (beingTied) then
		topText:Add("BEING_TIED", "-", "You are being tied");
	end;
end;

-- Called each tick.
function kuroScript.game:Tick()
	if ( self:PlayerIsCombine(g_LocalPlayer) ) then
		local curTime = CurTime();
		local health = g_LocalPlayer:Health();
		local armor = g_LocalPlayer:Armor();

		-- Check if a statement is true.
		if (!self.nextHealthWarning or curTime >= self.nextHealthWarning) then
			if (self.lastHealth) then
				if (health < self.lastHealth) then
					if (health == 0) then
						self:AddCombineDisplayLine( "ERROR! Shutting down...", Color(255, 0, 0, 255) );
					else
						self:AddCombineDisplayLine( "WARNING! Physical bodily trauma detected...", Color(255, 0, 0, 255) );
					end;
					
					-- Set some information.
					self.nextHealthWarning = curTime + 2;
				elseif (health > self.lastHealth) then
					if (health == 100) then
						self:AddCombineDisplayLine( "Physical body systems restored...", Color(0, 255, 0, 255) );
					else
						self:AddCombineDisplayLine( "Physical body systems regenerating...", Color(0, 0, 255, 255) );
					end;
					
					-- Set some information.
					self.nextHealthWarning = curTime + 2;
				end;
			end;
			
			-- Check if a statement is true.
			if (self.lastArmor) then
				if (armor < self.lastArmor) then
					if (armor == 0) then
						self:AddCombineDisplayLine( "WARNING! External protection exhausted...", Color(255, 0, 0, 255) );
					else
						self:AddCombineDisplayLine( "WARNING! External protection damaged...", Color(255, 0, 0, 255) );
					end;
					
					-- Set some information.
					self.nextHealthWarning = curTime + 2;
				elseif (armor > self.lastArmor) then
					if (armor == 100) then
						self:AddCombineDisplayLine( "External protection systems restored...", Color(0, 255, 0, 255) );
					else
						self:AddCombineDisplayLine( "External protection systems regenerating...", Color(0, 0, 255, 255) );
					end;
					
					-- Set some information.
					self.nextHealthWarning = curTime + 2;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (!self.nextRandomLine or curTime >= self.nextRandomLine) then
			local text = self.randomDisplayLines[ math.random(1, #self.randomDisplayLines) ];
			
			-- Check if a statement is true.
			if (text and self.lastRandomDisplayLine != text) then
				self:AddCombineDisplayLine(text);
				
				-- Set some information.
				self.lastRandomDisplayLine = text;
			end;
			
			-- Set some information.
			self.nextRandomLine = curTime + 3;
		end;
		
		-- Set some information.
		self.lastHealth = health;
		self.lastArmor = armor;
	end;
end;

-- Called when the foreground HUD should be painted.
function kuroScript.game:HUDPaintForeground()
	local alpha = 255;
	local k, v;
	local y = 8;
	
	-- Check if a statement is true.
	if (kuroScript.frame.BlackFadeIn) then
		alpha = alpha - kuroScript.frame.BlackFadeIn;
	elseif (kuroScript.frame.BlackFadeOut) then
		alpha = alpha - kuroScript.frame.BlackFadeOut;
	end;
	
	-- Check if a statement is true.
	if ( !g_LocalPlayer:Alive() ) then
		if ( g_LocalPlayer:GetSharedVar("ks_PermaKilled") ) then
			y = kuroScript.frame:DrawSimpleText("You have been permanently killed and will automatically reconnect shortly.", ScrW() / 2, y, Color(255, 255, 255, 255 - alpha), 1, 1);
		end;
	else
		local hideDisplay = (KS_CONVAR_HIDEDISPLAY:GetInt() == 1);
		
		-- Check if a statement is true.
		if (hideDisplay) then
			if ( !input.IsKeyDown(KEY_X) or self:IsTextEntryBeingUsed() ) then
				y = kuroScript.frame:DrawSimpleText("Hold down 'x' to see your head-up display.", ScrW() / 2, y, Color(255, 255, 255, alpha), 1);
			end;
		end;
		
		-- Check if a statement is true.
		if (kuroScript.frame:GetSharedVar("ks_PKMode") == 1) then
			y = kuroScript.frame:DrawSimpleText("Perma-kill mode is active, try not to be killed.", ScrW() / 2, y, Color(255, 255, 255, alpha), 1);
		end;
	end;
	
	-- Check if a statement is true.
	if ( g_LocalPlayer:Alive() ) then
		if (self.stunEffects) then
			local curTime = CurTime();
			
			-- Loop through each value in a table.
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp( ( 255 / v[2] ) * (v[1] - curTime), 0, 255 );
				
				-- Check if a statement is true.
				if (alpha != 0) then
					draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha) );
				else
					table.remove(self.stunEffects, k);
				end;
			end;
			
			-- Check if a statement is true.
			if (#self.stunEffects == 0) then
				self.stunEffects = nil;
			end;
		end;
	end;
end;

-- Called when the chat box info should be adjusted.
function kuroScript.game:ChatBoxAdjustInfo(info)
	if ( ValidEntity(info.speaker) ) then
		local speakerIcon = info.speaker:GetSharedVar("ks_Icon");
		
		-- Check if a statement is true.
		if (info.data.anon) then
			info.name = "Distorted";
		end;
		
		-- Check if a statement is true.
		if (speakerIcon != "") then
			info.icon = {speakerIcon, "#"};
		elseif ( info.speaker:GetSharedVar("ks_Donator") ) then
			if (info.icon[1] == "gui/silkicons/user") then
				local icon = info.speaker:GetSharedVar("ks_DonatorIcon");
				
				-- Check if a statement is true.
				if (icon == "Exclamation") then
					info.icon = {"gui/silkicons/exclamation", "<3"};
				elseif (icon == "Speaker") then
					info.icon = {"gui/silkicons/sound", "<3"};
				elseif (icon == "Recycle") then
					info.icon = {"gui/silkicons/arrow_refresh", "<3"};
				elseif (icon == "Anchor") then
					info.icon = {"gui/silkicons/anchor", "<3"};
				elseif (icon == "Wrench") then
					info.icon = {"gui/silkicons/wrench", "<3"};
				elseif (icon == "Group") then
					info.icon = {"gui/silkicons/group", "<3"};
				elseif (icon == "Bomb") then
					info.icon = {"gui/silkicons/bomb", "<3"};
				elseif (icon == "Car") then
					info.icon = {"gui/silkicons/car", "<3"};
				else
					info.icon = {"gui/silkicons/heart", "<3"};
				end;
			end;
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function kuroScript.game:GetPostProgressBarInfo()
	if ( g_LocalPlayer:Alive() and !g_LocalPlayer:IsRagdolled() ) then
		local action, percentage = kuroScript.player.GetAction(g_LocalPlayer, true);
		
		-- Check if a statement is true.
		if ( !g_LocalPlayer:IsRagdolled() and action == "clothes") then
			return {text = "Changing Clothes", percentage = percentage, flash = percentage < 25};
		end;
	end;
end;