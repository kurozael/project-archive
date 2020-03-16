--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local STAR_EMPTY = surface.GetTextureID("cwCityLife/star_empty");
local STAR_FULL = surface.GetTextureID("cwCityLife/star_full");

-- Called when the bars are needed.
function Schema:GetBars(bars)
	local hunger = Clockwork.Client:GetSharedVar("Hunger");
	local thirst = Clockwork.Client:GetSharedVar("Thirst");
	
	if (!self.hunger) then
		self.hunger = hunger;
	else
		self.hunger = math.Approach(self.hunger, hunger, 1);
	end;
	
	if (!self.thirst) then
		self.thirst = thirst;
	else
		self.thirst = math.Approach(self.thirst, thirst, 1);
	end;
	
	if (self.hunger > 25) then
		bars:Add("HUNGER", Color(200, 200, 100, 255), "Hunger", self.hunger, 100, self.hunger > 90);
	end;
	
	if (self.thirst > 25) then
		bars:Add("THIRST", Color(125, 125, 200, 255), "Thirst", self.thirst, 100, self.thirst > 90);
	end;
end;

-- Called before the local player's storage is rebuilt.
function Schema:PlayerPreRebuildStorage(panel)
	local entity = Clockwork.storage:GetEntity();
	local team = Clockwork.Client:Team();
	
	if (!IsValid(entity) or !entity:IsPlayer()) then
		return;
	end;
	
	if (panel.storageType != "Container") then
		return;
	end;

	if (team != CLASS_POLICE and team != CLASS_DISPENSER
	and team != CLASS_RESPONSE and team != CLASS_SECRETARY
	and team != CLASS_PRESIDENT) then
		return;
	end;
	
	for k, v in pairs(panel.inventory) do
		local itemTable = Clockwork.item:FindByID(k);
		local itemClasses = itemTable("classes");
		
		if (!itemClasses
		or table.HasValue(itemClasses, CLASS_BLACKMARKET)) then
			panel.inventory[k] = nil;
		end;
	end;
	
	panel.cash = 0;
end;

-- Called just after the translucent renderables have been drawn.
function Schema:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox) then
		local colorWhite = Clockwork.option:GetColor("white");
		local colorBlack = Color(0, 0, 0, 255);
		local eyeAngles = EyeAngles();
		local curTime = UnPredictedCurTime();
		local eyePos = EyePos();
		
		if (curTime >= self.nextGetSnipers) then
			self.nextGetSnipers = curTime + 1;
			self.sniperPlayers = {};
			
			for k, v in ipairs(_player.GetAll()) do
				if (Clockwork.player:GetWeaponRaised(v)) then
					local weapon = v:GetActiveWeapon();
					
					if (v:HasInitialized() and IsValid(weapon)) then
						local weaponClass = string.lower(weapon:GetClass());
						
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
					if (IsValid(v) and v:Alive()) then
						local trace = Clockwork.player:GetRealTrace(v, true);
						local position = trace.HitPos + (trace.HitNormal * 1.25);
						
						render.SetMaterial(self.laserSprite);
						render.DrawSprite(position, 4, 4, Color(255, 0, 0, 255));
					end;
				end;
			cam.End3D();
		end;
		
		cam.Start3D(eyePos, eyeAngles);
			for k, v in ipairs(self.billboards) do
				if (v.data and IsValid(v.data.owner)) then
					cam.Start3D2D(v.position, v.angles, v.scale);
						local smallHeight = draw.GetFontHeight("cid_BillboardSmall");
						local bigHeight = draw.GetFontHeight("cid_BillboardBig");
						local bigY = math.max(64, bigHeight);
						
						surface.SetDrawColor(Clockwork:UnpackColor(v.data.color));
						surface.DrawRect(0, 0, 512, 256);
						
						draw.SimpleText(v.data.title, "cid_BillboardBig", 256, bigY, colorBlack, 1, 1);
						
						for k, v in ipairs(v.data.text) do
							draw.SimpleText(v, "cid_BillboardSmall", 256, bigY + (smallHeight * k) + 16, colorBlack, 1, 1);
						end;
					cam.End3D2D();
				else
					cam.Start3D2D(v.position, v.angles, v.scale);
						surface.SetDrawColor(Clockwork:UnpackColor(colorWhite));
						surface.DrawRect(0, 0, 512, 256);
						
						draw.SimpleText("Billboard #"..k, "cid_BillboardBig", 256, 64, colorBlack, 1, 1);
						draw.SimpleText("This billboard can be purchased.", "cid_BillboardSmall", 256, 128, colorBlack, 1, 1);
					cam.End3D2D();
				end;
			end;
		cam.End3D();
	end;
