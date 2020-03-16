--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local Severance = Severance;

function Severance:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when the menu's items should be destroyed.
function Severance:MenuItemsDestroy(menuItems)
	if (!Clockwork.player:HasFlags(Clockwork.Client, "y")) then
		menuItems:Destroy(Clockwork.option:GetKey("name_business"));
	end;
end;

-- Called each frame.
function Severance:Think()
	local currentMap = game.GetMap();
	local validMaps = {
		["md_venetianredux_b2"] = Vector(-3985.6904, 1397.9601, 604.0056),
		["rp_necro_urban_v3b"] = Vector(3813.7615, 172.4379, 443.5957),
		["rp_necro_urban_v2"] = Vector(3813.7615, 172.4379, 443.5957),
		["rp_necro_urban_v1"] = Vector(3813.7615, 172.4379, 443.5957)
	};
	
	if (validMaps[currentMap] and Clockwork.kernel:IsChoosingCharacter()) then
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

-- Called when Clockwork has initialized.
function Severance:ClockworkInitialized()
	CW_CONVAR_HALOS = Clockwork.kernel:CreateClientConVar("cwRenderHalos", 1, true, true);

	for k, v in pairs(Clockwork.item:GetAll()) do
		if (!v("isBaseItem") and !v("isRareItem")) then
			v.business = true;
			v.access = "y";
			v.batch = 1;
		end;
	end;
end;

-- Called when the local player's character screen faction is needed.
function Severance:GetPlayerCharacterScreenFaction(character)
	if (character.customClass and character.customClass != "") then
		return character.customClass;
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function Severance:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (entity:GetClass() == "prop_physics") then
		local physDesc = entity:GetNetworkedString("PhysDesc");
		
		if (physDesc != "") then
			info.y = Clockwork.kernel:DrawInfo(physDesc, info.x, info.y,
				colorWhite, info.alpha);
		end;
	end;
end;

-- Called when the HUD should be painted.
function Severance:HUDPaint()
	if (!Clockwork.kernel:IsChoosingCharacter()) then
		if (Clockwork.Client:GetNetworkedVar("GhostMode", true)) then
			draw.SimpleText("Find a spawn location!", "sev_MainText", ScrW() / 2 - 70, ScrH() - 130, Color(0, 145, 255, 255), TEXT_ALIGN_CENTER);
			draw.SimpleText("Press 'RELOAD' to spawn in!", "sev_MainText", ScrW() / 2 - 70, ScrH() - 80, Color(0, 145, 255, 255), TEXT_ALIGN_CENTER);
		end;
	end;
end;

-- Called when the top bars are needed.
function Severance:GetBars(bars)
	--[[-------------------------------------------------------------------------
	TODO: Hide bars when Hunger/Thirst/Energy is >50%
	---------------------------------------------------------------------------]]
	local Hunger = Clockwork.Client:GetSharedVar("Hunger");

	if (!self.Hunger) then
		self.Hunger = Hunger;
	else
		self.Hunger = math.Approach(self.Hunger, Hunger, 1);
	end;

	bars:Add("Hunger", Color(230, 180, 0, 255), "HUNGER", self.Hunger, 100, self.Hunger < 20);

	local Thirst = Clockwork.Client:GetSharedVar("Thirst");

	if (!self.Thirst) then
		self.Thirst = Thirst;
	else
		self.Thirst = math.Approach(self.Thirst, Thirst, 1);
	end;

	bars:Add("Thirst", Color(50, 50, 175, 255), "THIRST", self.Thirst, 100, self.Thirst < 20);

	local Energy = Clockwork.Client:GetSharedVar("Energy");

	if (!self.Energy) then
		self.Energy = Energy;
	else
		self.Energy = math.Approach(self.Energy, Energy, 1);
	end;

	bars:Add("Energy", Color(100, 100, 100, 255), "ENERGY", self.Energy, 100, self.Energy < 20);
end;

-- Called when a text entry has gotten focus.
function Severance:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel;
end;

-- Called when a text entry has lost focus.
function Severance:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil;
end;

-- Called when screen space effects should be rendered.
function Severance:RenderScreenspaceEffects()
	local modify = {};
	
	if (!Clockwork.kernel:IsScreenFadedBlack()) then
		local curTime = CurTime();
		
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
				
				if (!self.flashEffect[3]) then
					DrawMotionBlur(1 - (incrementer * timeLeft), incrementer * timeLeft, self.flashEffect[2]);
				end;
			end;
		end;
		
		if (self:PlayerIsZombie(Clockwork.Client)) then
			local colormod = {}		
			colormod[ "$pp_colour_contrast" ] = 1.5
			colormod[ "$pp_colour_addr" ] = 255 / 2550
			colormod[ "$pp_colour_addg" ] = 70 / 2550
			colormod[ "$pp_colour_addb" ] = 70 / 2550

			if (Clockwork.Client:GetNetworkedVar("GhostMode", true)) then
				colormod[ "$pp_colour_contrast" ] = 1.5
				colormod[ "$pp_colour_addr" ] = 0 / 2550
				colormod[ "$pp_colour_addg" ] = 230 / 2550
				colormod[ "$pp_colour_addb" ] = 255 / 2550
			end;

			DrawColorModify(colormod)		
		end;	
	end;
