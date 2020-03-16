--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local OUTLINE_MATERIAL = Material("white_outline");

-- Called every tick.
function Clockwork.schema:Tick()
	if (!IsValid(Clockwork.Client) or !Clockwork.Client:HasInitialized()
	or type(self.hotkeyItems) != "table") then
		return;
	end;
	
	local bRemovedOne = false;
	local inventory = Clockwork.inventory:GetClient();
	local x = 24;
	local y = ScrH() - 56;
	
	for k, v in pairs(self.hotkeyItems) do
		local itemTable = Clockwork.inventory:FindItemByName(
			inventory, v.uniqueID, v.name
		);
		
		if (itemTable) then
			if (!IsValid(v.panel)) then
				v.panel = self:CreateHotkeySpawnIcon(itemTable);
			end;
			
			if (!Clockwork.Client:Alive() or Clockwork.Client:IsRagdolled()) then
				v.panel:SetVisible(false);
			else
				v.panel:SetVisible(true);
			end;
			
			v.panel:SetHotkeyData(v);
			v.panel:SetItemTable(itemTable);
			v.panel:SetColor(itemTable("color"));
			v.panel:SetModel(Clockwork.item:GetIconInfo(itemTable));
			v.panel:SetMarkupToolTip(Clockwork.item:GetMarkupToolTip(itemTable));
			v.panel:SetPos(x, y); x = x + 40;
		else
			table.remove(self.hotkeyItems, k);
			bRemovedOne = true;
			
			if (IsValid(v.panel)) then
				v.panel:Remove();
			end;
		end;
	end;
	
	if (bRemovedOne) then
		self:SaveHotkeys();
	end;
end;