end;

-- Called when the menu's items should be adjusted.
function Schema:MenuItemsAdd(menuItems)
	menuItems:Add("Billboards", "cwBillboards", "Purchase or update a billboard.");
	menuItems:Add("Lottery", "cwLottery", "Purchase a lottery ticket and get lucky.");
end;

-- Called when an entity's menu options are needed.
function Schema:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "prop_ragdoll") then
		local player = Clockwork.entity:GetPlayer(entity);
		
		if (!player or !player:Alive()) then
			options["Loot"] = "cwCorpseLoot";
		end;
	elseif (entity:GetClass() == "cw_broadcaster") then
		if (!entity:IsOff()) then
			options["Turn Off"] = "cwBroadcasterToggle";
		else
			options["Turn On"] = "cwBroadcasterToggle";
		end;
		
		options["Take"] = "cwBroadcasterTake";
	elseif (entity:GetClass() == "cw_belongings") then
		options["Open"] = "cwBelongingsOpen";
	elseif (entity:GetClass() == "cw_breach") then
		options["Charge"] = "cwBreachCharge";
	elseif (entity:GetClass() == "cw_radio") then
		if (!entity:IsOff()) then
			options["Turn Off"] = "cwRadioToggle";
		else
			options["Turn On"] = "cwRadioToggle";
		end;
		
		options["Set Frequency"] = function()
			Derma_StringRequest("Frequency", "What would you like to set the frequency to?", frequency, function(text)
				if (IsValid(entity)) then
					Clockwork.entity:ForceMenuOption(entity, "Set Frequency", text);
				end;
			end);
		end;
		
		options["Take"] = "cwRadioTake";
	end;
end;

-- Called when the local player attempts to see a class.
function Schema:PlayerCanSeeClass(class)
	if (table.HasValue(self.blacklist, class.index)) then
		return false;
	end;
end;

-- Called when a player's footstep sound should be played.
function Schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when a text entry has gotten focus.
function Schema:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel;
end;

-- Called when a text entry has lost focus.
function Schema:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil;
end;

-- Called when the local player's color modify should be adjusted.
function Schema:PlayerAdjustColorModify(colorModify)
	local interval = FrameTime() * 0.1;
	local contrast = colorModify["$pp_colour_contrast"];
	local color = colorModify["$pp_colour_colour"];
	
	if (!self.colorContrast) then
		self.colorContrast = contrast;
	end;
	
	if (!self.colorModify) then
		self.colorModify = color;
	end;
	
	if (!Clockwork.Client:HasInitialized()) then
		self.colorModify = math.Approach(self.colorModify, color, interval);
	else
		local hunger = Clockwork.Client:GetSharedVar("Hunger");
		local thirst = Clockwork.Client:GetSharedVar("Thirst");
		local data = math.max(hunger, thirst);
		
		color = math.min(math.max(((1 / 100) * (100 - data)) * 2, 0.2), color);
		
		if (Clockwork.Client:GetSharedVar("Withdrawal")) then
			contrast = 1.3;
			color = 0.1
		end;
		
		self.colorContrast = math.Approach(self.colorContrast, contrast, interval);
		self.colorModify = math.Approach(self.colorModify, color, interval);
	end;
	
	colorModify["$pp_colour_contrast"] = self.colorContrast;
	colorModify["$pp_colour_colour"] = self.colorModify;
end;