end;

-- Called before halos need to be rendered.
function Severance:PreDrawHalos()
	if (CW_CONVAR_HALOS:GetInt() == 1) then
		if (self:PlayerIsZombie(Clockwork.Client)) then
			local halo = halo;
			local Color = Color;
			local players = _player.GetAll();
			local zombies = ents.FindByClass("cw_zombie_nextbot");
			local haloColor = Color(0, 200, 255);

			for k, v in ipairs(players) do
				if (Clockwork.Client:GetPos():Distance(v:GetPos()) <= 1000) then
					if (v:IsValid() and v:GetMoveType() == MOVETYPE_WALK) then			
						if (self:PlayerIsZombie(v)) then
							haloColor = Color(255, 150, 0);
						end;

						halo.Add({v}, haloColor, 1, 1, 1, true, true);
					end;
				end;
			end;

			for k, v in ipairs(zombies) do
				if (Clockwork.Client:GetPos():Distance(v:GetPos()) <= 1000) then
					if (v:IsValid()) then			
						haloColor = Color(255, 150, 0);

						halo.Add({v}, haloColor, 1, 1, 1, true, true);
					end;
				end;
			end;
		end;
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function Severance:PlayerAdjustMotionBlurs(motionBlurs)
	if (!Clockwork.kernel:IsScreenFadedBlack()) then
		local curTime = CurTime();
		
		if (self.flashEffect and self.flashEffect[3]) then
			local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2]);
			local incrementer = 1 / self.flashEffect[2];
			
			if (timeLeft > 0) then
				motionBlurs.blurTable["flash"] = 1 - (incrementer * timeLeft);
			end;
		end;
	end;
end;

-- Called when the cinematic intro info is needed.
function Severance:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self:GetAuthor()..".",
		title = Clockwork.config:Get("intro_text_big"):Get(),
		text = Clockwork.config:Get("intro_text_small"):Get()
	};
end;

-- Called when the character background blur should be drawn.
function Severance:ShouldDrawCharacterBackgroundBlur()
	return false;
end;

-- Called when the local player's default color modify should be set.
function Severance:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.03;
	colorModify["$pp_colour_contrast"] = 1.1;
	colorModify["$pp_colour_colour"] = 0.4;
end;

-- Called when an entity's menu options are needed.
function Severance:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "prop_ragdoll") then
		local player = Clockwork.entity:GetPlayer(entity);
		
		if (!player or !player:Alive()) then
			options["Loot"] = "cwCorpseLoot";
		end;
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

-- Called when a player's scoreboard options are needed.
function Severance:GetPlayerScoreboardOptions(player, options, menu)
	if (Clockwork.command:FindByID("CharPermaKill")) then
		if (Clockwork.player:HasFlags(Clockwork.Client, Clockwork.command:FindByID("CharPermaKill").access)) then
			options["Perma-Kill"] = function()
				RunConsoleCommand("cwCmd", "CharPermaKill", player:Name());
			end;
		end;
	end;
end;

-- Called when the target's status should be drawn.
function Severance:DrawTargetPlayerStatus(target, alpha, x, y)
	local colorInformation = Clockwork.option:GetColor("information");
	local thirdPerson = "him";
	local mainStatus;
	local untieText;
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
		elseif (Clockwork.player:GetAction(Clockwork.Client) == "tie") then
			mainStatus = gender.." is being tied up.";
		end;
		
		if (mainStatus) then
			y = Clockwork.kernel:DrawInfo(Clockwork.kernel:ParseData(mainStatus),
				x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called when the foreground HUD should be painted.
function Severance:HUDPaintForeground()
	local curTime = CurTime();
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	if (Clockwork.Client:Alive() and Clockwork.Client:GetRagdollState() != RAGDOLL_KNOCKEDOUT) then
		if (self.stunEffects) then
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp((255 / v[2]) * (v[1] - curTime), 0, 255);
				
				if (alpha == 0) then
					self.stunEffects[k] = nil;
				elseif (!v[3]) then
					draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha));
				else
					v[3](alpha);
				end;
			end;
		end;
	end;
end;

-- Called to get the screen text info.
function Severance:GetScreenTextInfo()
	local blackFadeAlpha = Clockwork.kernel:GetBlackFadeAlpha();
	
	if (Clockwork.Client:GetSharedVar("PermaKilled")) then
		return {
			alpha = blackFadeAlpha,
			title = "THIS CHARACTER IS PERMANENTLY KILLED",
			text = "Go to the character menu to make a new one."
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
function Severance:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker)) then
		if (info.data.anon) then
			info.name = "Somebody";
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function Severance:GetPostProgressBarInfo()
	if (Clockwork.Client:Alive()) then
		local action, percentage = Clockwork.player:GetAction(Clockwork.Client, true);
		
		if (action == "die") then
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;