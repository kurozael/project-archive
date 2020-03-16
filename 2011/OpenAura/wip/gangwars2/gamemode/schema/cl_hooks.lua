--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local OUTLINE_MATERIAL = Material("white_outline");

-- Called when a weapon's lowered view info is needed.
function openAura.schema:GetWeaponLoweredViewInfo(itemTable, weapon, viewInfo)
	local class = weapon:GetClass();
	
	if (class == "aura_smokegrenade" or class == "aura_flashgrenade"
	or class == "weapon_frag") then
		viewInfo.origin = Vector(3, 0, -4);
		viewInfo.angles = Angle(0, 45, 0);
	end;
end;

-- Called to get whether a player's target ID should be drawn.
function openAura.schema:ShouldDrawPlayerTargetID(player)
	if (player:GetMaterial() == "sprites/heatwave") then
		return false;
	end;
end;

-- Called when a player's scoreboard class is needed.
function openAura.schema:GetPlayerScoreboardClass(player)
	return openAura.player:GetFaction(player);
end;

-- Called when the local player should be drawn.
function openAura.schema:ShouldDrawLocalPlayer()
	if ( ( openAura.Client:IsRunning() and !openAura.player:IsNoClipping(openAura.Client) )
	and (!self.overrideThirdPerson or UnPredictedCurTime() >= self.overrideThirdPerson) ) then
		self.thirdPersonAmount = math.Approach( self.thirdPersonAmount, 1, FrameTime() / 10);
	else
		self.thirdPersonAmount = math.Approach(self.thirdPersonAmount, 0, FrameTime() / 10);
	end;
	
	if (self.thirdPersonAmount > 0) then
		return true;
	end;
end;

-- Called when the calc view table should be adjusted.
function openAura.schema:CalcViewAdjustTable(view)
	if ( self.thirdPersonAmount > 0 and !openAura.player:IsNoClipping(openAura.Client) ) then
		local defaultOrigin = view.origin;
		local traceLine = nil;
		local position = openAura.Client:EyePos();
		local angles = openAura.Client:GetRenderAngles():Forward();
		
		if (defaultOrigin) then
			traceLine = util.TraceLine( {
				start = position,
				endpos = position - ( angles * (80 * self.thirdPersonAmount) ),
				filter = openAura.Client
			} );
			
			if (traceLine.Hit) then
				view.origin = traceLine.HitPos + (angles * 4) + Vector(0, 0, 16);
				
				if (view.origin:Distance(position) <= 32) then
					view.origin = defaultOrigin + Vector(0, 0, 16);
				end;
			else
				view.origin = traceLine.HitPos + Vector(0, 0, 16);
			end;
		end;
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
								local playerPosition = v:GetPos();
								local difference = playerPosition - position;
								local pointX = (difference.x / 768);
								local pointY = (difference.y / 768);
								local pointZ = math.sqrt(pointX * pointX + pointY * pointY);
								local color = Color(200, 0, 0, 255);
								local phi = math.Deg2Rad(math.Rad2Deg( math.atan2(pointX, pointY) ) - math.Rad2Deg( math.atan2(aimVector.x, aimVector.y) ) - 90);
								pointX = math.cos(phi) * pointZ;
								pointY = math.sin(phi) * pointZ;
								
								if ( openAura.player:GetFaction(openAura.Client) == openAura.player:GetFaction(v) ) then
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
	
	local weapon = openAura.Client:GetActiveWeapon();
	local info = openAura:GetAmmoInformation(weapon);
	
	if (!self.hudBulletPhysics) then
		self.hudBulletPhysics = {};
	end;
	
	if (info and !info.primary.doesNotShoot) then
		local width = 12 + (info.primary.clipSize * 8);
		local height = 28;
		local takeX = 0;
		local curX = 0;
		local x = ScrW() - width - 16;
		local y = ScrH() - height - 16;
		
		draw.RoundedBox( 4, x, y, width, height, Color(0, 0, 0, 200) );
		surface.SetTexture( surface.GetTextureID("vgui/white") );
		surface.SetDrawColor(100, 100, 100, 255);
		
		for i = 1, info.primary.clipBullets do
			curX = ( (x + width) - 12 ) - takeX;
			takeX = takeX + 8;
			
			surface.DrawTexturedRectRotated( curX, y + 12, 4, 12, 0);
		end;
		
		if (weapon.LastClip and info.primary.clipBullets < weapon.LastClip) then
			self.hudBulletPhysics[#self.hudBulletPhysics + 1] = {
				lerpAmount = 0,
				randomAdd = math.random(1, 32),
				randomGen = math.random(90, 180),
				x = curX,
				y = y + 8
			};
		end;
		
		for k, v in ipairs(self.hudBulletPhysics) do
			v.lerpAmount = math.Approach( v.lerpAmount, 1, FrameTime() );
			
			local rotation = (v.lerpAmount * 2) * v.randomGen;
			local alpha = 255;
			local y = v.y + Lerp(v.lerpAmount, Lerp(v.lerpAmount * 10, 0, -32 - v.randomAdd), 128 + v.randomAdd);
			local x = v.x - ( (v.lerpAmount * 2) * (64 + v.randomAdd) );
			
			if (v.lerpAmount > 0.75) then
				alpha = (255 / 0.25) * (1 - v.lerpAmount);
			end;
			
			if (v.lerpAmount == 1) then
				table.remove(self.hudBulletPhysics, k);
			end;
			
			surface.SetDrawColor(100, 100, 100, alpha);
			surface.DrawTexturedRectRotated( x, y, 4, 12, rotation);
		end;
		
		weapon.LastClip = info.primary.clipBullets;
	end;