-- Called when the local player's motion blurs should be adjusted.
function Schema:PlayerAdjustMotionBlurs(motionBlurs)
	if (Clockwork.Client:HasInitialized()) then
		local hunger = Clockwork.Client:GetSharedVar("Hunger");
		local thirst = Clockwork.Client:GetSharedVar("Thirst");
		local data = math.max(hunger, thirst);
		
		if (data >= 90) then
			motionBlurs.blurTable["needs"] = 1 - ((0.25 / 10) * (10 - (100 - data)));
		end;
		
		if (Clockwork.Client:GetSharedVar("Withdrawal")) then
			motionBlurs.blurTable["withdrawal"] = 0.25;
		end;
	end;
end;

-- Called when screen space effects should be rendered.
function Schema:RenderScreenspaceEffects()
	local modify = {};
	
	if (!Clockwork:IsScreenFadedBlack()) then
		local curTime = CurTime();
		local frameTime = FrameTime();
		local highSpeed = 0;
		
		for k, v in pairs(self.highEffects) do
			if (curTime >= v) then
				self.highEffects[k] = nil;
			elseif (highSpeed == 0) then
				highSpeed = frameTime * 0.5;
			else
				highSpeed = highSpeed * 2;
			end;
		end;
		
		if (self.flashEffect) then
			local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2]);
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
			end;
		end;
		
		if (self.tearGassed) then
			local timeLeft = self.tearGassed - curTime;
			
			if (timeLeft > 0) then
				if (timeLeft >= 15) then
					DrawMotionBlur(0.1 + (0.9 / (20 - timeLeft)), 1, 0);
				else
					DrawMotionBlur(0.1, 1, 0);
				end;
			end;
		end;
		
		if (highSpeed > 0) then
			if (self.highDistance == 5) then
				self.highTarget = -5;
			elseif (self.highDistance == -5) then
				self.highTarget = 5;
			end;
			
			self.highDistance = math.Approach(self.highDistance, self.highTarget, highSpeed);
		else
			self.highDistance = math.Approach(self.highDistance, 0, frameTime * 0.1);
		end;
		
		if (self.highDistance != 0) then
			DrawSharpen(1, self.highDistance);
		end;
	end;
end;

-- Called when the cinematic intro info is needed.
function Schema:GetCinematicIntroInfo()
	return {
		credits = "A roleplaying game designed by "..self:GetAuthor()..".",
		title = Clockwork.config:Get("intro_text_big"):Get(),
		text = Clockwork.config:Get("intro_text_small"):Get()
	};
end;

-- Called when a player's name should be shown as unrecognised.
function Schema:PlayerCanShowUnrecognised(player, x, y, color, alpha, flashAlpha)
	if (player:GetSharedVar("SkullMask")) then
		return "This character is wearing a Skull Mask.";
	end;
end;

-- Called when a player's phys desc override is needed.
function Schema:GetPlayerPhysDescOverride(player, physDesc)
	local physDescOverride = nil;
	
	if (!self.oneDisguise) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("Disguise");
			
			if (IsValid(disguise)) then
				physDescOverride = Clockwork.player:GetPhysDesc(disguise);
			end;
		self.oneDisguise = nil;
	end;
	
	if (physDescOverride) then
		return physDescOverride;
	end;
end;

-- Called when the target player's name is needed.
function Schema:GetTargetPlayerName(player)
	local targetPlayerName = nil;
	
	if (!self.oneDisguise) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("Disguise");
			
			if (IsValid(disguise) and Clockwork.player:DoesRecognise(disguise)) then
				targetPlayerName = disguise:Name();
			end;
		self.oneDisguise = nil;
	end;
	
	if (targetPlayerName) then
		return targetPlayerName;
	end;
end;

-- Called when the local player is created.
function Schema:LocalPlayerCreated()
	Clockwork:RegisterNetworkProxy(Clockwork.Client, "skullMask", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			Clockwork.inventory:Rebuild();
		end;
	end);
	
	Clockwork:RegisterNetworkProxy(Clockwork.Client, "lottery", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			if (IsValid(self.cwLotteryPanel)) then
				self.cwLotteryPanel:Rebuild();
			end;
		end;
	end);
	
	Clockwork:RegisterNetworkProxy(Clockwork.Client, "sensor", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			Clockwork.inventory:Rebuild();
		end;
	end);
	
	Clockwork:RegisterNetworkProxy(GetWorldEntity(), "lottery", function(entity, name, oldValue, newValue)
		if (oldValue != newValue) then
			if (IsValid(self.cwLotteryPanel)) then
				self.cwLotteryPanel:Rebuild();
			end;
		end;
	end);