-- Called when the HUD should be painted.
function Clockwork.schema:HUDPaint()
	local colorWhite = Clockwork.option:GetColor("white");
	local curTime = CurTime();
	
	if (Clockwork.Client:HasInitialized() and type(self.hotkeyItems) == "table") then
		local x = 16;
		local y = ScrH() - 64;
		
		draw.RoundedBox(4, x, y, 408, 48, Color(0, 0, 0, 100));
		
		for i = 0, 9 do
			local hotkeyData = self.hotkeyItems[i + 1];
			local boxX = x + (40 * i) + 8;
			local boxY = y + 8;
			
			if (hotkeyData) then
				local itemsList = Clockwork.inventory:FindItemsByName(
					Clockwork.inventory:GetClient(), hotkeyData.uniqueID,
					hotkeyData.name
				);
				
				Clockwork:OverrideMainFont("DefaultLarge");
					Clockwork:DrawInfo(
						tostring(#itemsList), boxX + 16, boxY - 28, colorWhite, 255
					);
				Clockwork:OverrideMainFont(false);
			end;
			
			draw.RoundedBox(4, boxX, boxY, 32, 32, Color(255, 255, 255, 50));
		end;
	end;
	
	if (Clockwork.Client:GetSharedVar("IsTied")) then
		local scrH = ScrH();
		local scrW = ScrW();
		
		local y = Clockwork:DrawInfo("YOU DROP EVERYTHING ON YOU IF YOU LEAVE WHILE TIED!", scrW, scrH, colorWhite, 255, true, function(x, y, width, height)
			return x - width - 8, y - (height * 2) - 16;
		end);
		
		Clockwork:DrawInfo("THIS INCLUDES ANY CLOTHING YOU ARE WEARING!", scrW, y, colorWhite, 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	else
		local nextDC = Clockwork.Client:GetSharedVar("NextQuit");
		local scrH = ScrH();
		local scrW = ScrW();
		
		if (nextDC > curTime) then
			local y = Clockwork:DrawInfo("YOU DROP EVERYTHING ON YOU IF YOU LEAVE WITHIN "..math.ceil(nextDC - curTime).." SECOND(s)!", scrW, scrH, colorWhite, 255, true, function(x, y, width, height)
				return x - width - 8, y - (height * 2) - 16;
			end);
			
			Clockwork:DrawInfo("THIS INCLUDES ANY CLOTHING YOU ARE WEARING!", scrW, y, colorWhite, 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		end;
	end;
end;

-- Called when the chat box position is needed.
function Clockwork:GetChatBoxPosition()
	return {x = 24, y = ScrH() - 128};
end;

-- Called when a cash entity is drawn.
function Clockwork.schema:CashEntityDraw(entity)
	self:GeneratorEntityDraw(entity, Color(255, 255, 255, 255));
end;

-- Called when a shipment entity is drawn.
function Clockwork.schema:ShipmentEntityDraw(entity)
	self:GeneratorEntityDraw(entity, Color(255, 255, 255, 255));
end;

-- Called when the local player's character has initialized.
function Clockwork.schema:PlayerCharacterInitialized(iCharacterKey)
	self:LoadHotkeys(iCharacterKey);
end;

-- Called when a generator entity is drawn.
function Clockwork.schema:GeneratorEntityDraw(entity, forceColor)
	local curTime = CurTime();
	local sineWave = math.max(math.abs(math.sin(curTime) * 32), 16);
	local r, g, b, a = entity:GetColor();
	local outlineColor = forceColor or Color(255, 255, 255, 255);
	
	render.SuppressEngineLighting(true);
	render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
	
	render.SetAmbientLight(1, 1, 1);
	render.SetBlend(outlineColor.a / 255);
	entity:SetModelScale(Vector() * (1.025 + (sineWave / 320)));
	
	SetMaterialOverride(OUTLINE_MATERIAL);
		entity:DrawModel();
	SetMaterialOverride(nil);
	entity:SetModelScale(Vector());
	
	render.SetBlend(1);
	render.SetColorModulation(r / 255, g / 255, b / 255);
	render.SuppressEngineLighting(false);
end;

-- Called when an item entity is drawn.
function Clockwork.schema:ItemEntityDraw(itemTable, entity)
	local curTime = CurTime();
	local sineWave = math.max(math.abs(math.sin(curTime) * 32), 16);
	local r, g, b, a = entity:GetColor();
	local outlineColor = itemTable("color") or Color(255, 255, 255, 255);
	
	cam.Start3D(EyePos(), EyeAngles());
		render.SuppressEngineLighting(true);
		render.SetColorModulation(outlineColor.r / 255, outlineColor.g / 255, outlineColor.b / 255);
		
		render.SetAmbientLight(1, 1, 1);
		entity:SetModelScale(Vector() * (1.025 + (sineWave / 320)));
		
		SetMaterialOverride(OUTLINE_MATERIAL);
			entity:DrawModel();
		SetMaterialOverride(nil);
		entity:SetModelScale(Vector());
		
		render.SetColorModulation(r / 255, g / 255, b / 255);
		render.SuppressEngineLighting(false);
	cam.End3D();
end;

-- Called just after a player is drawn.
function Clockwork.schema:PostPlayerDraw(player)
	if (!DO_NOT_DRAW) then
		DO_NOT_DRAW = true;
			if (player:GetMaterial() != "sprites/heatwave" and player:GetMoveType() == MOVETYPE_WALK
			and self.targetOutlines[player]) then
				local alpha = math.Clamp((255 / 60) * (self.targetOutlines[player] - CurTime()), 0, 255);
				
				if (alpha > 0) then
					self:DrawBasicOutline(player, Color(255, 50, 50, alpha));
				end;
			end;
		DO_NOT_DRAW = false;
	end;
end;

-- Called when the target player's text is needed.
function Clockwork.schema:GetTargetPlayerText(player, targetPlayerText)
	local groupName = player:GetSharedVar("Group");
	
	if (groupName != "") then
		targetPlayerText:Add("GUILD", "A member of \""..groupName.."\".", Color(200, 200, 200, 255));
	end;
end;

-- Called when a player's scoreboard class is needed.
function Clockwork.schema:GetPlayerScoreboardClass(player)
	local groupName = player:GetSharedVar("Group");
	
	if (groupName != "") then
		return groupName;
	end;
end;

-- Called when the local player's color modify should be adjusted.
function Clockwork.schema:PlayerAdjustColorModify(colorModify)
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
	
	if (self.suppressEffect) then
		local curTime = CurTime();
		local timeLeft = self.suppressEffect - curTime;
		local curColor = colorModify["$pp_colour_colour"];
		local curContrast = colorModify["$pp_colour_contrast"];
		
		if (timeLeft > 0) then
			colorModify["$pp_colour_colour"] = curColor - ((curColor / 10) * timeLeft);
			colorModify["$pp_colour_contrast"] = curContrast + ((0.5 / 10) * timeLeft);
		end;
		
		interval = (interval * 3);
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

-- Called when the local player attempts to see the top bars.
function Clockwork.schema:PlayerCanSeeBars(class)
	if (class == "top") then
		if (self.thirdPersonAmount > 0) then
			return false;
		else
			return true;
		end;
	elseif (class == "tab") then
		return false;
	elseif (class == "3d") then
		return true;
	end;
end;

-- Called when the local player should be drawn.
function Clockwork.schema:ShouldDrawLocalPlayer()
	if ((Clockwork.Client:IsRunning() and !Clockwork.player:IsNoClipping(Clockwork.Client))
	and (!self.overrideThirdPerson or UnPredictedCurTime() >= self.overrideThirdPerson)) then
		self.thirdPersonAmount = math.Approach(self.thirdPersonAmount, 1, FrameTime() / 10);
	else
		self.thirdPersonAmount = math.Approach(self.thirdPersonAmount, 0, FrameTime() / 10);
	end;
	
	if (self.thirdPersonAmount > 0) then
		return true;
	end;
end;

-- Called when the local player's item menu should be adjusted.
function Clockwork.schema:PlayerAdjustItemMenu(itemTable, menuPanel, itemFunctions)
	if (itemTable:IsBasedFrom("custom_weapon") or itemTable:IsBasedFrom("custom_clothes")) then
		menuPanel:AddOption("Repair", function()
			Clockwork:StartDataStream("RepairItem", Clockwork.item:GetSignature(itemTable));
		end);
		
		local durability = itemTable:GetData("Durability");
		local panel = menuPanel.Items[#menuPanel.Items];
		
		if (IsValid(panel)) then
			if (durability == 100) then
				panel:SetToolTip("This item already has full durability and does not need to be repaired.");
				return;
			end;
			
			local itemCost = itemTable("cost");
			local minPrice = itemCost * 0.1;
			local maxPrice = itemCost * 0.6;
			local repairCost = math.max((maxPrice / 100) * (100 - durability), minPrice);
			local currentCash = Clockwork.player:GetCash();
			
			if (currentCash < minPrice) then
				panel:SetToolTip("You need atleast "..FORMAT_CASH(minPrice, true).." to begin repairing this item.");
				return;
			end;
			
			if (currentCash < repairCost) then
				local newDurability = ((100 - durability) / repairCost) * currentCash;
				local newRepairCost = math.ceil((repairCost / (100 - durability)) * newDurability);
				panel:SetToolTip("You can repair this item to "..math.ceil(durability + newDurability).."% for "..FORMAT_CASH(newRepairCost, true)..".");
			else
				panel:SetToolTip("This item will cost you "..FORMAT_CASH(repairCost, true).." to fully repair.");
			end;
		end;
	end;
	
	if (#self.hotkeyItems < 10 and !HIDE_HOTKEY_OPTION) then
		for k, v in pairs(self.hotkeyItems) do
			if (v.uniqueID == itemTable("uniqueID")
			and v.name == itemTable("name")) then
				return;
			end;
		end;
		
		menuPanel:AddOption("Hotkey", function()
			Clockwork.schema:AddHotkey(itemTable);
		end);
	end;
end;

-- Called just after the translucent renderables have been drawn.
function Clockwork.schema:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox and Clockwork.Client:Alive() and self.thirdPersonAmount > 0) then
		local backgroundColor = Clockwork.option:GetColor("background");
		local dateTimeFont = Clockwork.option:GetFont("date_time_text");
		local colorWhite = Clockwork.option:GetColor("white");
		local eyeAngles = EyeAngles();
		local eyePos = EyePos();
		local angles = Clockwork.Client:GetRenderAngles();
		
		angles:RotateAroundAxis(angles:Forward(), 90);
		angles:RotateAroundAxis(angles:Right(), 90);
		
		Clockwork:OverrideMainFont(dateTimeFont);
			cam.Start3D(eyePos, eyeAngles);
				cam.Start3D2D(Clockwork.Client:GetShootPos() + Vector(0, 0, 40), angles, 0.15);
					local stamina = Clockwork.Client:GetSharedVar("Stamina");
					local info = {
						width = 256,
						x = -256,
						y = 32
					};
					
					Clockwork:DrawInfo("STAMINA", info.x, info.y, Color(255, 255, 255, 255), nil, true);
					info.y = info.y + 32;
					
					Clockwork:DrawSimpleGradientBox(2, info.x - 4, info.y - 4, (8 * 50) + 8, 24, backgroundColor);
					
					for i = 1, 50 do
						if (stamina / 2 > i) then
							draw.RoundedBox(2, info.x - 1, info.y - 1, 6, 18, _team.GetColor(Clockwork.Client:Team()));
							draw.RoundedBox(2, info.x, info.y, 4, 16, _team.GetColor(Clockwork.Client:Team()));
						else
							draw.RoundedBox(2, info.x - 1, info.y - 1, 6, 18, Color(50, 50, 50, 255));
						end;
						
						info.x = info.x + 8;
					end;
					
					info.x = -256;
					info.y = info.y + 32;
					
					Clockwork:DrawBars(info, "3d");
				cam.End3D2D();
			cam.End3D();
		Clockwork:OverrideMainFont(false);
	end;
end;

-- Called when an entity's menu options are needed.
function Clockwork.schema:GetEntityMenuOptions(entity, options)
	local mineTypes = {"cw_firemine", "cw_freezemine", "cw_explomine"};
	
	if (table.HasValue(mineTypes, entity:GetClass())) then
		options["Defuse"] = "cwMineDefuse";
	elseif (entity:GetClass() == "prop_ragdoll") then
		local player = Clockwork.entity:GetPlayer(entity);
		
		if (!player or !player:Alive()) then
			options["Loot"] = "cwCorpseLoot";
		end;
	elseif (entity:GetClass() == "cw_belongings") then
		options["Open"] = "cwBelongingsOpen";
	elseif (entity:GetClass() == "cw_breach") then
		options["Charge"] = "cwBreachCharge";
	elseif (entity:IsPlayer()) then
		local cashEnabled = Clockwork.config:Get("cash_enabled"):Get();
		local cashName = Clockwork.option:GetKey("name_cash");
		
		if (entity:GetSharedVar("IsTied")) then
			options["Untie"] = {
				Callback = function(entity) Clockwork:RunCommand("PlyUntie"); end,
				isArgTable = true
			};
		end;
		
		if (cashEnabled) then
			options["Give"] = {
				Callback = function(entity)
					Derma_StringRequest("Amount", "How much do you want to give them?", "0", function(text)
						Clockwork:RunCommand(string.gsub(cashName, "%s", "").."Give", entity:Name(), text);
					end);
				end,
				isArgTable = true,
				toolTip = "Give this character some "..string.lower(cashName).."."
			};
		end;
	end;
	
	if (Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (self.containers[model]) then
			options["Open"] = "cwContainerOpen";
		end;
	elseif (entity:GetClass() == "cw_safebox") then
		options["Open"] = "cwContainerOpen";
	end;
end;

-- Called when a player's footstep sound should be played.
function Clockwork.schema:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true;
end;

-- Called when a text entry has gotten focus.
function Clockwork.schema:OnTextEntryGetFocus(panel)
	self.textEntryFocused = panel;
end;

-- Called when a text entry has lost focus.
function Clockwork.schema:OnTextEntryLoseFocus(panel)
	self.textEntryFocused = nil;
end;

-- Called when the cinematic intro info is needed.
function Clockwork.schema:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self:GetAuthor()..".",
		title = Clockwork.config:Get("intro_text_big"):Get(),
		text = Clockwork.config:Get("intro_text_small"):Get()
	};
end;

-- Called when the target's status should be drawn.
function Clockwork.schema:DrawTargetPlayerStatus(target, alpha, x, y)
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
		
		if (target:GetSharedVar("IsTied")) then
			if (Clockwork.player:GetAction(Clockwork.Client) == "untie") then
				mainStatus = gender.. " is being untied.";
			else
				mainStatus = gender.." has been tied up.";
			end;
		elseif (Clockwork.player:GetAction(Clockwork.Client) == "chloro") then
			mainStatus = gender.." is having chloroform used on "..thirdPerson..".";
		elseif (Clockwork.player:GetAction(Clockwork.Client) == "tie") then
			mainStatus = gender.." is being tied up.";
		end;
		
		if (mainStatus) then
			y = Clockwork:DrawInfo(mainStatus, x, y, colorInformation, alpha);
		end;
		
		return y;
	end;
end;

-- Called to get whether a player's target ID should be drawn.
function Clockwork.schema:ShouldDrawPlayerTargetID(player)
	if (player:GetMaterial() == "sprites/heatwave") then
		return false;
	end;
end;

-- Called when screen space effects should be rendered.
function Clockwork.schema:RenderScreenspaceEffects()
	local modify = {};
	
	if (!Clockwork:IsScreenFadedBlack()) then
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
			else
				self.tearGassed = nil;
			end;
		end;
		
		local thermalVision = Clockwork.Client:GetSharedVar("Thermal");
		local modulation = {1, 1, 1};
		
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
		
		cam.Start3D(EyePos(), EyeAngles());
			for k, v in ipairs(_player.GetAll()) do
				if (v:Alive() and !v:IsRagdolled() and v:GetMoveType() == MOVETYPE_WALK) then
					if (v:HasInitialized()) then
						if (thermalVision or (v:GetMaterial() == "sprites/heatwave"
						and v:GetVelocity():Length() > 1)) then
							local material = self.heatwaveMaterial;
							
							if (thermalVision) then
								material = self.shinyMaterial;
							end;
							
							render.SuppressEngineLighting(true);
							render.SetColorModulation(unpack(modulation));
							
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
		
		if (self.thirdPersonAmount > 0) then
			render.UpdateScreenEffectTexture();
				self.fishEyeTexture:SetMaterialFloat("$envmap", 0);
				self.fishEyeTexture:SetMaterialFloat("$envmaptint",	0);
				self.fishEyeTexture:SetMaterialFloat("$refractamount", self.thirdPersonAmount / 16);
				self.fishEyeTexture:SetMaterialInt("$ignorez", 1);
			render.SetMaterial(self.fishEyeTexture);
			render.DrawScreenQuad();
		end;
	end;
end;

-- Called when the local player's motion blurs should be adjusted.
function Clockwork.schema:PlayerAdjustMotionBlurs(motionBlurs)
	if (self.suppressEffect) then
		local curTime = CurTime();
		local timeLeft = self.suppressEffect - curTime;
		
		if (timeLeft > 0) then
			motionBlurs.blurTable["Suppression"] = 1 - ((1 / 10) * timeLeft);
		end;
	end;
end;

-- Called when the calc view table should be adjusted.
function Clockwork.schema:CalcViewAdjustTable(view)
	if (self.thirdPersonAmount > 0 and !Clockwork.player:IsNoClipping(Clockwork.Client)) then
		local defaultOrigin = view.origin;
		local traceLine = nil;
		local position = Clockwork.Client:EyePos();
		local angles = Clockwork.Client:GetRenderAngles():Forward();
		
		if (defaultOrigin) then
			traceLine = util.TraceLine({
				start = position,
				endpos = position - (angles * (80 * self.thirdPersonAmount)),
				filter = Clockwork.Client
			});
			
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

-- Called when the foreground HUD should be painted.
function Clockwork.schema:HUDPaintForeground()
	local backgroundColor = Clockwork.option:GetColor("background");
	local dateTimeFont = Clockwork.option:GetFont("date_time_text");
	local colorWhite = Clockwork.option:GetColor("white");
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	if (Clockwork.Client:Alive()) then
		local curTime = CurTime();
		
		if (self.stunEffects) then
			for k, v in pairs(self.stunEffects) do
				local alpha = math.Clamp((255 / v[2]) * (v[1] - curTime), 0, 255);
				
				if (alpha != 0) then
					draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(255, 255, 255, alpha));
				else
					table.remove(self.stunEffects, k);
				end;
			end;
		end;
		
		if (self.shotEffect) then
			local alpha = math.Clamp((255 / self.shotEffect[2]) * (self.shotEffect[1] - curTime), 0, 255);
			local scrH = ScrH();
			local scrW = ScrW();
			
			if (alpha != 0) then
				draw.RoundedBox(0, 0, 0, scrW, scrH, Color(255, 50, 50, alpha));
			end;
		end;
		
		if (#self.damageNotify > 0) then
			Clockwork:OverrideMainFont(dateTimeFont);
				for k, v in ipairs(self.damageNotify) do
					local alpha = math.Clamp((255 / v.duration) * (v.endTime - curTime), 0, 255);
					
					if (alpha != 0) then
						local position = v.position:ToScreen();
						local canSee = Clockwork.player:CanSeePosition(Clockwork.Client, v.position);
						
						if (canSee) then
							Clockwork:DrawInfo(v.text, position.x, position.y - ((255 - alpha) / 2), v.color, alpha);
						end;
					else
						table.remove(self.damageNotify, k);
					end;
				end;
			Clockwork:OverrideMainFont(false);
		end;
	end;
end;

-- Called to get the screen text info.
function Clockwork.schema:GetScreenTextInfo()
	local blackFadeAlpha = Clockwork:GetBlackFadeAlpha();
	
	if (!Clockwork.Client:Alive() and self.deathType) then
		return {
			alpha = blackFadeAlpha,
			title = "YOU WERE KILLED BY "..self.deathType,
			text = "It probably isn't random, you just don't know the reason."
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
	elseif (Clockwork.Client:GetSharedVar("IsTied")) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "YOU HAVE BEEN TIED UP"
		};
	end;
end;

-- Called when the chat box info should be adjusted.
function Clockwork.schema:ChatBoxAdjustInfo(info)
	if (IsValid(info.speaker)) then
		if (info.data.anon) then
			info.name = "Somebody";
		end;
	end;
end;

-- Called when the post progress bar info is needed.
function Clockwork.schema:GetPostProgressBarInfo()
	if (Clockwork.Client:Alive()) then
		local action, percentage = Clockwork.player:GetAction(Clockwork.Client, true);
		
		if (action == "die") then
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		elseif (action == "chloroform") then
			return {text = "You are using chloroform on somebody.", percentage = percentage, flash = percentage > 75};
		elseif (action == "defuse") then
			return {text = "You are defusing a landmine.", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function Clockwork.schema:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (Clockwork.entity:IsPhysicsEntity(entity)) then
		local model = string.lower(entity:GetModel());
		
		if (self.containers[model]) then
			info.y = Clockwork:DrawInfo(self.containers[model][2], info.x, info.y, colorTargetID, info.alpha);
			
			if (entity:GetNetworkedString("Name") != "") then
				info.y = Clockwork:DrawInfo(entity:GetNetworkedString("Name"), info.x, info.y, colorWhite, info.alpha);
			else
				info.y = Clockwork:DrawInfo("It can temporarily hold stuff.", info.x, info.y, colorWhite, info.alpha);
			end;
		end;
	elseif (entity:GetClass() == "cw_safebox") then
		info.y = Clockwork:DrawInfo("Safebox", info.x, info.y, colorTargetID, info.alpha);
		info.y = Clockwork:DrawInfo("It can permanently hold stuff.", info.x, info.y, colorWhite, info.alpha);
	end;
end;

-- Called when the local player's storage is rebuilt.
function Clockwork.schema:PlayerStorageRebuilt(panel, categories)
	if (panel.storageType == "Container") then
		local entity = Clockwork.storage:GetEntity();
		
		if (IsValid(entity) and entity.cwMessage) then
			local messageForm = vgui.Create("DForm", panel);
			local helpText = messageForm:Help(entity.cwMessage);
			
			messageForm:SetPadding(5);
			messageForm:SetName("Message");
			helpText:SetFont("Default");
			
			panel:AddItem(messageForm);
		end;
	end;
end;