end;

-- Called just after a player is drawn.
function openAura.schema:PostPlayerDraw(player)
	if (!DO_NOT_DRAW) then
		DO_NOT_DRAW = true;
		
		if (openAura.Client != player and player:GetMaterial() != "sprites/heatwave"
		and player:GetMoveType() == MOVETYPE_WALK) then
			if ( self.targetOutlines[player] ) then
				local alpha = math.Clamp( (255 / 60) * ( self.targetOutlines[player] - CurTime() ), 0, 255 );
				
				if (alpha > 0) then
					self:DrawBasicOutline( player, Color(255, 255, 255, alpha) );
				end;
			else
				self:DrawBasicOutline( player, _team.GetColor( player:Team() ) );
			end;
		end;
		
		DO_NOT_DRAW = false;
	end;
end;

-- Called when the menu's items should be adjusted.
function openAura.schema:MenuItemsAdd(menuItems)
	menuItems:Add("Titles", "aura_Titles", "View a list of unlocked titles, or set your title.");
	menuItems:Add("Upgrades", "aura_Upgrades", "Purchase new or view already purchased upgrades.");
	menuItems:Add("Achievements", "aura_Achievements", "View a list of possible achievements to achieve.");
end;

function openAura.schema:MenuItemsDestroy(menuItems)
	menuItems:Destroy( openAura.option:GetKey("name_attributes") );
	menuItems:Destroy( openAura.option:GetKey("name_inventory") );
	menuItems:Destroy( openAura.option:GetKey("name_business") );
	
	local classesItem = menuItems:Get("Classes");
	
	if (classesItem) then
		classesItem.text = "Loadouts";
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
	local title = player:GetSharedVar("title");
	local prefixLevel = tostring( self:GetLevel(player) )..". ";
	local achievementTable = openAura.achievement:Get(title);
	
	if (title != "" and achievementTable) then
		return prefixLevel..string.Replace( achievementTable.unlockTitle, "%n", player:Name() );
	else
		return prefixLevel..player:Name();
	end;
end;

-- Called when the scoreboard's player info should be adjusted.
function openAura.schema:ScoreboardAdjustPlayerInfo(info)
	local title = info.player:GetSharedVar("title");
	local playerName = nil;
	local achievementTable = openAura.achievement:Get(title);
	
	if (title != "" and achievementTable) then
		playerName = string.Replace( achievementTable.unlockTitle, "%n", info.player:Name() );
	end;
	
	if (playerName) then
		info.name = playerName;
	end;
end;

