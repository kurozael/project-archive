--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local OUTLINE_MATERIAL = Material("white_outline");

-- Called when the bars are needed.
function openAura.schema:GetBars(bars)
	local honor = openAura.Client:GetSharedVar("honor");
	local fuel = openAura.Client:GetSharedVar("fuel");
	
	if (!self.honor) then
		self.honor = honor;
	else
		self.honor = math.Approach(self.honor, honor, 1);
	end;
	
	if (!self.fuel) then
		self.fuel = fuel;
	else
		self.fuel = math.Approach(self.fuel, fuel, 1);
	end;
	
	if (honor >= 50) then
		bars:Add("HONOR", Color(175, 255, 75, 255), "Honor", self.honor, 100, self.honor < 55);
	else
		bars:Add("HONOR", Color(255, 75, 175, 255), "Honor", self.honor, 100, self.honor > 45);
	end;
	
	if ( self.fuel < 90 and openAura.Client:GetSharedVar("jetpack") ) then
		bars:Add("FUEL", Color(255, 255, 75, 255), "Fuel", self.fuel, 100, self.fuel < 10);
	end;
end;

-- Called when the a custom business info label is needed.
function openAura.schema:GetCustomBusinessInfoLabel(panel, itemTable)
	if ( itemTable.requiresExplosives and !openAura.augments:Has(AUG_EXPLOSIVES) ) then
		return "Requires the Explosives augment.";
	elseif ( itemTable.requiresArmadillo and !openAura.augments:Has(AUG_ARMADILLO) ) then
		return "Requires the Armadillo augment.";
	elseif ( itemTable.requiresGunsmith and !openAura.augments:Has(AUG_GUNSMITH) ) then
		return "Requires the Gunsmith augment.";
	elseif (itemTable.cost > 120 and itemTable.batch > 1) then
		local engRequired = math.floor( math.Clamp(itemTable.cost / 150, 0, 50) );
		local engineering = openAura.attributes:Fraction(ATB_ENGINEERING, 50, 50);
		
		if (engineering < engRequired) then
			return "Requires an engineering level of "..( (100 / 50) * engRequired ).."%.";
		end;
	end;
end;