end;

-- Called when the target's status should be drawn.
function Schema:DrawTargetPlayerStatus(target, alpha, x, y)
	local colorInformation = Clockwork.option:GetColor("information");
	local thirdPerson = "him";
	local mainStatus = nil;
	local untieText = nil;
	local gender = "He";
	local action = Clockwork.player:GetAction(target);
	
	if (target:GetGender() == GENDER_FEMALE) then
		thirdPerson = "her";
		gender = "She";
	end;
	
	if (target:Alive()) then
		if (action == "die") then
			mainStatus = gender.." is in critical condition.";
		end;
		
		if (target:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
			mainStatus = gender.." is clearly unconscious.";
		end;
		
		if (target:GetSharedVar("IsTied") != 0) then
			if (Clockwork.player:GetAction(Clockwork.Client) == "untie") then
				mainStatus = gender.. " is being untied.";
			else
				local untieText;
				
				if (target:GetShootPos():Distance(Clockwork.Client:GetShootPos()) <= 192) then
					if (Clockwork.Client:GetSharedVar("IsTied") == 0) then
						mainStatus = "Press :+use: to untie "..thirdPerson..".";
						
						untieText = true;
					end;
				end;
				
				if (!untieText) then
					mainStatus = gender.." has been tied up.";
				end;
			end;
		elseif (Clockwork.player:GetAction(Clockwork.Client) == "chloro") then
			mainStatus = gender.." is having chloroform used on "..thirdPerson..".";
		elseif (Clockwork.player:GetAction(Clockwork.Client) == "tie") then
			mainStatus = gender.." is being tied up.";
		elseif (Clockwork.player:GetAction(target) == "drug") then
			mainStatus = gender.." is getting high.";
		end;
		
		if (mainStatus) then
			y = Clockwork:DrawInfo(Clockwork:ParseData(mainStatus), x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called to check if a player does recognise another player.
function Schema:PlayerDoesRecognisePlayer(player, status, isAccurate, realValue)
	local doesRecognise = nil;
	
	if (player:GetSharedVar("SkullMask")) then
		return false;
	end;
	
	if (status < RECOGNISE_SAVE) then
		local localTeam = Clockwork.Client:Team();
		local playerTeam = player:Team();
		
		if (localTeam == CLASS_POLICE or localTeam == CLASS_DISPENSER or localTeam == CLASS_RESPONSE
		or localTeam == CLASS_SECRETARY or localTeam == CLASS_PRESIDENT) then
			if (playerTeam == CLASS_POLICE or playerTeam == CLASS_DISPENSER or playerTeam == CLASS_RESPONSE
			or playerTeam == CLASS_SECRETARY or playerTeam == CLASS_PRESIDENT) then
				return true;
			end;
		end;
	end;
	
	if (!self.oneDisguise and !SCOREBOARD_PANEL) then
		self.oneDisguise = true;
			local disguise = player:GetSharedVar("Disguise");
			
			if (IsValid(disguise) and Clockwork.player:DoesRecognise(disguise)) then
				doesRecognise = true;
			end;
		self.oneDisguise = nil;
	end;
	
	return doesRecognise;
end;

-- Called when the target player's text is needed.
function Schema:GetTargetPlayerText(player, targetPlayerText)
	if (Clockwork.player:DoesRecognise(player, RECOGNISE_SAVE)) then
		local disguise = player:GetSharedVar("Disguise");
		
		if (IsValid(disguise)) then
			player = disguise;
		end;
		
		local alliance = player:GetSharedVar("Alliance");
		
		if (alliance != "") then
			if (player:GetSharedVar("Leader")) then
				targetPlayerText:Add("ALLIANCE", "A leader of \""..alliance.."\".", Color(50, 50, 150, 255));
			else
				targetPlayerText:Add("ALLIANCE", "A member of \""..alliance.."\".", Color(50, 150, 50, 255));
			end;
		end;
	end;
end;

-- Called when the player info text is needed.
function Schema:GetPlayerInfoText(playerInfoText)
	local alliance = Clockwork.Client:GetSharedVar("Alliance");
	
	if (alliance != "") then
		playerInfoText:AddSub("ALLIANCE", alliance);
	end;
end;

-- Called when the target player's text should be destroyed.
function Schema:DestroyTargetPlayerText(entity, targetPlayerText)
	if (targetPlayerText:Get("FACTION") and targetPlayerText:Get("STATUS")) then
		targetPlayerText:Destroy("FACTION");
	end;
end;

-- Called when the foreground HUD should be painted.
function Schema:HUDPaintForeground()
	if (Clockwork.Client:Alive()) then
		local scrH = ScrH();
		local scrW = ScrW();
		
		if (self.stunEffects) then
			local curTime = CurTime();
			
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp((255 / v[2]) * (v[1] - curTime), 0, 255);
				
				if (alpha != 0) then
					draw.RoundedBox(0, 0, 0, scrW, scrH, Color(255, 255, 255, alpha));
				else
					table.remove(self.stunEffects, k);
				end;
			end;
		end;
		
		if (self.currentCrime) then
			local crimeName = "committing a murder";
			local alpha = (255 / 6) * math.Clamp(self.currentCrime.fadeOut - CurTime(), 0, 6);
			local y = scrH - 256;
			local x = scrW - 128 - 50;
			
			if (self.currentCrime.crime == CRIME_ASSAULT) then
				crimeName = "committing assault";
			elseif (self.currentCrime.crime == CRIME_DRUGS) then
				crimeName = "consuming illegal drugs";
			elseif (self.currentCrime.crime == CRIME_WEAPON) then
				crimeName = "in posession of an illegal weapon";
			end;
			
			surface.SetDrawColor(255, 255, 255, alpha);
			surface.SetTexture(STAR_FULL);
			surface.DrawTexturedRect(x, y, 128, 128);
			
			Clockwork:DrawInfo("SPOTTED "..string.upper(crimeName), scrW, y + 128 + 8, Color(200, 100, 100, 255), alpha, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
			
			if (alpha == 255) then
				self.currentCrime = nil;
			end;
		end;
		
		local starX = scrW - 200;
		local starY = scrH - 40;
		local stars = Clockwork.Client:GetSharedVar("Stars");
		
		if (stars > 0) then
			for i = 1, 5 do
				if (i <= stars) then
					surface.SetTexture(STAR_FULL);
				else
					surface.SetTexture(STAR_EMPTY);
				end;
				
				surface.SetDrawColor(255, 255, 255, 255);
				surface.DrawTexturedRect(starX, starY, 32, 32);
				
				starX = starX + 40;
			end;
		end;
	end;
end;

-- Called after a player has been drawn.
function Schema:PostPlayerDraw(player)
	if (Clockwork.Client:GetFaction() == FACTION_POLICE) then
		local stars = player:GetSharedVar("Stars");
		
		if (stars > 0 and Clockwork.player:CanSeePlayer(Clockwork.Client, player)) then
			local crimesShared = player:GetSharedVar("Crimes");
			local colorWhite = Clockwork.option:GetColor("white");
			local eyeAngles = Clockwork.Client:EyeAngles();
			local crimes = {};
			local font = Clockwork.option:GetFont("large_3d_2d");
			local starX = -50;
			local starY = 0;
			
			if (crimesShared and crimesShared != "") then
				crimes = glon.decode(crimesShared);
			end;
			
			local offset = Vector(0, 0, 100);
			local position = player:GetPos() + offset + eyeAngles:Up();
		 
			eyeAngles:RotateAroundAxis(eyeAngles:Forward(), 90);
			eyeAngles:RotateAroundAxis(eyeAngles:Right(), 90);
		 
			cam.Start3D2D(position, Angle(0, eyeAngles.y, 90), 0.03);
				for i = 1, 5 do
					if (i <= stars) then
						surface.SetTexture(STAR_FULL);
					else
						surface.SetTexture(STAR_EMPTY);
					end;
					
					surface.SetDrawColor(255, 255, 255, 255);
					surface.DrawTexturedRect(starX, starY, 16, 16);
					
					starX = starX + 20;
				end;
				
				local crimeString = "";
				
				for k, v in pairs(crimes) do
					if (crimeString == "") then
						crimeString = v.." x "..string.upper(self:CrimeToName(k));
					else
						crimeString = crimeString..", "..v.." x "..string.upper(self:CrimeToName(k));
					end;
				end;
				
				if (crimeString != "") then
					Clockwork:OverrideMainFont(font);
						Clockwork:DrawInfo(crimeString, 0, starY + 20, colorWhite);
					Clockwork:OverrideMainFont(false);
				end;
			cam.End3D2D();
		end;
	end;
end;

-- Called when the top screen HUD should be painted.
function Schema:HUDPaintTopScreen(info)
	local wrappedTable = {};
	local colorWhite = Clockwork.option:GetColor("white");
	local team = Clockwork.Client:Team();
	
	if (Clockwork.inventory:HasItemByID("heartbeat_sensor")) then
		if (Clockwork.Client:GetSharedVar("Sensor")) then
			local aimVector = Clockwork.Client:GetAimVector();
			local position = Clockwork.Client:GetPos();
			local curTime = UnPredictedCurTime();

			self.heartbeatOverlay:SetMaterialFloat("$alpha", 0.5);
			
			surface.SetDrawColor(255, 255, 255, 128);
				surface.SetMaterial(self.heartbeatOverlay);
			surface.DrawTexturedRect(info.x, info.y, 200, 200);
			
			surface.SetDrawColor(0, 200, 0, 255);
				surface.SetMaterial(self.heartbeatPoint);
			surface.DrawTexturedRect(info.x + 84, info.y + 84, 32, 32);
			
			if (self.heartbeatScan) then
				local scanAlpha = math.min((255 / 3) * math.max(self.heartbeatScan.fadeOutTime - curTime, 0), 255);
				local y = self.heartbeatScan.y + ((184 / 255) * (255 - scanAlpha));
				
				if (scanAlpha > 0) then
					surface.SetDrawColor(100, 0, 0, scanAlpha * 0.5);
						surface.SetMaterial(self.heartbeatGradient);
					surface.DrawTexturedRect(self.heartbeatScan.x, y, self.heartbeatScan.width, self.heartbeatScan.height);
				else
					self.heartbeatScan = nil;
				end;
			end;
			
			if (curTime >= self.nextHeartbeatCheck) then
				self.nextHeartbeatCheck = curTime + 2;
				self.oldHeartbeatPoints = self.heartbeatPoints;
				self.heartbeatPoints = {};
				self.heartbeatScan = {
					fadeOutTime = curTime + 3,
					height = 16,
					width = 200,
					y = info.y,
					x = info.x
				};
				
				local centerY = info.y + 100;
				local centerX = info.x + 100;
				
				for k, v in ipairs(ents.FindInSphere(position, 768)) do
					if (v:IsPlayer() and v:Alive() and v:HasInitialized()) then
						if (Clockwork.Client != v and !Clockwork.player:IsNoClipping(v)) then
							if (v:Health() >= (v:GetMaxHealth() / 3)) then
								local playerPosition = v:GetPos();
								local difference = playerPosition - position;
								local pointX = (difference.x / 768);
								local pointY = (difference.y / 768);
								local pointZ = math.sqrt(pointX * pointX + pointY * pointY);
								local phi = math.Deg2Rad(math.Rad2Deg(math.atan2(pointX, pointY)) - math.Rad2Deg(math.atan2(aimVector.x, aimVector.y)) - 90);
								
								pointX = math.cos(phi) * pointZ;
								pointY = math.sin(phi) * pointZ;
								
								self.heartbeatPoints[#self.heartbeatPoints + 1] = {
									fadeInTime = curTime + 2,
									height = 32,
									width = 32,
									x = centerX + (pointX * 100) - 16,
									y = centerY + (pointY * 100) - 16
								};
							end;
						end;
					end;
				end;
				
				if (self.lastHeartbeatAmount > #self.heartbeatPoints) then
					Clockwork.Client:EmitSound("items/flashlight1.wav", 25);
				end;
				
				for k, v in ipairs(self.oldHeartbeatPoints) do
					v.fadeOutTime = curTime + 2;
					v.fadeInTime = nil;
				end;
				
				self.lastHeartbeatAmount = #self.heartbeatPoints;
			end;
			
			for k, v in ipairs(self.oldHeartbeatPoints) do
				local pointAlpha = (255 / 2) * math.max(v.fadeOutTime - curTime, 0);
				local pointX = math.Clamp(v.x, info.x, (info.x + 200) - 32);
				local pointY = math.Clamp(v.y, info.y, (info.y + 200) - 32);
				
				surface.SetDrawColor(200, 0, 0, pointAlpha);
					surface.SetMaterial(self.heartbeatPoint);
				surface.DrawTexturedRect(pointX, pointY, v.width, v.height);
			end;
			
			for k, v in ipairs(self.heartbeatPoints) do
				local pointAlpha = 255 - ((255 / 2) * math.max(v.fadeInTime - curTime, 0));
				local pointX = math.Clamp(v.x, info.x, (info.x + 200) - 32);
				local pointY = math.Clamp(v.y, info.y, (info.y + 200) - 32);
				
				surface.SetDrawColor(200, 0, 0, pointAlpha);
					surface.SetMaterial(self.heartbeatPoint);
				surface.DrawTexturedRect(pointX, pointY, v.width, v.height);
			end;
			
			info.y = info.y + 212;
		end;
	end;
	
	if (Clockwork.config:Get("using_life_system"):Get()) then
		info.y = Clockwork:DrawInfo("YOUR CHARACTER ONLY HAS ONE LIFE.", info.x, info.y, Color(200, 100, 100, 255), nil, true);
	end;
	
	if (team == CLASS_PRESIDENT or team == CLASS_SECRETARY or team == CLASS_POLICE
	or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
		local noWagesTime = Clockwork:GetSharedVar("NoWagesTime");
		local curTime = CurTime();
		local agenda = "";
		
		if (noWagesTime > curTime) then
			agenda = "YOU WILL NOT RECEIVE ANY WAGES FOR "..math.Round(math.ceil(noWagesTime - curTime)).." SECOND(S).";
		else
			agenda = Clockwork:GetSharedVar("Agenda");
		end;
			
		if (agenda != "") then
			Clockwork:WrapText(agenda, Clockwork.option:GetFont("main_text"), 200, wrappedTable);
			
			for k, v in ipairs(wrappedTable) do
				info.y = Clockwork:DrawInfo(string.upper(v), info.x, info.y, colorWhite, nil, true);
			end;
		else
			Clockwork:DrawInfo("NO AGENDA HAS BEEN SET.", info.x, info.y, colorWhite, nil, true);
		end;
	end;
end;

-- Called to get the screen text info.
function Schema:GetScreenTextInfo()
	local blackFadeAlpha = Clockwork:GetBlackFadeAlpha();
	
	if (!Clockwork.Client:Alive() and self.deathType) then
		return {
			alpha = blackFadeAlpha,
			title = "YOU WERE KILLED BY "..self.deathType,
			text = "Go to the character menu to make a new one."
		};
	elseif (Clockwork.Client:GetSharedVar("BeingChloro")) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "SOMEBODY IS USING CHLOROFORM ON YOU"
		};
	elseif (Clockwork.Client:GetSharedVar("BeingTied")) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU ARE BEING TIED UP"
		};
	elseif (Clockwork.Client:GetSharedVar("IsTied") != 0) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU HAVE BEEN TIED UP"
		};
	end;
end;

-- Called when the chat box info should be adjusted.
function Schema:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker)) then
		if (info.data.anon) then
			info.name = "Somebody";
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function Schema:GetPostProgressBarInfo()
	if (Clockwork.Client:Alive()) then
		local action, percentage = Clockwork.player:GetAction(Clockwork.Client, true);
		
		if (action == "die") then
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		elseif (action == "drug") then
			return {text = "You are getting high from a drug.", percentage = percentage, flash = percentage > 75};
		elseif (action == "chloroform") then
			return {text = "You are using chloroform on somebody.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;