-- Called when the local player is created.
function openAura.schema:LocalPlayerCreated()
	openAura:RegisterNetworkProxy(openAura.Client, "title", function(entity, name, oldValue, newValue)
		timer.Simple(FrameTime(), function()
			if ( openAura.menu:GetOpen() ) then
				if (openAura.menu:GetActivePanel() == self.titlesPanel) then
					self.titlesPanel:Rebuild();
				end;
			end;
		end);
	end);
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
		
		if (mainStatus) then
			y = openAura:DrawInfo(mainStatus, x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called when screen space effects should be rendered.
function openAura.schema:RenderScreenspaceEffects()
	local thermalVision = openAura.Client:GetSharedVar("thermal");
	local modulation = {1, 1, 1};
	local curTime = UnPredictedCurTime();
	
	if (thermalVision) then
		modulation = {1, 0, 0};
		
		local colorModify = {};
			colorModify["$pp_colour_brightness"] = 0;
			colorModify["$pp_colour_contrast"] = 1;
			colorModify["$pp_colour_colour"] = 0.1;
			colorModify["$pp_colour_addr"] = 0;
			colorModify["$pp_colour_addg"] = 0;
			colorModify["$pp_colour_addb"] = 0.1;
			colorModify["$pp_colour_mulr"] = 25;
			colorModify["$pp_colour_mulg"] = 0;
			colorModify["$pp_colour_mulb"] = 25;
		DrawColorModify(colorModify);
	end;
	
	if (self.thirdPersonAmount > 0) then
		render.UpdateScreenEffectTexture();
			self.fishEyeTexture:SetMaterialFloat("$envmap", 0);
			self.fishEyeTexture:SetMaterialFloat("$envmaptint",	0);
			self.fishEyeTexture:SetMaterialFloat("$refractamount", self.thirdPersonAmount / 16);
			self.fishEyeTexture:SetMaterialInt("$ignorez", 1);
		render.SetMaterial(self.fishEyeTexture);
		render.DrawScreenQuad();
	else
		render.UpdateScreenEffectTexture();
			self.fishEyeTexture:SetMaterialFloat("$envmap", 0);
			self.fishEyeTexture:SetMaterialFloat("$envmaptint",	0);
			self.fishEyeTexture:SetMaterialInt("$ignorez", 1);
		render.SetMaterial(self.visorTexture);
		render.DrawScreenQuad();
	end;
	
	cam.Start3D( EyePos(), EyeAngles() );
		for k, v in ipairs( _player.GetAll() ) do
			if (v:Alive() and !v:IsRagdolled() and v:GetMoveType() == MOVETYPE_WALK) then
				if ( v:HasInitialized() ) then
					if ( thermalVision or (v:GetMaterial() == "sprites/heatwave"
					and v:GetVelocity():Length() > 1) ) then
						local material = self.heatwaveMaterial;
						
						if (thermalVision) then
							material = self.shinyMaterial;
						end;
						
						render.SuppressEngineLighting(true);
						render.SetColorModulation( unpack(modulation) );
						
						SetMaterialOverride(material);
							v:DrawModel();
						SetMaterialOverride(false)
						
						render.SetColorModulation(1, 1, 1);
						render.SuppressEngineLighting(false);
					end;
				end;
			end;
		end;
	cam.End3D();
	
	if ( !openAura:IsScreenFadedBlack() ) then
		local curTime = CurTime();
		
		if (self.flashEffect) then
			local timeLeft = math.Clamp( self.flashEffect[1] - curTime, 0, self.flashEffect[2] );
			local incrementer = 1 / self.flashEffect[2];
			
			if (timeLeft > 0) then
				local modify = {};
				
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
	end;
end;

-- Called when the local player's default color modify should be set.
function openAura.schema:PlayerSetDefaultColorModify(colorModify)
	-- if ( openAura:IsCharacterScreenOpen(true) ) then
		-- colorModify["$pp_colour_mulr"] = 25;
		-- colorModify["$pp_colour_mulg"] = 30;
		-- colorModify["$pp_colour_mulb"] = 45;
	-- elseif ( openAura.menu:GetOpen() ) then
		-- local faction = openAura.player:GetFaction(openAura.Client);
		
		-- if (faction == FACTION_YAKUZA) then
			-- colorModify["$pp_colour_mulb"] = 45;
		-- elseif (faction == FACTION_MAFIA) then
			-- colorModify["$pp_colour_mulr"] = 45;
		-- elseif (faction == FACTION_QAEDA) then
			-- colorModify["$pp_colour_mulg"] = 45;
		-- elseif (faction == FACTION_KINGS) then
			-- colorModify["$pp_colour_mulr"] = 45;
			-- colorModify["$pp_colour_mulg"] = 45;
		-- end;
	-- end;
end;

-- Called when the local player's color modify should be adjusted.
function openAura.schema:PlayerAdjustColorModify(colorModify)
	local interval = FrameTime() / 2;
	
	if (!self.colorModify) then
		self.colorModify = {
			brightness = colorModify["$pp_colour_brightness"],
			contrast = colorModify["$pp_colour_contrast"],
			color = colorModify["$pp_colour_colour"],
			mulr = colorModify["$pp_colour_mulr"],
			mulg = colorModify["$pp_colour_mulg"],
			mulb = colorModify["$pp_colour_mulb"]
		};
	end;
	
	if (self.thirdPersonAmount > 0) then
		colorModify["$pp_colour_contrast"] = 1.2;
		colorModify["$pp_colour_colour"] = 0.6;
	end;
	
	self.colorModify.brightness = math.Approach(self.colorModify.brightness, colorModify["$pp_colour_brightness"], interval);
	self.colorModify.contrast = math.Approach(self.colorModify.contrast, colorModify["$pp_colour_contrast"], interval);
	self.colorModify.color = math.Approach(self.colorModify.color, colorModify["$pp_colour_colour"], interval);
	self.colorModify.mulr = math.Approach(self.colorModify.mulr, colorModify["$pp_colour_mulr"], interval);
	self.colorModify.mulg = math.Approach(self.colorModify.mulg, colorModify["$pp_colour_mulg"], interval);
	self.colorModify.mulb = math.Approach(self.colorModify.mulb, colorModify["$pp_colour_mulb"], interval);
	
	colorModify["$pp_colour_brightness"] = self.colorModify.brightness;
	colorModify["$pp_colour_contrast"] = self.colorModify.contrast;
	colorModify["$pp_colour_colour"] = self.colorModify.color;
	colorModify["$pp_colour_mulr"] = self.colorModify.mulr;
	colorModify["$pp_colour_mulg"] = self.colorModify.mulg;
	colorModify["$pp_colour_mulb"] = self.colorModify.mulb;
end;

-- Called when the bars are needed.
function openAura.schema:GetBars(bars)
	local minEXP, maxEXP = self:GetEXP();
	
	if (self:GetLevel(openAura.Client) < 40) then
		if (!self.minEXP) then
			self.minEXP = minEXP;
		else
			self.minEXP = math.Approach(self.minEXP, minEXP, 1);
		end;
		
		bars:Add( "EXPERIENCE", Color(50, 255, 75, 255), "XP", self.minEXP, maxEXP, self.minEXP > (maxEXP * 0.9) );
	end;
end;

-- Called when the top bars should be destroyed.
function openAura.schema:DestroyBars(bars)
	local healthBar = bars:Get("HEALTH");
	local armorBar = bars:Get("ARMOR");
	
	if (healthBar) then healthBar.text = "HP"; end;
	if (armorBar) then armorBar.text = "AP"; end;
end;

-- Called just after the opaque renderables have been drawn.
function openAura.schema:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox)
	if (drawingSkybox) then
		return;
	end;
	
	if (openAura.Client:Alive() and self.thirdPersonAmount > 0) then
		local backgroundColor = openAura.option:GetColor("background");
		local dateTimeFont = openAura.option:GetFont("date_time_text");
		local colorWhite = openAura.option:GetColor("white");
		local eyeAngles = EyeAngles();
		local eyePos = EyePos();
		local angles = openAura.Client:GetRenderAngles();
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		openAura:OverrideMainFont(dateTimeFont);
			cam.Start3D(eyePos, eyeAngles);
				cam.Start3D2D(openAura.Client:GetShootPos() + Vector(0, 0, 40), angles, 0.15);
					local stamina = openAura.Client:GetSharedVar("stamina");
					local info = {
						width = 256,
						x = -256,
						y = 32
					};
					
					openAura:DrawInfo("STAMINA", info.x, info.y, Color(255, 255, 255, 255), nil, true);
					info.y = info.y + 32;
					
					openAura:DrawSimpleGradientBox(2, info.x - 4, info.y - 4, (8 * 50) + 8, 24, backgroundColor);
					
					for i = 1, 50 do
						if (stamina / 2 > i) then
							draw.RoundedBox( 2, info.x - 1, info.y - 1, 6, 18, _team.GetColor( openAura.Client:Team() ) );
							draw.RoundedBox( 2, info.x, info.y, 4, 16, _team.GetColor( openAura.Client:Team() ) );
						else
							draw.RoundedBox( 2, info.x - 1, info.y - 1, 6, 18, Color(50, 50, 50, 255) );
						end;
						
						info.x = info.x + 8;
					end;
					
					info.x = -256;
					info.y = info.y + 32;
					
					openAura:DrawBars(info, "3d");
				cam.End3D2D();
			cam.End3D();
		openAura:OverrideMainFont(false);
	end;