-- Called when the local player's item menu should be adjusted.
function openAura.schema:PlayerAdjustItemMenu(itemTable, menuPanel, itemFunctions)
	if (itemTable.OnUse) then
		local subMenu = menuPanel:AddSubMenu("Hotkey");
		
		subMenu:AddOption("Slot #1", function()
			self.hotkeyItems[1] = itemTable.uniqueID;
			openAura:SaveSchemaData("hotkeys", self.hotkeyItems);
		end);
		
		subMenu:AddOption("Slot #2", function()
			self.hotkeyItems[2] = itemTable.uniqueID;
			openAura:SaveSchemaData("hotkeys", self.hotkeyItems);
		end);
		
		subMenu:AddOption("Slot #3", function()
			self.hotkeyItems[3] = itemTable.uniqueID;
			openAura:SaveSchemaData("hotkeys", self.hotkeyItems);
		end);
	
		if (itemTable.weaponLevel and itemTable.nextWeaponID) then
			if (itemTable.weaponLevel != 10) then
				menuPanel:AddOption("Upgrade", function()
					openAura:StartDataStream("UpgradeWeapon", itemTable.uniqueID);
				end);
				
				local panel = menuPanel.Panels[#menuPanel.Panels];
				
				if ( IsValid(panel) ) then
					local engRequired = math.floor( math.Clamp(itemTable.weaponLevel * 5, 0, 50) );
					local engineering = openAura.attributes:Fraction(ATB_ENGINEERING, 50, 50);
					
					if (engineering < engRequired) then
						panel:SetToolTip("Requires an engineering level of "..( (100 / 50) * engRequired ).."%.");
					else
						panel:SetToolTip("This upgrade will cost you "..FORMAT_CASH(itemTable.weaponLevel * 500, true)..".");
					end;
				end;
			end;
		end;
		
		if (itemTable.armorLevel and itemTable.nextArmorID) then
			if (itemTable.armorLevel != 10) then
				menuPanel:AddOption("Upgrade", function()
					openAura:StartDataStream("UpgradeArmor", itemTable.uniqueID);
				end);
				
				local panel = menuPanel.Panels[#menuPanel.Panels];
				
				if ( IsValid(panel) ) then
					local engRequired = math.floor( math.Clamp(itemTable.armorLevel * 5, 0, 50) );
					local engineering = openAura.attributes:Fraction(ATB_ENGINEERING, 50, 50);
					
					if (engineering < engRequired) then
						panel:SetToolTip("Requires an engineering level of "..( (100 / 50) * engRequired ).."%.");
					else
						panel:SetToolTip("This upgrade will cost you "..FORMAT_CASH(itemTable.armorLevel * 500, true)..".");
					end;
				end;
			end;
		end;
	end;
end;

-- Called when the local player's item functions should be adjusted.
function openAura.schema:PlayerAdjustItemFunctions(itemTable, itemFunctions)
	if ( openAura.augments:Has(AUG_CASHBACK) or openAura.augments:Has(AUG_BLACKMARKET) ) then
		if (itemTable.cost) then
			itemFunctions[#itemFunctions + 1] = "Cash";
		end;
	end;
end;

-- Called when the local player's business item should be adjusted.
function openAura.schema:PlayerAdjustBusinessItemTable(itemTable)
	if ( openAura.augments:Has(AUG_MERCANTILE) ) then
		itemTable.cost = itemTable.cost * 0.9;
	end;
end;

-- Called when the HUD should be painted.
function openAura.schema:HUDPaint()
	local colorWhite = openAura.option:GetColor("white");
	local curTime = CurTime();
	local info = {
		alpha = 255 - openAura:GetBlackFadeAlpha(),
		x = ScrW() - 208,
		y = 8
	};
	
	if (openAura.inventory:HasItem("heartbeat_implant") and info.alpha > 0) then
		if ( openAura.Client:GetSharedVar("implant") ) then
			local aimVector = openAura.Client:GetAimVector();
			local position = openAura.Client:GetPos();
			local curTime = UnPredictedCurTime();

			self.heartbeatOverlay:SetMaterialFloat( "$alpha", math.min(0.5, (info.alpha / 255) * 0.5) );
			
			surface.SetDrawColor( 255, 255, 255, math.min(150, info.alpha / 2) );
				surface.SetMaterial(self.heartbeatOverlay);
			surface.DrawTexturedRect(info.x, info.y, 200, 200);
			
			surface.SetDrawColor(0, 200, 0, info.alpha);
				surface.SetMaterial(self.heartbeatPoint);
			surface.DrawTexturedRect(info.x + 84, info.y + 84, 32, 32);
			
			if (self.heartbeatScan) then
				local scanAlpha = math.min( 255 * math.max(self.heartbeatScan.fadeOutTime - curTime, 0), info.alpha );
				local y = self.heartbeatScan.y + ( (184 / 255) * (255 - scanAlpha) );
				
				if (scanAlpha > 0) then
					surface.SetDrawColor(100, 0, 0, scanAlpha * 0.5);
						surface.SetMaterial(self.heartbeatGradient);
					surface.DrawTexturedRect(self.heartbeatScan.x, y, self.heartbeatScan.width, self.heartbeatScan.height);
				else
					self.heartbeatScan = nil;
				end;
			end;
			
			if (curTime >= self.nextHeartbeatCheck) then
				self.nextHeartbeatCheck = curTime + 1;
				self.oldHeartbeatPoints = self.heartbeatPoints;
				self.heartbeatPoints = {};
				self.heartbeatScan = {
					fadeOutTime = curTime + 1,
					height = 16,
					width = 200,
					y = info.y,
					x = info.x
				};
				
				local centerY = info.y + 100;
				local centerX = info.x + 100;
				
				for k, v in ipairs( ents.FindInSphere(position, 768) ) do
					if ( v:IsPlayer() and v:Alive() and v:HasInitialized() ) then
						if ( openAura.Client != v and !openAura.player:IsNoClipping(v) ) then
							if ( v:Health() >= (v:GetMaxHealth() / 3) ) then
								if ( !v:GetSharedVar("ghostheart") ) then
									local playerPosition = v:GetPos();
									local difference = playerPosition - position;
									local pointX = (difference.x / 768);
									local pointY = (difference.y / 768);
									local pointZ = math.sqrt(pointX * pointX + pointY * pointY);
									local color = Color(200, 0, 0, 255);
									local phi = math.Deg2Rad(math.Rad2Deg( math.atan2(pointX, pointY) ) - math.Rad2Deg( math.atan2(aimVector.x, aimVector.y) ) - 90);
									pointX = math.cos(phi) * pointZ;
									pointY = math.sin(phi) * pointZ;
									
									if ( openAura.Client:GetAlliance() == v:GetAlliance() ) then
										color = Color(0, 0, 200, 255);
									end;
									
									self.heartbeatPoints[#self.heartbeatPoints + 1] = {
										fadeInTime = curTime + 1,
										height = 32,
										width = 32,
										color = color,
										x = centerX + (pointX * 100) - 16,
										y = centerY + (pointY * 100) - 16
									};
								end;
							end;
						end;
					end;
				end;
				
				if (self.lastHeartbeatAmount > #self.heartbeatPoints) then
					openAura.Client:EmitSound("items/flashlight1.wav", 25);
				end;
				
				for k, v in ipairs(self.oldHeartbeatPoints) do
					v.fadeOutTime = curTime + 1;
					v.fadeInTime = nil;
				end;
				
				self.lastHeartbeatAmount = #self.heartbeatPoints;
			end;
			
			for k, v in ipairs(self.oldHeartbeatPoints) do
				local pointAlpha = 255 * math.max(v.fadeOutTime - curTime, 0);
				local pointX = math.Clamp(v.x, info.x, (info.x + 200) - 32);
				local pointY = math.Clamp(v.y, info.y, (info.y + 200) - 32);
				
				surface.SetDrawColor( v.color.r, v.color.g, v.color.b, math.min(pointAlpha, info.alpha) );
					surface.SetMaterial(self.heartbeatPoint);
				surface.DrawTexturedRect(pointX, pointY, v.width, v.height);
			end;
			
			for k, v in ipairs(self.heartbeatPoints) do
				local pointAlpha = 255 - ( 255 * math.max(v.fadeInTime - curTime, 0) );
				local pointX = math.Clamp(v.x, info.x, (info.x + 200) - 32);
				local pointY = math.Clamp(v.y, info.y, (info.y + 200) - 32);
				
				surface.SetDrawColor( v.color.r, v.color.g, v.color.b, math.min(pointAlpha, info.alpha) );
					surface.SetMaterial(self.heartbeatPoint);
				surface.DrawTexturedRect(pointX, pointY, v.width, v.height);
			end;
			
			info.y = info.y + 212;
		end;
	end;
	
	if ( openAura.Client:GetSharedVar("tied") ) then
		local scrH = ScrH();
		local scrW = ScrW();
		
		local y = openAura:DrawInfo("YOU DROP EVERYTHING ON YOU IF YOU LEAVE WHILE TIED!", scrW, scrH, colorWhite, 255, true, function(x, y, width, height)
			return x - width - 8, y - (height * 2) - 16;
		end);
		
		openAura:DrawInfo("THIS INCLUDES ANY CLOTHING YOU ARE WEARING!", scrW, y, colorWhite, 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	else
		local nextDC = openAura.Client:GetSharedVar("nextDC");
		local scrH = ScrH();
		local scrW = ScrW();
		
		if (nextDC > curTime) then
			local y = openAura:DrawInfo("YOU DROP EVERYTHING ON YOU IF YOU LEAVE WITHIN "..math.ceil(nextDC - curTime).." SECOND(s)!", scrW, scrH, colorWhite, 255, true, function(x, y, width, height)
				return x - width - 8, y - (height * 2) - 16;
			end);
			
			openAura:DrawInfo("THIS INCLUDES ANY CLOTHING YOU ARE WEARING!", scrW, y, colorWhite, 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		end;
	end;
end;

-- Called when a cash entity is drawn.
function openAura.schema:OpenAuraCashEntityDraw(entity)
	self:OpenAuraGeneratorEntityDraw( entity, Color(0, 255, 255, 255) );
end;

-- Called when a shipment entity is drawn.
function openAura.schema:OpenAuraShipmentEntityDraw(entity)
	self:OpenAuraGeneratorEntityDraw( entity, Color(125, 100, 75, 255) );
end;

-- Called when a generator entity is drawn.
function openAura.schema:OpenAuraGeneratorEntityDraw(entity, forceColor)
	local curTime = CurTime();
	local sineWave = math.max(math.abs(math.sin(curTime) * 32), 16);
	local r, g, b, a = entity:GetColor();
	local outlineColor = forceColor or Color(255, 0, 255, 255);
	
	if (entity:GetClass() == "aura_rationproducer") then
		outlineColor = Color(0, 255, 255, 255);
	end;
	
	render.SuppressEngineLighting(true);
	render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
	
	render.SetAmbientLight(1, 1, 1);
	render.SetBlend(outlineColor.a / 255);
	entity:SetModelScale( Vector() * ( 1.025 + (sineWave / 320) ) );
	
	SetMaterialOverride(OUTLINE_MATERIAL);
		entity:DrawModel();
	SetMaterialOverride(nil);
	entity:SetModelScale( Vector() );
	
	render.SetBlend(1);
	render.SetColorModulation(r / 255, g / 255, b / 255);
	render.SuppressEngineLighting(false);
end;

-- Called when the OpenAura core has loaded.
function openAura.schema:OpenAuraCoreLoaded()
	for k, v in pairs( openAura.item:GetAll() ) do
		if (v.category == "Consumables" or v.category == "Alcohol") then
			v.color = Color(50, 50, 255, 255);
		elseif (v.category == "Ammunition") then
			v.color = Color(255, 50, 100, 255);
		elseif (v.category == "Clothing") then
			v.color = Color(255, 255, 175, 255);
		elseif (v.category == "Implants") then
			v.color = Color(50, 255, 50, 255);
		elseif (v.category == "Stimpacks") then
			v.color = Color(255, 255, 50, 255);
		elseif (v.category == "Reusables") then
			v.color = Color(50, 255, 255, 255);
		elseif (v.category == "Storage") then
			v.color = Color(175, 50, 100, 255);
		elseif (v.category == "Tomes") then
			v.color = Color(125, 175, 25, 255);
		elseif (v.category == "Other") then
			v.color = Color(255, 150, 150, 255);
		else
			v.color = Color(255, 50, 255, 255);
		end;
	end;
end;

-- Called when an item entity is drawn.
function openAura.schema:OpenAuraItemEntityDraw(itemTable, entity)
	local curTime = CurTime();
	local sineWave = math.max(math.abs(math.sin(curTime) * 32), 16);
	local r, g, b, a = entity:GetColor();
	local outlineColor = Color(255, 0, 0, 255);
	
	if (itemTable.category == "Consumables" or itemTable.category == "Alcohol") then
		outlineColor = Color(50, 50, 255, 255);
	elseif (itemTable.category == "Ammunition") then
		outlineColor = Color(255, 50, 100, 255);
	elseif (itemTable.category == "Clothing") then
		outlineColor = Color(255, 255, 175, 255);
	elseif (itemTable.category == "Implants") then
		outlineColor = Color(50, 255, 50, 255);
	elseif (itemTable.category == "Stimpacks") then
		outlineColor = Color(255, 255, 50, 255);
	elseif (itemTable.category == "Reusables") then
		outlineColor = Color(50, 255, 255, 255);
	elseif (itemTable.category == "Storage") then
		outlineColor = Color(175, 50, 100, 255);
	elseif (itemTable.category == "Tomes") then
		outlineColor = Color(125, 175, 25, 255);
	elseif (itemTable.category == "Other") then
		outlineColor = Color(255, 150, 150, 255);
	end;
	
	cam.Start3D( EyePos(), EyeAngles() );
		render.SuppressEngineLighting(true);
			render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
				render.SetAmbientLight(1, 1, 1);
					entity:SetModelScale( Vector() * ( 1.025 + (sineWave / 320) ) );
						SetMaterialOverride(OUTLINE_MATERIAL);
					entity:DrawModel();
					
					entity:SetModelScale( Vector() );
				SetMaterialOverride(nil);
			render.SetColorModulation(r / 255, g / 255, b / 255);
		render.SuppressEngineLighting(false);
	cam.End3D();
end;

-- Called just after a player is drawn.
function openAura.schema:PostPlayerDraw(player)
	if (!DO_NOT_DRAW) then
		DO_NOT_DRAW = true;
		
		local alliance = openAura.Client:GetAlliance();
		local curTime = CurTime();
		
		if (alliance) then
			if (player:GetMaterial() != "sprites/heatwave" and player:GetMoveType() == MOVETYPE_WALK) then
				if (player:GetAlliance() == alliance) then
					if ( openAura.augments:Has(AUG_WALLHACKS)
					and !openAura.player:CanSeePlayer(openAura.Client, player, 0.9, true) ) then
						self:DrawBasicOutline(player, Color(50, 255, 50, 255), true);
					else
						self:DrawBasicOutline( player, Color(50, 255, 50, 255) );
					end;
				elseif ( self.targetOutlines[player] ) then
					local alpha = math.Clamp( (255 / 60) * (self.targetOutlines[player] - curTime), 0, 255 );
					
					if (alpha > 0) then
						if ( openAura.augments:Has(AUG_TRACKING)
						and !openAura.player:CanSeePlayer(openAura.Client, player, 0.9, true) ) then
							self:DrawBasicOutline(player, Color(255, 50, 50, alpha), true);
						else
							self:DrawBasicOutline( player, Color(255, 50, 50, alpha) );
						end;
					end;
				end;
			end;
		end;
		
		DO_NOT_DRAW = false;
	end;
end;

-- Called just after the opaque renderables have been drawn.
function openAura.schema:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (!drawingSkybox) then
		local colorWhite = openAura.option:GetColor("white");
		local colorBlack = Color(0, 0, 0, 255);
		local eyeAngles = EyeAngles();
		local curTime = UnPredictedCurTime();
		local eyePos = EyePos();
		
		if (curTime >= self.nextGetSnipers) then
			self.nextGetSnipers = curTime + 1;
			self.sniperPlayers = {};
			
			for k, v in ipairs( _player.GetAll() ) do
				if ( openAura.player:GetWeaponRaised(v) ) then
					local weapon = v:GetActiveWeapon();
					
					if ( v:HasInitialized() and IsValid(weapon) ) then
						local weaponClass = string.lower( weapon:GetClass() );
						
						if (weaponClass == "rcs_g3sg1" and weapon:GetNetworkedInt("Zoom") != 0) then
							self.sniperPlayers[#self.sniperPlayers + 1] = v;
						end;
					end;
				end;
			end;
			
			if (#self.sniperPlayers == 0) then
				self.sniperPlayers = nil;
			end;
		end;
		
		if (self.sniperPlayers) then
			cam.Start3D(eyePos, eyeAngles);
				for k, v in ipairs(self.sniperPlayers) do
					if ( IsValid(v) and v:Alive() ) then
						local trace = openAura.player:GetRealTrace(v, true);
						local position = trace.HitPos + (trace.HitNormal * 1.25);
						
						render.SetMaterial(self.laserSprite);
						render.DrawSprite( position, 4, 4, Color(255, 0, 0, 255) );
					end;
				end;
			cam.End3D();
		end;
	end;
end;

-- Called when the menu's items should be adjusted.
function openAura.schema:MenuItemsAdd(menuItems)
	menuItems:Add("Titles", "aura_Titles", "View a list of unlocked titles, or set your title.");
	menuItems:Add("Bounties", "aura_Bounties", "Place a bounty on someone, or view active bounties.");
	menuItems:Add("Alliance", "aura_Alliance", "Manage the alliance that you are a member of.");
	menuItems:Add("Augments", "aura_Augments", "Purchase new or view already purchased augments.");
	menuItems:Add("Victories", "aura_Victories", "View a list of possible victories to achieve.");
end;

-- Called when an entity's menu options are needed.
function openAura.schema:GetEntityMenuOptions(entity, options)
	local mineTypes = {"aura_firemine", "aura_freezemine", "aura_explomine"};
	
	if ( table.HasValue( mineTypes, entity:GetClass() ) ) then
		options["Defuse"] = "aura_mineDefuse";
	elseif (entity:GetClass() == "prop_ragdoll") then
		local player = openAura.entity:GetPlayer(entity);
		
		if ( !player or !player:Alive() ) then
			if ( openAura.augments:Has(AUG_MUTILATOR) ) then
				options["Mutilate"] = "aura_corpseMutilate";
			end;
			
			if ( openAura.augments:Has(AUG_LIFEBRINGER) ) then
				options["Revive"] = "aura_corpseRevive";
			end;
			
			options["Loot"] = "aura_corpseLoot";
		end;
	elseif (entity:GetClass() == "aura_belongings") then
		options["Open"] = "aura_belongingsOpen";
	elseif (entity:GetClass() == "aura_breach") then
		options["Charge"] = "aura_breachCharge";
	elseif ( entity:IsPlayer() ) then
		local cashEnabled = openAura.config:Get("cash_enabled"):Get();
		local myAlliance = openAura.Client:GetAlliance();
		local cashName = openAura.option:GetKey("name_cash");
		
		if (myAlliance and openAura.Client:GetRank() == RANK_MAJ) then
			options["Invite"] = {
				Callback = function(entity) openAura:RunCommand("AllyInvite"); end,
				arguments = true,
				toolTip = "Invite this character to your alliance."
			};
		end;
		
		if ( entity:GetSharedVar("tied") ) then
			options["Untie"] = {
				Callback = function(entity) openAura:RunCommand("PlyUntie"); end,
				arguments = true
			};
		end;
		
		if (cashEnabled) then
			options["Give"] = {
				Callback = function(entity)
					Derma_StringRequest("Amount", "How much do you want to give them?", "0", function(text)
						openAura:RunCommand(string.gsub(cashName, "%s", "").."Give", entity:Name(), text);
					end);
				end,
				arguments = true,
				toolTip = "Give this character some "..string.lower(cashName).."."
			};
		end;
	end;
end;

-- Called when a player's footstep sound should be played.
function openAura.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
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

-- Called when a player's name should be shown as unrecognised.
function openAura.schema:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	if ( player:GetSharedVar("skullMask") and !openAura.augments:Has(AUG_ROUSELESS) ) then
		return "This character is wearing a Skull Mask.";
	end;
end;

-- Called when a player's phys desc override is needed.
function openAura.schema:GetPlayerPhysDescOverride(player, physDesc)
	local physDescOverride = nil;
	
	if (!self.oneDisguise) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("disguise");
			
			if ( IsValid(disguise) ) then
				physDescOverride = openAura.player:GetPhysDesc(disguise);
			end;
		self.oneDisguise = nil;
	end;
	
	if (physDescOverride) then
		return physDescOverride;
	end;
end;

-- Called when the scoreboard's class players should be sorted.
function openAura.schema:ScoreboardSortClassPlayers(class, a, b)
	return a:GetRank() > b:GetRank();
end;

-- Called when a player's scoreboard class is needed.
function openAura.schema:GetPlayerScoreboardClass(player)
	local alliance = player:GetAlliance();
	
	if (alliance) then
		return alliance;
	end;
end;

local PARTICLE_TABLE = { 
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016"
};

-- Called each frame.
function openAura.schema:Think()
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() and v:GetSharedVar("jetpack") ) then
			local bone = v:LookupBone("ValveBiped.Bip01_Spine2");
			
			if (bone) then
				local direction = Vector(0, 0, -256);
				local position, angles = v:GetBonePosition(bone);
				local emitter = ParticleEmitter( v:GetPos() );
				local particle = emitter:Add("particles/flamelet"..math.random(1, 5), position);

				particle:SetAirResistance(100);
				particle:SetStartAlpha(0);
				particle:SetStartSize(10);
				particle:SetEndAlpha(150);
				particle:SetRollDelta( math.Rand(-1, 1) );
				particle:SetVelocity(direction);
				particle:SetDieTime( math.Rand(0.2, 0.4) );
				particle:SetEndSize(0);
				particle:SetRoll( math.Rand(360, 480) );

				local particle = emitter:Add( table.Random(PARTICLE_TABLE), position);

				particle:SetAirResistance(100);
				particle:SetStartAlpha( math.Rand(60, 80) );
				particle:SetRollDelta( math.Rand(-1, 1) );
				particle:SetStartSize( math.Rand(5, 10) );
				particle:SetEndSize( math.Rand(64, 80) );
				particle:SetVelocity(direction);
				particle:SetDieTime(2);
				particle:SetCollide(true);
				particle:SetColor(180, 180, 180);
				particle:SetEndAlpha(0);
				particle:SetRoll( math.Rand(360, 480) );
			end;
		end;
	end;
end;

-- Called when the target player's name is needed.
function openAura.schema:GetTargetPlayerName(player)
	local targetPlayerName = nil;
	local playerAlliance = player:GetAlliance();
	local myAlliance = openAura.Client:GetAlliance();
	
	if (!self.oneDisguise) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("disguise");
			
			if ( IsValid(disguise) and openAura.player:DoesRecognise(disguise) ) then
				local title = disguise:GetSharedVar("title");
				local victoryTable = openAura.victory:Get(title);
				
				if (title != "" and victoryTable) then
					targetPlayerName = string.Replace( victoryTable.unlockTitle, "%n", disguise:Name() );
				else
					targetPlayerName = disguise:Name();
				end;
				
				playerAlliance = disguise:GetAlliance();
				
				if (myAlliance and playerAlliance) then
					if (myAlliance == playerAlliance) then
						return disguise:GetRank(true)..". "..targetPlayerName;
					end;
				end;
			end;
		self.oneDisguise = nil;
	end;
	
	if (targetPlayerName) then
		return targetPlayerName;
	end;
	
	local title = player:GetSharedVar("title");
	local victoryTable = openAura.victory:Get(title);
	
	if (title != "" and victoryTable) then
		targetPlayerName = string.Replace( victoryTable.unlockTitle, "%n", player:Name() );
	end;
	
	if (myAlliance and playerAlliance) then
		if (myAlliance == playerAlliance) then
			return player:GetRank(true)..". "..( targetPlayerName or player:GetName() );
		end;
	end;
	
	if (targetPlayerName) then
		return targetPlayerName;
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function openAura.schema:ScoreboardAdjustPlayerInfo(info)
	local playerAlliance = info.player:GetAlliance();
	local myAlliance = openAura.Client:GetAlliance();
	local playerName = nil;
	
	local title = info.player:GetSharedVar("title");
	local victoryTable = openAura.victory:Get(title);
	
	if (title != "" and victoryTable) then
		playerName = string.Replace( victoryTable.unlockTitle, "%n", info.player:Name() );
	end;
	
	if (myAlliance and playerAlliance) then
		if (myAlliance == playerAlliance) then
			info.name = info.player:GetRank(true)..". "..( playerName or info.player:Name() );
			
			return;
		end;
	end;
	
	if (playerName) then
		info.name = playerName;
	end;
end;

-- Called when an entity is created.
function openAura.schema:OnEntityCreated(entity)
	if ( entity:IsPlayer() ) then
		openAura:RegisterNetworkProxy(entity, "alliance", function(entity, name, oldValue, newValue)
			timer.Simple(FrameTime(), function()
				if ( openAura.menu:GetOpen() ) then
					if (openAura.menu:GetActivePanel() == self.alliancePanel) then
						self.alliancePanel:Rebuild();
					end;
				end;
			end);
		end);
		
		openAura:RegisterNetworkProxy(entity, "bounty", function(entity, name, oldValue, newValue)
			timer.Simple(FrameTime(), function()
				if ( openAura.menu:GetOpen() ) then
					if (openAura.menu:GetActivePanel() == self.bountyPanel) then
						self.bountyPanel:Rebuild();
					end;
				end;
			end);
		end);
	end;
end

-- Called when the local player is created.
function openAura.schema:LocalPlayerCreated()
	openAura:RegisterNetworkProxy(openAura.Client, "skullMask", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			openAura.inventory:Rebuild();
		end;
	end);
	
	openAura:RegisterNetworkProxy(openAura.Client, "implant", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			openAura.inventory:Rebuild();
		end;
	end);
	
	openAura:RegisterNetworkProxy(openAura.Client, "clothes", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			openAura.inventory:Rebuild();
		end;
	end);
	
	openAura:RegisterNetworkProxy(openAura.Client, "title", function(entity, name, oldValue, newValue)
		timer.Simple(FrameTime(), function()
			if ( openAura.menu:GetOpen() ) then
				if (openAura.menu:GetActivePanel() == self.titlesPanel) then
					self.titlesPanel:Rebuild();
				end;
			end;
		end);
	end);
	
	self:OnEntityCreated(openAura.Client);
end;

-- Called when the target's status should be drawn.
function openAura.schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local colorInformation = openAura.option:GetColor("information");
	local thirdPerson = "him";
	local mainStatus = nil;
	local untieText = nil;
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
		
		if ( target:GetSharedVar("tied") ) then
			if (openAura.player:GetAction(openAura.Client) == "untie") then
				mainStatus = gender.. " is being untied.";
			else
				mainStatus = gender.." has been tied up.";
			end;
		elseif (openAura.player:GetAction(openAura.Client) == "chloro") then
			mainStatus = gender.." is having chloroform used on "..thirdPerson..".";
		elseif (openAura.player:GetAction(openAura.Client) == "tie") then
			mainStatus = gender.." is being tied up.";
		end;
		
		if (mainStatus) then
			y = openAura:DrawInfo(mainStatus, x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called to check if a player does recognise another player.
function openAura.schema:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	local doesRecognise = nil;
	
	if ( player:GetSharedVar("skullMask") and !openAura.augments:Has(AUG_ROUSELESS) ) then
		return false;
	end;
	
	if (!self.oneDisguise and !SCOREBOARD_PANEL) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("disguise");
			
			if ( IsValid(disguise) and openAura.player:DoesRecognise(disguise) ) then
				doesRecognise = true;
			end;
		self.oneDisguise = nil;
	end;
	
	return doesRecognise;
end;

-- Called when the target player's text is needed.
function openAura.schema:GetTargetPlayerText(player, targetPlayerText)
	if ( !player:GetSharedVar("skullMask") or openAura.augments:Has(AUG_ROUSELESS) ) then
		local disguise = player:GetSharedVar("disguise");
		
		if ( IsValid(disguise) ) then
			player = disguise;
		end;
		
		local alliance = player:GetAlliance();
		local honor = player:GetSharedVar("honor");
		
		if ( alliance and player:Alive() ) then
			if ( player:IsLeader() ) then
				targetPlayerText:Add( "ALLIANCE", "A leader of \""..alliance.."\".", Color(50, 50, 150, 255) );
			else
				targetPlayerText:Add( "ALLIANCE", "A member of \""..alliance.."\".", Color(50, 150, 50, 255) );
			end;
		end;
		
		if (honor >= 50) then
			targetPlayerText:Add( "HONOR", self:PlayerGetHonorText(player, honor), Color(175, 255, 75, 255) );
		else
			targetPlayerText:Add( "HONOR", self:PlayerGetHonorText(player, honor), Color(255, 75, 175, 255) );
		end;
	end;
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
				DrawMotionBlur(1 - (incrementer * timeLeft), 1, 0);
			else
				self.flashEffect = nil;
			end;
		end;
		
		if (self.tearGassed) then
			local timeLeft = self.tearGassed - curTime;
			
			if (timeLeft > 0) then
				if (timeLeft >= 15) then
					DrawMotionBlur(0.1 + ( 0.9 / (20 - timeLeft) ), 1, 0);
				else
					DrawMotionBlur(0.1, 1, 0);
				end;
			else
				self.tearGassed = nil;
			end;
		end;
	end;
end;

-- Called when the foreground HUD should be painted.
function openAura.schema:HUDPaintForeground()
	local backgroundColor = openAura.option:GetColor("background");
	local dateTimeFont = openAura.option:GetFont("date_time_text");
	local colorWhite = openAura.option:GetColor("white");
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	if ( openAura.Client:Alive() ) then
		local curTime = CurTime();
		
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
		
		if (self.shotEffect) then
			local alpha = math.Clamp( ( 255 / self.shotEffect[2] ) * (self.shotEffect[1] - curTime), 0, 255 );
			local scrH = ScrH();
			local scrW = ScrW();
			
			if (alpha != 0) then
				draw.RoundedBox( 0, 0, 0, scrW, scrH, Color(255, 50, 50, alpha) );
			else
				self.shotEffect = nil;
			end;
		end;
		
		if (#self.damageNotify > 0) then
			openAura:OverrideMainFont(dateTimeFont);
				for k, v in ipairs(self.damageNotify) do
					local alpha = math.Clamp( (255 / v.duration) * (v.endTime - curTime), 0, 255 );
					
					if (alpha != 0) then
						local position = v.position:ToScreen();
						local canSee = openAura.player:CanSeePosition(openAura.Client, v.position);
						
						if (canSee) then
							openAura:DrawInfo(v.text, position.x, position.y - ( (255 - alpha) / 2 ), v.color, alpha);
						end;
					else
						table.remove(self.damageNotify, k);
					end;
				end;
			openAura:OverrideMainFont(false);
		end;
	end;
	
	if ( IsValid(self.hotkeyMenu) ) then
		local menuTextTiny = openAura.option:GetFont("menu_text_tiny");
		local textDisplay = "SELECT WHICH ITEM TO USE";
		
		openAura:DrawSimpleGradientBox(2, self.hotkeyMenu.x - 4, self.hotkeyMenu.y - 4, self.hotkeyMenu:GetWide() + 8, self.hotkeyMenu:GetTall() + 8, backgroundColor);
		openAura:OverrideMainFont(menuTextTiny);
			openAura:DrawInfo(textDisplay, self.hotkeyMenu.x, self.hotkeyMenu.y, colorWhite, 255, true, function(x, y, width, height)
				return x, y - height - 4;
			end);
		openAura:OverrideMainFont(false);
	end;
end;

-- Called to get the screen text info.
function openAura.schema:GetScreenTextInfo()
	local blackFadeAlpha = openAura:GetBlackFadeAlpha();
	
	if (!openAura.Client:Alive() and self.deathType) then
		return {
			alpha = blackFadeAlpha,
			title = "YOU WERE KILLED BY "..self.deathType,
			text = "It probably isn't random, you just don't know the reason."
		};
	elseif ( openAura.Client:GetSharedVar("beingChloro") ) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "SOMEBODY IS USING CHLOROFORM ON YOU"
		};
	elseif ( openAura.Client:GetSharedVar("beingTied") ) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU ARE BEING TIED UP"
		};
	elseif ( openAura.Client:GetSharedVar("tied") ) then
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
	end;
end;

-- Called when the post progress bar info is needed.
function openAura.schema:GetPostProgressBarInfo()
	if ( openAura.Client:Alive() ) then
		local action, percentage = openAura.player:GetAction(openAura.Client, true);
		
		if (action == "die") then
			if ( openAura.augments:Has(AUG_ADRENALINE) ) then
				return {text = "You are slowly healing yourself.", percentage = percentage, flash = percentage > 75};
			else
				return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
			end;
		elseif (action == "chloroform") then
			return {text = "You are using chloroform on somebody.", percentage = percentage, flash = percentage > 75};
		elseif (action == "defuse") then
			return {text = "You are defusing a landmine.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;