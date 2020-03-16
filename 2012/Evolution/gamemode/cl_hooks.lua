--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local OUTLINE_MATERIAL = Material("white_outline");

-- Called every tick.
function Schema:Tick()
	if (!IsValid(Clockwork.Client) or !Clockwork.Client:HasInitialized()
	or type(self.hotkeyItems) != "table") then
		return;
	end;
	
	local bRemovedOne = false;
	local inventory = Clockwork.inventory:GetClient();
	local x = 24;
	local y = ScrH() - 72;
	
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
	
	--[[ If we removed a hotkey, then we want to save them again. --]]
	if (bRemovedOne) then self:SaveHotkeys(); end;
	
	--[[
		We're finding all the doors and vehicles that the local client
		owns here, and caching them so we don't have to loop through
		unneccessary ones every time we draw!
	--]]
	
	if (!self.nextFindDoors or CurTime() >= self.nextFindDoors) then
		self.nextFindDoors = CurTime() + 2;
		self.ownedDoors = {};
		
		for k, v in ipairs(ents.FindByClass("prop_door_rotating")) do
			if (Clockwork.entity:GetOwner(v) == Clockwork.Client) then
				self.ownedDoors[#self.ownedDoors + 1] = v;
			end;
		end;
	end;
	
	if (!self.nextFindVehicles or CurTime() >= self.nextFindVehicles) then
		self.nextFindVehicles = CurTime() + 2;
		self.ownedVehicles = {};
		
		for k, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
			if (Clockwork.entity:GetOwner(v) == Clockwork.Client) then
				self.ownedVehicles[#self.ownedVehicles + 1] = v;
			end;
		end;
	end;
end;

-- Called when the bars are needed.
function Schema:GetBars(bars)
	local stamina = Clockwork.Client:GetSharedVar("Stamina");
	
	if (stamina <= 90 and self.thirdPersonAmount == 0) then
		bars:Add("STAMINA", Color(50, 175, 50, 255), "", stamina, 100, stamina < 10);
	end;
end;

-- Called when the HUD should be painted.
function Schema:HUDPaint()
	local colorWhite = Clockwork.option:GetColor("white");
	
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
		
		if (nextDC > CurTime()) then
			local y = Clockwork:DrawInfo("YOU DROP EVERYTHING ON YOU IF YOU LEAVE WITHIN "..math.ceil(nextDC - CurTime()).." SECOND(s)!", scrW, scrH, colorWhite, 255, true, function(x, y, width, height)
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
	return {x = 24, y = ScrH() - 144};
end;

-- Called when a cash entity is drawn.
function Schema:CashEntityDraw(entity)
	Clockwork.outline:RenderFromFade(entity, Color(255, 255, 255, 255), 1024);
end;

-- Called when a shipment entity is drawn.
function Schema:ShipmentEntityDraw(entity)
	Clockwork.outline:RenderFromFade(entity, Color(255, 255, 255, 255), 1024);
end;

-- Called when the local player's character has initialized.
function Schema:PlayerCharacterInitialized(iCharacterKey)
	self:LoadHotkeys(iCharacterKey);
end;

-- Called when a generator entity is drawn.
function Schema:GeneratorEntityDraw(entity, forceColor)
	local outlineColor = forceColor or Color(255, 255, 255, 255);
	
	if (!forceColor and entity:GetNetworkedInt("Cash") > 0) then
		outlineColor = Color(75, 255, 75, 255);
	end;
	
	Clockwork.outline:RenderFromFade(entity, outlineColor, 1024);
end;

-- Called when an item entity is drawn.
function Schema:ItemEntityDraw(itemTable, entity)
	Clockwork.outline:RenderFromFade(
		entity, itemTable("color") or Color(255, 255, 255, 255), 1024
	);
end;

-- Called when a gear entity is drawn.
function Schema:GearEntityDraw(entity)
	local itemTable = entity:GetItemTable();
	local itemRarity = itemTable:GetData("Rarity");
	
	if (itemRarity and itemRarity > 0) then
		Clockwork.outline:RenderFromFade(
			entity, itemTable("color") or Color(255, 255, 255, 255), 1024
		);
	end;
	
	entity:DrawModel();
	
	--[[
		Are we kevlar? If so, draw an overlay of the damaged
		kevlar over the original model. This gives the effect
		of being damaged.
	--]]
	if (itemTable("uniqueID") == "kevlar_vest") then
		SetMaterialOverride(Material("models/kevlarvest/kevlarshot"));
			render.SetBlend(
				(1 / 200) * (200 - itemTable:GetData("Armor"))
			);
			entity:DrawModel();
			render.SetBlend(1);
		SetMaterialOverride(false);
	end;
	
	return false;
end;

-- Called just before a player is drawn.
function Schema:PrePlayerDraw(player)
	if (player:GetMaterial() == "sprites/heatwave"
	and !player.cwForceDrawAlways) then
		return true;
	end;
end;

-- Called just after a player is drawn.
function Schema:PostPlayerDraw(player)
	if (DO_NOT_DRAW) then
		return;
	end;
	
	DO_NOT_DRAW = true;
	
	if (player:GetMaterial() != "sprites/heatwave"
	and player:GetMoveType() == MOVETYPE_WALK) then
		if (self.targetOutlines[player]) then
			local alpha = math.Clamp((255 / 60) * (
				self.targetOutlines[player] - CurTime()), 0, 255
			);
			
			if (alpha > 0) then
				Clockwork.outline:RenderFromFade(
					player, Color(255, 50, 50, alpha), nil, true
				);
			end;
		else
			local alpha = 0;
			
			if (IsValid(player:GetSharedVar("SafeZone"))) then
				alpha = 255;
			end;
			
			if (alpha > 0) then
				Clockwork.outline:RenderFromFade(
					player, Color(50, 255, 50, alpha), 1024, true
				);
			end;
		end;
	end;
	
	DO_NOT_DRAW = nil;
end;

-- Called when the target player's text is needed.
function Schema:GetTargetPlayerText(player, targetPlayerText)
	local groupName = player:GetSharedVar("Group");
	
	if (groupName != "") then
		targetPlayerText:Add("GUILD", "A member of \""..groupName.."\".", Color(200, 200, 200, 255));
	end;
end;

-- Called when a player's scoreboard class is needed.
function Schema:GetPlayerScoreboardClass(player)
	local groupName = player:GetSharedVar("Group");
	
	if (groupName != "") then
		return groupName;
	end;
end;

-- Called just after the date time box is drawn.
function Schema:PostDrawDateTimeBox(info)
	if (!Clockwork:IsInfoMenuOpen()) then return; end;
	
	local foregroundColor = Clockwork.option:GetColor("foreground");
	local menuTextTiny = Clockwork.option:GetFont("menu_text_tiny");
	local bIsThirsty = Clockwork.Client:GetSharedVar("Thirsty");
	local bIsHungry = Clockwork.Client:GetSharedVar("Hungry");
	local colorWhite = Clockwork.option:GetColor("white");
	local realWidth = 0;
	
	if (bIsThirsty or bIsHungry) then
		info.y = info.y + 8;
	end;
	
	if (bIsThirsty) then
		info:DrawText(">> THIRSTY", Color(255, 185, 64, 255), false, menuTextTiny);
		info:DrawText("You will not regenerate stamina.", colorWhite);
	end;
	
	if (bIsHungry) then
		info:DrawText(">> HUNGRY", Color(255, 185, 64, 255), false, menuTextTiny);
		info:DrawText("You will not regenerate health.", colorWhite);
	end;
	
	if (bIsThirsty or bIsHungry) then
		info.y = info.y + 8;
	end;
end;

-- Called when the scoreboard's class players should be sorted.
function Schema:ScoreboardSortClassPlayers(class, a, b)
	return a:GetSharedVar("Rank") > b:GetSharedVar("Rank");
end;

-- Called when an entity is created.
function Schema:OnEntityCreated(entity)
	if (!entity:IsPlayer()) then return; end;
	
	Clockwork:RegisterNetworkProxy(entity, "SafeZone", function(entity, name, oldValue, newValue)
		if (!IsValid(newValue) or Clockwork.Client != entity) then return; end;
		
		--[[ A nice little effect when we enter a Safe Zone. --]]
		local cwAreaDisplays = Clockwork.plugin:FindByID("Area Displays");
		
		if (cwAreaDisplays) then
			cwAreaDisplays:AddAreaDisplayDisplay(
				{name = newValue:GetNetworkedString("Name")..", %t."}
			);
		end;
	end);
	
	Clockwork:RegisterNetworkProxy(entity, "Group", function(entity, name, oldValue, newValue)
		local myGroupName = Clockwork.Client:GetSharedVar("Group");
		
		Clockwork:OnNextFrame("Group", function()
			if (Clockwork.menu:IsPanelActive(self.groupPanel)) then
				if (newValue != myGroupName and oldValue == myGroupName) then
					self.groupPanel:Rebuild();
				elseif (oldValue == myGroupName and newValue != myGroupName) then
					self.groupPanel:Rebuild();
				end;
			end;
		end);
	end);
	
	Clockwork:RegisterNetworkProxy(entity, "Rank", function(entity, name, oldValue, newValue)
		local myGroupRank = Clockwork.Client:GetSharedVar("Rank");
		
		Clockwork:OnNextFrame("Rank", function()
			local myGroupName = Clockwork.Client:GetSharedVar("Group");
			
			if (Clockwork.menu:IsPanelActive(self.groupPanel)
			and entity:GetSharedVar("Group") == myGroupName) then
				self.groupPanel:Rebuild();
			end;
		end);
	end);
end

-- Called when the local player's default colorify should be set.
function Schema:PlayerSetDefaultColorModify(colorModify)
	colorModify["$pp_colour_brightness"] = -0.02;
	colorModify["$pp_colour_contrast"] = 1.2;
	colorModify["$pp_colour_colour"] = 0.5;
end;

-- Called when the local player's color modify should be adjusted.
function Schema:PlayerAdjustColorModify(colorModify)
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
	
	if (IsValid(Clockwork.Client:GetSharedVar("SafeZone"))) then
		colorModify["$pp_colour_colour"] = 0.9;
		colorModify["$pp_colour_contrast"] = 1;
		colorModify["$pp_colour_brightness"] = 0;
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
function Schema:PlayerCanSeeBars(class)
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
function Schema:ShouldDrawLocalPlayer()
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

-- Called when the character panel weapon model is needed.
function Schema:GetCharacterPanelSequence(entity, character)
	local sequence = Clockwork.animation:GetForModel(
		model, "stand_smg_idle"
	);
	
	if (type(sequence) == "string") then
		sequence = entity:LookupSequence(sequence);
	end;
	
	return sequence;
end;

-- Called when the character panel weapon model is needed.
function Schema:GetCharacterPanelWeaponModel(panel, character)
	return "models/weapons/w_shotgun.mdl";
end;

-- Called when a model selection's weapon model is needed.
function Schema:GetModelSelectWeaponModel(model)
	return "models/weapons/w_shotgun.mdl";
end;

-- Called when a model selection's sequence is needed.
function Schema:GetModelSelectSequence(entity, model)
	local sequence = Clockwork.animation:GetForModel(
		model, "stand_smg_idle"
	);
	
	if (type(sequence) == "string") then
		sequence = entity:LookupSequence(sequence);
	end;
	
	return sequence;
end;

-- Called when the local player's item menu should be adjusted.
function Schema:PlayerAdjustItemMenu(itemTable, menuPanel, itemFunctions)
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
	elseif (itemTable("uniqueID") == "backpack") then
		if (itemTable:GetData("Level") < 6) then
			menuPanel:AddOption("Upgrade", function()
				Clockwork:StartDataStream("UpgradeItem", Clockwork.item:GetSignature(itemTable));
			end);
			
			local panel = menuPanel.Items[#menuPanel.Items];
			
			if (IsValid(panel)) then
				local upgradeCost = itemTable("cost") * (itemTable:GetData("Level") + 1); 
				panel:SetToolTip("This item will cost you "..FORMAT_CASH(upgradeCost, true).." to upgrade.");
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
			Schema:AddHotkey(itemTable);
		end);
	end;
end;

--[[ The laser we're going to use for the snipers... --]]
local SNIPER_LASER = Material("sprites/bluelaser1");
local LASER_HIT = Material("sprites/gmdm_pickups/light");

-- Called just after the translucent renderables have been drawn.
function Schema:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox and !bDrawingDepth and Clockwork.Client:Alive()
	and self.thirdPersonAmount > 0) then
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
			
			info.y = Clockwork:DrawInfo("STAMINA", info.x, info.y, Color(255, 255, 255, 255), nil, true);
			Clockwork:DrawSimpleGradientBox(2, info.x - 4, info.y - 4, (8 * 50) + 8, 24, backgroundColor);
			
			for i = 1, 50 do
				if (stamina / 2 > i) then
					draw.RoundedBox(2, info.x - 1, info.y - 1, 6, 18, Color(50, 175, 50, 255));
					draw.RoundedBox(2, info.x, info.y, 4, 16, Color(50, 175, 50, 255));
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
	
	if (!bDrawingSkybox and !bDrawingDepth and Clockwork.Client:Alive()) then
		for k, v in ipairs(self.ownedVehicles) do
			if (IsValid(v)) then
				Clockwork.outline:RenderFromFade(v, Color(255, 255, 255, 255), 512, true);
			else
				table.remove(self.ownedVehicles, k);
			end;
		end;
		
		for k, v in ipairs(self.ownedDoors) do
			if (IsValid(v)) then
				Clockwork.outline:RenderFromFade(v, Color(255, 255, 200, 255), 512, true);
			else
				table.remove(self.ownedDoors, k);
			end;
		end;
	end;
	
	if (bDrawingSkybox or bDrawingDepth) then return; end;
	
	cam.Start3D(EyePos(), EyeAngles());
	for k, v in ipairs(ents.FindByClass("cw_safezone")) do
		v:RenderBox();
	end;
	
	for k, v in ipairs(player.GetAll()) do
		local activeWeapon = v:GetActiveWeapon();
		
		if (v:HasInitialized() and IsValid(activeWeapon) and Clockwork.player:GetWeaponRaised(v)
		and activeWeapon:GetClass() == "rcs_g3sg1" and activeWeapon:GetNetworkedInt("Zoom") == 0) then
			local traceHitPos = v:GetEyeTraceNoCursor().HitPos;
			local muzzlePos = Clockwork.entity:GetMuzzlePos(v:GetActiveWeapon());
			local distance = muzzlePos:Distance(traceHitPos);
			local beamAlpha = (150 / 512) * math.min(distance, 512);
			
			render.SetMaterial(SNIPER_LASER);
			render.DrawBeam(
				muzzlePos, traceHitPos, 8, 0, CurTime(), Color(255, 0, 0, beamAlpha)
			);
			
			render.SetMaterial(LASER_HIT);
			render.DrawSprite(traceHitPos, 8, 8, Color(255, 0, 0, 150));
		end;
	end;
	cam.End3D();
end;

-- Called when the menu's items should be adjusted.
function Schema:MenuItemsAdd(menuItems)
	menuItems:Add("Group", "cwGroup", "Manage the group that you are a member of.");
end;

-- Called when an entity's menu options are needed.
function Schema:GetEntityMenuOptions(entity, options)
	if (entity:GetClass() == "cw_landmine" and !entity:IsBuilding()) then
		options["Defuse"] = "cwMineDefuse";
		
		if (!entity:HasUpgrade(MINE_FIRE)) then
			options["Upgrade"] = options["Upgrade"] or {};
			options["Upgrade"]["Fire Blast"] = {
				Callback = function(ForceMenuOption)
					ForceMenuOption("cwFireBlast");
				end,
				isArgTable = true,
				toolTip = "Upgrade this landmine to deal fire damage for "..FORMAT_CASH(40, nil, true).."."
			};
		end;
		
		if (!entity:HasUpgrade(MINE_ICE)) then
			options["Upgrade"] = options["Upgrade"] or {};
			options["Upgrade"]["Ice Blast"] = {
				Callback = function(ForceMenuOption)
					ForceMenuOption("cwIceBlast");
				end,
				isArgTable = true,
				toolTip = "Upgrade this landmine to freeze its target for "..FORMAT_CASH(40, nil, true).."."
			};
		end;
		
		if (!entity:HasUpgrade(MINE_STEALTH)) then
			options["Upgrade"] = options["Upgrade"] or {};
			options["Upgrade"]["Stealth"] = {
				Callback = function(ForceMenuOption)
					ForceMenuOption("cwStealth");
				end,
				isArgTable = true,
				toolTip = "Upgrade this landmine to have stealth camo for "..FORMAT_CASH(40, nil, true).."."
			};
		end;
	elseif (entity:GetClass() == "cw_sign_post") then
		if (entity:GetNetworkedString("Text") == "") then
			options["Write"] = {
				Callback = function(ForceMenuOption)
					Derma_StringRequest("Text", "What do you want the sign to say?", "<color=red>this</color> <color=blue>is</color> an <color=yellow>example</color>.", function(text)
						ForceMenuOption(text);
					end);
				end,
				isArgTable = true,
				toolTip = "Write on this sign permanently."
			};
		end;
	elseif (entity:GetClass() == "prop_ragdoll") then
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
		
		options["Set Name"] = {
			Callback = function(ForceMenuOption)
				Derma_StringRequest("Name", "What would you like to call this broadcaster?",
				entity:GetNetworkedString("Name"), function(text)
					ForceMenuOption(text);
				end);
			end,
			isArgTable = true,
			toolTip = "Set the name of this broadcaster."
		};
		
		options["Take"] = "cwBroadcasterTake";
	elseif (entity:GetClass() == "cw_belongings") then
		options["Open"] = "cwBelongingsOpen";
	elseif (entity:GetClass() == "cw_cash_printer") then
		if (entity:GetNetworkedInt("Level") < 2) then
			options["Upgrade"] = "cwPrinterUpgrade";
		end;
		
		if (entity:GetNetworkedInt("Cash") > 0) then
			options["Collect"] = "cwPrinterCollect";
		end;
	elseif (entity:GetClass() == "cw_breach") then
		options["Charge"] = "cwBreachCharge";
	elseif (entity:IsPlayer()) then
		local theirGroupName = entity:GetSharedVar("Group");
		local cashEnabled = Clockwork.config:Get("cash_enabled"):Get();
		local myGroupName = Clockwork.Client:GetSharedVar("Group");
		local cashName = Clockwork.option:GetKey("name_cash");
		
		if (myGroupName != "" and theirGroupName == ""
		and Clockwork.Client:GetSharedVar("Rank") == RANK_MAJ) then
			options["Invite"] = {
				isArgTable = true,
				Callback = function(entity)
					Clockwork:RunCommand("GroupInvite", entity:SteamID());
				end,
				toolTip = "Invite this character to your group."
			};
		end;
		
		if (entity:GetSharedVar("IsTied")) then
			options["Untie"] = {
				Callback = function(entity) Clockwork:RunCommand("PlyUntie"); end,
				isArgTable = true
			};
		end;
		
		if (cashEnabled) then
			options["Give"] = {
				Callback = function()
					Derma_StringRequest("Amount", "How much do you want to give them?", "0", function(text)
						Clockwork:RunCommand("Give"..string.gsub(cashName, "%s", ""), text);
					end);
				end,
				isArgTable = true,
				toolTip = "Give this character some "..string.lower(cashName).."."
			};
		end;
	elseif (entity:GetClass() == "cw_radio") then
		if (!entity:IsOff()) then
			options["Turn Off"] = "cwRadioToggle";
		else
			options["Turn On"] = "cwRadioToggle";
		end;
		
		options["Set Frequency"] = {
			Callback = function(ForceMenuOption)
				Derma_StringRequest("Frequency", "What would you like to set the frequency to?",
				entity:GetNetworkedString("Frequency"), function(text)
					ForceMenuOption(text);
				end);
			end,
			isArgTable = true,
			toolTip = "Set the frequency of this radio."
		};
		
		options["Take"] = "cwRadioTake";
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

-- Called when the scoreboard's player info should be adjusted.
function Schema:ScoreboardAdjustPlayerInfo(info)
	local theirGroupName = info.player:GetSharedVar("Group");
	local theirGroupRank = info.player:GetSharedVar("Rank");
	
	if (theirGroupName != "") then
		info.name = self:RankToTitle(theirGroupRank)..". "..info.name;
	end;
end;

-- Called when the target player's name is needed.
function Schema:GetTargetPlayerName(player)
	local theirGroupName = player:GetSharedVar("Group");
	local theirGroupRank = player:GetSharedVar("Rank");
	
	if (theirGroupName != "" and Clockwork.player:DoesRecognise(player)) then
		return self:RankToTitle(theirGroupRank)..". "..player:Name();
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

-- Called when the cinematic intro info is needed.
function Schema:GetCinematicIntroInfo()
	return {
		credits = "Designed and developed by "..self:GetAuthor()..".",
		title = Clockwork.config:Get("intro_text_big"):Get(),
		text = Clockwork.config:Get("intro_text_small"):Get()
	};
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
		
		if (target:GetSharedVar("IsTied")) then
			if (Clockwork.player:GetAction(Clockwork.Client) == "untie") then
				mainStatus = gender.. " is being untied.";
			else
				mainStatus = gender.." has been tied up.";
			end;
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
function Schema:ShouldDrawPlayerTargetID(player)
	if (player:GetMaterial() == "sprites/heatwave") then
		return false;
	end;
end;

-- Called when screen space effects should be rendered.
function Schema:RenderScreenspaceEffects()
	if (!Clockwork:IsScreenFadedBlack()) then
		local curTime = CurTime();
		
		if (self.flashEffect) then
			local timeLeft = math.Clamp(self.flashEffect[1] - curTime, 0, self.flashEffect[2]);
			local incrementer = 1 / self.flashEffect[2];
			
			if (timeLeft > 0) then
				local colorModify = {};
					colorModify["$pp_colour_brightness"] = 0;
					colorModify["$pp_colour_contrast"] = 1 + (timeLeft * incrementer);
					colorModify["$pp_colour_colour"] = 1 - (incrementer * timeLeft);
					colorModify["$pp_colour_addr"] = incrementer * timeLeft;
					colorModify["$pp_colour_addg"] = 0;
					colorModify["$pp_colour_addb"] = 0;
					colorModify["$pp_colour_mulr"] = 1;
					colorModify["$pp_colour_mulg"] = 0;
					colorModify["$pp_colour_mulb"] = 0;
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
		
		local bThermalVis = Clockwork.Client:GetSharedVar("Thermal");
		local modulation = {1, 1, 1};
		
		if (bThermalVis) then
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
				if (v:HasInitialized() and (bThermalVis or v:GetMaterial() == "sprites/heatwave")) then
					v.cwForceDrawAlways = true;
					
					render.SuppressEngineLighting(true);
					render.SetColorModulation(unpack(modulation));
					
					self.heatwaveMaterial:SetMaterialFloat("$refractamount", -0.0007);
					
					if (!bThermalVis) then
						local fSpeedAdd = math.max((0.07 / 512) * (v:GetVelocity():Length() - 150), 0.07);
						
						if (v:GetSharedVar("HideStealth") > CurTime()) then
							self.heatwaveMaterial:SetMaterialFloat("$refractamount", -0.07);
							
							render.SetBlend(0.3);
							v:SetMaterial("");
								v:DrawModel();
							v:SetMaterial("sprites/heatwave");
							render.SetBlend(1);
						elseif (v:GetVelocity():Length() > 1) then
							self.heatwaveMaterial:SetMaterialFloat("$refractamount", -0.007 + (0.07 - fSpeedAdd));
						end;
						
						v:DrawModel();
					else
						SetMaterialOverride(self.shinyMaterial);
							v:DrawModel();
						SetMaterialOverride(false);
					end;
					
					render.SetColorModulation(1, 1, 1);
					render.SuppressEngineLighting(false);
					
					v.cwForceDrawAlways = nil;
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
function Schema:PlayerAdjustMotionBlurs(motionBlurs)
	if (self.suppressEffect) then
		local curTime = CurTime();
		local timeLeft = math.max(self.suppressEffect - curTime, 0);
		
		if (timeLeft > 0) then
			motionBlurs.blurTable["suppression"] = 1 - ((1 / 10) * timeLeft);
		end;
	end;
end;

-- Called when the calc view table should be adjusted.
function Schema:CalcViewAdjustTable(view)
	if (Clockwork.Client:InVehicle()) then
		local vehicleEntity = Clockwork.Client:GetVehicle();
		
		if (!Clockwork.entity:HasFetchedItemData(vehicleEntity)) then
			Clockwork.entity:FetchItemData(vehicleEntity);
			return;
		end;
		
		local itemTable = Clockwork.entity:FetchItemTable(vehicleEntity);

		if (itemTable("calcView")) then
			view.origin = view.origin + itemTable("calcView");
		end;
	elseif (self.thirdPersonAmount > 0 and !Clockwork.player:IsNoClipping(Clockwork.Client)) then
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
	elseif (self.suppressEffect) then
		local curTime = CurTime();
		local timeLeft = self.suppressEffect - curTime;
		local multiplier = timeLeft;
		
		view.angles.p = view.angles.p + (4 * multiplier);
		view.angles.y = view.angles.y + (4 * multiplier);
	end;
end;

-- Called when the foreground HUD should be painted.
function Schema:HUDPaintForeground()
	local informationColor = Clockwork.option:GetColor("information");
	local backgroundColor = Clockwork.option:GetColor("background");
	local dateTimeFont = Clockwork.option:GetFont("date_time_text");
	local colorWhite = Clockwork.option:GetColor("white");
	local curTime = CurTime();
	local y = (ScrH() / 2) - 128;
	local x = ScrW() / 2;
	
	--[[ We don't want to draw any of this stuff is the client is alive! --]]
	if (!Clockwork.Client:Alive()) then return; end;
	
	if (type(self.hotkeyItems) == "table") then
		local x = 16;
		local y = ScrH() - 80;
		
		Clockwork:DrawGradient(
			GRADIENT_RIGHT, x, y, 408, 48, Color(100, 100, 100, boxAlpha)
		);
		
		for i = 0, 9 do
			local hotkeyData = self.hotkeyItems[i + 1];
			local boxX = x + (40 * i) + 8;
			local boxY = y + 8;
			
			if (hotkeyData) then
				local itemsList = Clockwork.inventory:FindItemsByName(
					Clockwork.inventory:GetClient(), hotkeyData.uniqueID,
					hotkeyData.name
				);
				
				Clockwork:DrawInfo(
					tostring(#itemsList), boxX + 16, boxY - 32, colorWhite, 255
				);
			end;
			
			draw.RoundedBox(4, boxX, boxY, 32, 32, Color(255, 255, 255, 50));
		end;
		
		Clockwork:DrawInfo(
			"Hold <"..(input.LookupBinding("+menu_context") or "+menu_context").."> to click on a hotkey slot or other clickables.",
			x, y + 52, colorWhite, 255, true
		);
	end;
	
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
	
	if (!self.centerTexts) then return; end;
	local centerText = self.centerTexts[1];
	
	if (!centerText) then
		return;
	end;
	
	local introTextBig = Clockwork.option:GetFont("intro_text_big");
	local introTextSmall = Clockwork.option:GetFont("intro_text_small");
	local introTextTiny = Clockwork.option:GetFont("intro_text_tiny");
	
	if (!centerText.fadeBack or CurTime() >= centerText.fadeBack) then
		centerText.alpha = math.Approach(
			centerText.alpha, centerText.targetAlpha, FrameTime() * 64
		);
	end;
	
	if (centerText.soundName) then
		surface.PlaySound(centerText.soundName);
		centerText.soundName = nil;
	end;
	
	if (centerText.targetAlpha == 0 and centerText.alpha == 0) then
		table.remove(self.centerTexts, 1);
		return;
	elseif (centerText.targetAlpha == 255 and centerText.alpha == 255
	and !centerText.fadeBack) then
		centerText.targetAlpha = 0;
		centerText.fadeBack = CurTime() + 2;
	end;
	
	local x, y = ScrW() / 2, ScrH() * 0.3;
	
	if (centerText.bSmallTitle) then
		introTextBig = introTextSmall;
	end;
	
	Clockwork:OverrideMainFont(introTextBig);
		y = Clockwork:DrawInfo(centerText.text, x, y, informationColor, centerText.alpha);
	Clockwork:OverrideMainFont(false);
	
	if (centerText.subText) then
		Clockwork:OverrideMainFont(introTextTiny);
			y = Clockwork:DrawInfo(centerText.subText, x, y, colorWhite, centerText.alpha);
		Clockwork:OverrideMainFont(false);
	end;
end;

-- Called to get the screen text info.
function Schema:GetScreenTextInfo()
	local blackFadeAlpha = Clockwork:GetBlackFadeAlpha();
	
	if (!Clockwork.Client:Alive() and self.deathType) then
		return {
			alpha = blackFadeAlpha,
			title = "YOU WERE KILLED BY "..self.deathType,
			text = "It probably isn't random, you just don't know the reason."
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

-- Called when the post progress bar info is needed.
function Schema:GetPostProgressBarInfo()
	if (Clockwork.Client:Alive()) then
		local action, percentage = Clockwork.player:GetAction(Clockwork.Client, true);
		
		if (action == "die") then
			return {text = "You are slowly dying.", percentage = percentage, flash = percentage > 75};
		elseif (action == "safezone_leave") then
			return {text = "You are leaving a Safe Zone.", percentage = percentage, flash = percentage > 75};
		elseif (action == "safezone_enter") then
			return {text = "You are entering a Safe Zone.", percentage = percentage, flash = percentage > 75};
		elseif (action == "defuse") then
			return {text = "You are defusing a landmine.", percentage = percentage, flash = percentage > 75};
		elseif (action == "build") then
			return {text = "You are building this entity...", percentage = percentage, flash = percentage > 75};
		end;
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function Schema:HUDPaintEntityTargetID(entity, info)
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
	
	if (!Clockwork.Client:InVehicle() and entity:GetClass() == "prop_vehicle_jeep") then
		if (!Clockwork.entity:HasFetchedItemData(entity)) then
			Clockwork.entity:FetchItemData(entity);
			return;
		end;
		
		local itemTable = Clockwork.entity:FetchItemTable(entity);
		local description = itemTable("description");
		local wrappedTable = {};
		
		info.y = Clockwork:DrawInfo(itemTable("name"), info.x, info.y, colorTargetID, info.alpha);
		
		Clockwork:WrapText(
			description, Clockwork.option:GetFont("target_id_text"), math.max(ScrW() / 8, 384), wrappedTable
		);
		
		for k, v in ipairs(wrappedTable) do
			info.y = Clockwork:DrawInfo(v, info.x, info.y, colorWhite, info.alpha);
		end;
	end;
end;

-- Called when the local player's storage is rebuilt.
function Schema:PlayerStorageRebuilt(panel, categories)
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

-- Called when a player presses a bind.
function Schema:PlayerBindPress(player, bind, pressed)
	if (player:InVehicle()) then
		if (string.find(bind, "+attack2")) then
			Clockwork:StartDataStream("ManageCar", "unlock");
		elseif (string.find(bind, "+attack")) then
			Clockwork:StartDataStream("ManageCar", "lock");
		elseif (string.find(bind, "+reload")) then
			Clockwork:StartDataStream("ManageCar", "horn");
		end;
	end;
end;