end;

-- Called when the local player attempts to see the top bars.
function openAura.schema:PlayerCanSeeBars(class)
	if (class == "tab") then
		return false;
	elseif (class == "top") then
		if (self.thirdPersonAmount > 0) then
			return false;
		else
			return true;
		end;
	elseif (class == "3d") then
		return true;
	end;
end;

-- Called when the foreground HUD should be painted.
function openAura.schema:HUDPaintForeground()
	local introTextSmallFont = openAura.option:GetFont("intro_text_small");
	local colorInformation = openAura.option:GetColor("information");
	local dateTimeFont = openAura.option:GetFont("date_time_text");
	local mainTextFont = openAura.option:GetFont("main_text");
	local colorWhite = openAura.option:GetColor("white");
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	if ( openAura.Client:Alive() ) then
		local curTime = CurTime();
		
		if (self.thirdPersonAmount == 0) then
			local displays = {
				{ "lvl", self:GetLevel(openAura.Client), {} },
				{ "drugs", openAura.player:GetCash(openAura.Client), {} },
				{ "resources", self:GetResources( openAura.player:GetFaction(openAura.Client) ), {} }
			};
			local height = 0;
			local width = 0;
			
			for k, v in ipairs(displays) do
				local displayText = tostring( openAura:ZeroNumberToDigits(v[2], 3) );
				local smallW, smallH = openAura:GetCachedTextSize( mainTextFont, v[1] );
				local bigW, bigH = openAura:GetCachedTextSize(introTextSmallFont, displayText);
				
				v[3].smallH = smallH;
				v[3].smallW = smallW;
				v[3].bigH = bigH;
				v[3].bigW = bigW;
				
				if (k != #displays) then
					width = width + smallW + bigW + 64;
				else
					width = width + smallW + bigW;
				end;
				
				if (bigH > height) then
					height = bigH;
				end;
			end;
			
			local x = (ScrW() / 2) - (width / 2);
			local y = ScrH() - height - 8;
			
			for k, v in ipairs(displays) do
				openAura:DrawSimpleText(v[1], x, y, colorInformation);
				x = x + v[3].smallW + 1;
				
				openAura:OverrideMainFont(introTextSmallFont);
					openAura:DrawSimpleText(v[2], x, y - (v[3].smallH / 2), colorWhite);
					x = x + v[3].bigW + 64;
				openAura:OverrideMainFont(false);
			end;
			
			for k, v in ipairs(self.damageCracks) do
				local alpha = 255;
				
				if (v.fadeOut) then
					alpha = math.Clap( (255 / 3) * (v.fadeOut - curTime), 0, 255 );
					
					if (curTime >= v.fadeOut) then
						table.remove(self.damageCracks, k);
					end;
				elseif (openAura.Client:Health() > v.health) then
					v.fadeOut = curTime + 3;
				end;
				
				surface.SetDrawColor(255, 255, 255, alpha);
				surface.SetTexture(self.crackTexture);
				surface.DrawTexturedRect(v.x, v.y, 256, 256);
			end;
		end;
		
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
	
	if (#self.killNotices > 0) then
		local curTime = UnPredictedCurTime();
		local x = 8;
		local y = ScrH() * 0.2;
		
		for k, v in ipairs(self.killNotices) do
			local fadeInTimeLeft = math.max(v.fadeIn - curTime, 0);
			local fadeUpTimeLeft = v.fadeUp - curTime;
			local textWidth, textHeight = openAura:GetCachedTextSize(mainTextFont, v.text);
			local minusX = (textWidth + 8) * (1 * fadeInTimeLeft);
			local minusY = 0;
			local alpha = 255;
			
			if (fadeUpTimeLeft < 0) then
				local timeSince = math.min(math.abs(fadeUpTimeLeft), 3);
				
				minusY = ( (textHeight * 2) / 3 ) * timeSince;
				alpha = (255 / 3) * (3 - timeSince);
			end;
			
			openAura:DrawInfo(v.text, x - minusX, y - minusY, colorWhite, alpha, true);
			
			y = y + textHeight + 4;
		end;
	end;
end;

-- Called to get the screen text info.
function openAura.schema:GetScreenTextInfo()
	local blackFadeAlpha = openAura:GetBlackFadeAlpha();
	
	if (!openAura.Client:Alive() and self.deathType) then
		return {
			alpha = blackFadeAlpha,
			title = "YOU WERE KILLED BY "..self.deathName,
			text = "the cause of death was "..self.deathType
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
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;