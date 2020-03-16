--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

AddCSLuaFile("sh_boot");
AddCSLuaFile("cl_init.lua");
include("sh_boot");

-- A function to load the radios.
function Schema:LoadRadios()
	local radios = Clockwork:RestoreSchemaData("plugins/radios/"..game.GetMap());
	
	for k, v in pairs(radios) do
		local entity = nil;
		
		if (v.frequency) then
			entity = ents.Create("cw_radio");
		else
			entity = ents.Create("cw_broadcaster");
		end;
		
		Clockwork.player:GivePropertyOffline(v.key, v.uniqueID, entity);
		
		entity:SetItemTable(Clockwork.item:CreateInstance(v.item, v.itemID, v.data));
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (IsValid(entity)) then
			entity:SetOff(v.off);
			
			if (v.frequency) then
				entity:SetFrequency(v.frequency);
			end;
		end;
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the radios.
function Schema:SaveRadios()
	local radios = {};
	
	for k, v in pairs(ents.FindByClass("cw_radio")) do
		local physicsObject = v:GetPhysicsObject();
		local itemTable = v:GetItemTable();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:IsOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			item = itemTable("uniqueID"),
			data = itemTable("data"),
			angles = v:GetAngles(),
			itemID = itemTable("itemID"),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			frequency = v:GetSharedVar("Frequency"),
			isMoveable = bMoveable
		};
	end;
	
	for k, v in pairs(ents.FindByClass("cw_broadcaster")) do
		local physicsObject = v:GetPhysicsObject();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:IsOff(),
			key = Clockwork.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/radios/"..game.GetMap(), radios);
end;

-- A function to make an explosion.
function Schema:MakeExplosion(position, scale)
	local explosionEffect = EffectData();
	local smokeEffect = EffectData();
		explosionEffect:SetOrigin(position);
		explosionEffect:SetScale(scale);
		smokeEffect:SetOrigin(position);
		smokeEffect:SetScale(scale);
	util.Effect("explosion", explosionEffect, true, true);
	util.Effect("cw_smoke_effect", smokeEffect, true, true);
end;

-- A function to get a player's location.
function Schema:PlayerGetLocation(player)
	local areaNames = Clockwork.plugin:FindByID("Area Names");
	local closest;
	
	if (areaNames) then
		for k, v in pairs(areaNames.areaNames) do
			if (Clockwork.entity:IsInBox(player, v.minimum, v.maximum)) then
				if (string.sub(string.lower(v.name), 1, 4) == "the ") then
					return string.sub(v.name, 5);
				else
					return v.name;
				end;
			else
				local distance = player:GetShootPos():Distance(v.minimum);
				
				if (!closest or distance < closest[1]) then
					closest = {distance, v.name};
				end;
			end;
		end;
		
		if (!completed) then
			if (closest) then
				if (string.sub(string.lower(closest[2]), 1, 4) == "the ") then
					return string.sub(closest[2], 5);
				else
					return closest[2];
				end;
			end;
		end;
	end;
	
	return "unknown location";
end;

-- A function to load the lottery cash.
function Schema:LoadLotteryCash()
	self.cwLotteryCash = Clockwork:RestoreSchemaData("lottery");
	
	if (!tonumber(self.cwLotteryCash)) then
		self.cwLotteryCash = 0;
	end;
end;

-- A function to save the lottery cash.
function Schema:SaveLotteryCash()
	Clockwork:SaveSchemaData("lottery", self.cwLotteryCash);
end;

-- A function to get a player's heal amount.
function Schema:GetHealAmount(player, scale)
	local medical = Clockwork.attributes:Fraction(player, ATB_MEDICAL, 35);
	local healAmount = (15 + medical) * (scale or 1);
	
	return healAmount;
end;

-- A function to get a player's dexterity time.
function Schema:GetDexterityTime(player)
	return 7 - Clockwork.attributes:Fraction(player, ATB_DEXTERITY, 5, 5);
end;

-- A function to get whether a player has won the lottery.
function Schema:HasWonLottery(player, numbers, winningNumbers)
	local correctNumbers = 0;
	local numbersCopy = table.Copy(winningNumbers);
	
	for i = 1, 3 do
		for o = 1, 3 do
			if (numbers[i] == numbersCopy[o]) then
				correctNumbers = correctNumbers + 1;
				numbersCopy[o] = nil;
				
				break;
			end;
		end;
	end;
	
	if (correctNumbers == 3) then
		return true;
	else
		return false;
	end;
end;

-- A function to send the player their crimes.
function Schema:SendCrimes(player)
	player:SetSharedVar("Crimes", glon.encode(player:GetCharacterData("Stars").crimes));
end;

-- A function to give a player a star.
function Schema:GivePlayerStar(player, crime)
	if (player:GetFaction() != FACTION_POLICE) then
		local stars = player:GetCharacterData("Stars");
		local hasValue = (stars.crimes[crime] != nil);
		local increase = 1;
		
		if (crime == CRIME_MURDER) then
			increase = 4;
		elseif (crime == CRIME_WEAPON) then
			increase = 3;
		end;
		
		if ((crime != CRIME_WEAPON and crime != CRIME_ASSAULT) or !hasValue) then
			stars.stars = math.min(stars.stars + increase, 5);
			stars.crimes[crime] = (stars.crimes[crime] or 0) + 1;
			stars.clearTime = os.clock() + 1200;
			
			umsg.Start("cwGiveStar", player);
				umsg.Short(crime);
			umsg.End();
			
			player:SetSharedVar("Stars", stars.stars);
			self:SendCrimes(player);
		end;
	end;
end;

-- A function to bust down a door.
function Schema:BustDownDoor(player, door, force)
	door.cwIsBustedDown = true;
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	local fakeDoor = ents.Create("prop_physics");
	
	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
	fakeDoor:SetAngles(door:GetAngles());
	fakeDoor:SetModel(door:GetModel());
	fakeDoor:SetSkin(door:GetSkin());
	fakeDoor:SetPos(door:GetPos());
	fakeDoor:Spawn();
	
	local physicsObject = fakeDoor:GetPhysicsObject();
	
	if (IsValid(physicsObject)) then
		if (!force) then
			if (IsValid(player)) then
				physicsObject:ApplyForceCenter((door:GetPos() - player:GetPos()):Normalize() * 10000);
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	Clockwork.entity:Decay(fakeDoor, 300);
	
	Clockwork:CreateTimer("ResetDoor"..door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
			door.cwIsBustedDown = nil;
		end;
	end);
end;

-- A function to load the belongings.
function Schema:LoadBelongings()
	local belongings = Clockwork:RestoreSchemaData("plugins/belongings/"..game.GetMap());
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("cw_belongings");
		
		if (v.cwInventory["human_meat"]) then
			v.cwInventory["human_meat"] = nil;
		end;
		
		entity:SetAngles(v.angles);
		entity:SetData(
			Clockwork.inventory:ToLoadable(v.cwInventory),
			v.cwCash
		);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (!v.isMoveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the belongings.
function Schema:SaveBelongings()
	local belongings = {};
	
	for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
		if (v.cwIsBelongings and (v.cwCash > 0 or table.Count(v.cwInventory) > 0)) then
			belongings[#belongings + 1] = {
				cash = v.cwCash,
				angles = Angle(0, 0, -90),
				position = v:GetPos() + Vector(0, 0, 32),
				inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
				isMoveable = true
			};
		end;
	end;
	
	for k, v in pairs(ents.FindByClass("cw_belongings")) do
		if (v.cwCash and v.cwInventory and (v.cwCash > 0 or table.Count(v.cwInventory) > 0)) then
			local physicsObject = v:GetPhysicsObject();
			local bMoveable = nil;
			
			if (IsValid(physicsObject)) then
				bMoveable = physicsObject:IsMoveable();
			end;
			
			belongings[#belongings + 1] = {
				cash = v.cwCash,
				angles = v:GetAngles(),
				position = v:GetPos(),
				inventory = Clockwork.inventory:ToSaveable(v.cwInventory),
				isMoveable = bMoveable
			};
		end;
	end;
	
	Clockwork:SaveSchemaData("plugins/belongings/"..game.GetMap(), belongings);
end;

-- A function to make a player drop random items.
function Schema:PlayerDropRandomItems(player, ragdoll)
	local defaultModel = Clockwork.player:GetDefaultModel(player);
	local defaultSkin = Clockwork.player:GetDefaultSkin(player);
	local inventory = player:GetInventory();
	local clothes = player:GetCharacterData("Clothes");
	local model = player:GetModel();
	local cash = player:GetCash();
	local info = {
		inventory = {},
		cash = cash
	};
	
	if (!IsValid(ragdoll)) then
		info.entity = ents.Create("cw_belongings");
	end;
	
	for k, v in pairs(inventory) do
		local itemTable = Clockwork.item:FindByID(k);
		
		if (itemTable("allowStorage") != false and !itemTable("isRareItem")) then
			for k2, v2 in pairs(v) do
				if (player:TakeItem(v2)) then
					Clockwork.inventory:AddInstance(
						info.inventory, v2
					);
				end;
			end;
		end;
	end;
	
	player:SetCharacterData("Cash", 0, true);
	
	if (!IsValid(ragdoll)) then
		if (table.Count(info.inventory) > 0 or info.cash > 0) then
			info.entity:SetAngles(Angle(0, 0, -90));
			info.entity:SetData(info.inventory, info.cash);
			info.entity:SetPos(player:GetPos() + Vector(0, 0, 48));
			info.entity:Spawn();
		else
			info.entity:Remove();
		end;
	else
		if (ragdoll:GetModel() != model) then
			ragdoll:SetModel(model);
		end;
		
		ragdoll.cwIsBelongings = true;
		ragdoll.cwClothesData = {clothes, defaultModel, defaultSkin};
		ragdoll.inventory = info.inventory;
		ragdoll.cash = info.cash;
	end;
	
	if (Clockwork.config:Get("using_life_system"):Get()) then
		player:SetCharacterData("IsDead", true);
	end;
	
	Clockwork.player:SaveCharacter(player);
end;

-- A function to tie or untie a player.
function Schema:TiePlayer(player, isTied, reset, government)
	if (isTied) then
		if (government) then
			player:SetSharedVar("IsTied", 2);
		else
			player:SetSharedVar("IsTied", 1);
		end;
	else
		player:SetSharedVar("IsTied", 0);
	end;
	
	if (isTied) then
		Clockwork.player:DropWeapons(player);
		Clockwork:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.");
		
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if (player:Alive() and !player:IsRagdolled()) then 
			Clockwork.player:LightSpawn(player, true, true);
		end;
		
		Clockwork:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.");
	end;
end;

resource.AddFile("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");
resource.AddFile("models/katharsmodels/syringe_out/syringe_out.mdl");
resource.AddFile("models/katharsmodels/syringe_out/heroine_out.mdl");
resource.AddFile("materials/cwCityLife/bg_gradient.vtf");
resource.AddFile("materials/cwCityLife/bg_gradient.vmt");
resource.AddFile("materials/cwCityLife/scratch_final.vtf");
resource.AddFile("materials/cwCityLife/scratch_final.vmt");
resource.AddFile("materials/cwCityLife/dirty_final.vtf");
resource.AddFile("materials/cwCityLife/dirty_final.vmt");
resource.AddFile("materials/cwCityLife/star_empty.vtf");
resource.AddFile("materials/cwCityLife/star_empty.vmt");
resource.AddFile("materials/cwCityLife/star_full.vtf");
resource.AddFile("materials/cwCityLife/star_full.vmt");
resource.AddFile("models/pmc/pmc_4/pmc__07.mdl");
resource.AddFile("resource/fonts/sansation.ttf");
resource.AddFile("models/jaanus/morphi.mdl");
resource.AddFile("models/jaanus/ecstac.mdl");
resource.AddFile("models/sprayca2.mdl");
resource.AddFile("models/cocn.mdl");

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cikizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cikizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cirizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cirizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/ciaizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/ciaizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cilizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cilizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cibizen_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cibizen_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/cityadm_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/cityadm_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/freerun_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/freerun_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/pmc/pmc_4/*.*")) do
	resource.AddFile("materials/models/pmc/pmc_4/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/pmc/pmc_shared/*.*")) do
	resource.AddFile("materials/models/pmc/pmc_shared/"..v);
end;

for k, v in pairs(_file.Find("../materials/katharsmodels/contraband/*.*")) do
	resource.AddFile("materials/katharsmodels/contraband/"..v);
end;

for k, v in pairs(_file.Find("../materials/katharsmodels/syringe_out/*.*")) do
	resource.AddFile("materials/katharsmodels/syringe_out/"..v);
end;

for k, v in pairs(_file.Find("../materials/katharsmodels/syringe_in/*.*")) do
	resource.AddFile("materials/katharsmodels/syringe_in/"..v);
end;

for k, v in pairs(_file.Find("../materials/jaanus/ecstac_a.*")) do
	resource.AddFile("materials/jaanus/"..v);
end;

for k, v in pairs(_file.Find("../materials/jaanus/morphi_a.*")) do
	resource.AddFile("materials/jaanus/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/drug/*.*")) do
	resource.AddFile("materials/models/drug/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/lagmite/*.*")) do
	resource.AddFile("materials/models/lagmite/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/spraycan3.*")) do
	resource.AddFile("materials/models/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/deadbodies/*.*")) do
	resource.AddFile("materials/models/deadbodies/"..v);
end;

for k, v in pairs(_file.Find("../models/deadbodies/*.*")) do
	resource.AddFile("models/deadbodies/"..v);
end;

for k, v in pairs(_file.Find("../models/lagmite/*.*")) do
	resource.AddFile("models/lagmite/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group17/*.mdl")) do
	resource.AddFile("models/humans/group17/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group99/*.mdl")) do
	resource.AddFile("models/humans/group99/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group09/*.mdl")) do
	resource.AddFile("models/humans/group09/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group10/*.mdl")) do
	resource.AddFile("models/humans/group10/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group08/*.mdl")) do
	resource.AddFile("models/humans/group08/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group07/*.mdl")) do
	resource.AddFile("models/humans/group07/"..v);
end;

for k, v in pairs(_file.Find("../models/humans/group04/*.mdl")) do
	resource.AddFile("models/humans/group04/"..v);
end;

Clockwork.config:Add("using_life_system", true, true);
Clockwork.config:Add("using_star_system", true, true);
Clockwork.config:Add("intro_text_small", "Where the rich get famous.", true);
Clockwork.config:Add("intro_text_big", "DEEP WITHIN EVOCITY, 2010.", true);

Clockwork.config:Get("change_class_interval"):Set(60);
Clockwork.config:Get("enable_gravgun_punt"):Set(false);
Clockwork.config:Get("default_inv_weight"):Set(8);
Clockwork.config:Get("minimum_physdesc"):Set(16);
Clockwork.config:Get("scale_prop_cost"):Set(0);
Clockwork.config:Get("disable_sprays"):Set(false);
Clockwork.config:Get("wages_interval"):Set(360);
Clockwork.config:Get("default_cash"):Set(80);

Clockwork.hint:Add("911", "You can contact the police by using the command $command_prefix$911.");
Clockwork.hint:Add("912", "You can contact secretaries by using the command $command_prefix$912.");
Clockwork.hint:Add("Call", "Call somebody by using the command $command_prefix$call.");
Clockwork.hint:Add("Admins", "The admins are here to help you, please respect them.");
Clockwork.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
Clockwork.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
Clockwork.hint:Add("Headset", "You can speak to other characters with your class by using $command_prefix$Headset.");
Clockwork.hint:Add("Alliance", "You can create an alliance by using the command $command_prefix$AllyCreate.");
Clockwork.hint:Add("Broadcast", "As the president, you can broadcast to the city with $command_prefix$Broadcast.");
Clockwork.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
Clockwork.hint:Add("F4 Hotkey", "Press F4 while looking at a tied character to search them.");
Clockwork.hint:Add("Caller ID", "Set your cell phone number by using the command $command_prefix$SetCallerID.");

Clockwork:HookDataStream("TakeDownBillboard", function(player, data)
	local billboard = Schema.billboards[data];
	
	if (billboard and billboard.data) then
		if (billboard.data.owner == player) then
			Clockwork:StartDataStream(nil, "BillboardRemove", data);
			
			billboard.uniqueID = nil;
			billboard.data = nil;
			billboard.key = nil;
		end;
	end;
end);

Clockwork:HookDataStream("PurchaseLottery", function(player, data)
	if (type(data) == "table") then
		local numberOne = tonumber(data[1]) or 1;
		local numberTwo = tonumber(data[2]) or 1;
		local numberThree = tonumber(data[3]) or 1;
		
		local nextLotteryTime = Clockwork:GetSharedVar("Lottery");
		local lotteryTicket = player:GetSharedVar("Lottery");
		local curTime = CurTime();
		
		if (nextLotteryTime > curTime and !lotteryTicket) then
			if (Clockwork.player:CanAfford(player, 40)) then
				Clockwork.player:GiveCash(player, -40, "purchasing a lottery ticket");
				
				Schema.cwLotteryCash = Schema.cwLotteryCash + 40;
				
				player:SetSharedVar("Lottery", true);
				player.cwLottery = {numberOne, numberTwo, numberThree};
			else
				Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(40 - player:GetCash(), nil, true).."!");
			end;
		elseif (!lotteryTicket) then
			Clockwork.player:Notify(player, "The lottery is currently in progress, please wait!");
		else
			Clockwork.player:Notify(player, "You have already purchased a lottery ticket, please wait.");
		end;
	end;
end);

Clockwork:HookDataStream("UpdateBillboard", function(player, data)
	if (type(data) == "table") then
		local billboard = Schema.billboards[data.id];
		local color = Color(255, 255, 255, 255);
		local title = string.sub(data.title or "", 0, 18);
		local text = string.sub(data.text or "", 0, 80);
		
		if (data.color) then
			color.r = data.color.r or 255;
			color.g = data.color.g or 255;
			color.b = data.color.b or 255;
		end;
		
		if (billboard) then
			if (billboard.data and IsValid(billboard.data.owner)) then
				if (billboard.data.owner == player) then
					billboard.data = {
						color = color,
						owner = player,
						title = title,
						text = text
					};
					
					Clockwork:StartDataStream(nil, "BillboardAdd", {id = data.id, data = billboard.data});
				end;
			else
				if (Clockwork.player:CanAfford(player, 60)) then
					billboard.uniqueID = player:UniqueID();
					billboard.data = {
						owner = player,
						color = color,
						title = title,
						text = text
					};
					billboard.key = player:GetCharacterKey();
					
					Clockwork:StartDataStream(nil, "BillboardAdd", {id = data.id, data = billboard.data});
					
					Clockwork.player:GiveCash(player, -60, "purchasing a billboard");
				else
					Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(60 - player:GetCash(), nil, true).."!");
				end;
			end;
		end;
	end;
end);

Clockwork:HookDataStream("JoinAlliance", function(player, data)
	if (player.cwAllianceAuth == data) then
		player:SetCharacterData("Leader", nil);
		player:SetCharacterData("Alliance", data);
		Clockwork.player:Notify(player, "You have joined the '"..data.."' alliance.");
	end;
end);

Clockwork:HookDataStream("Notepad", function(player, data)
	if (type(data) == "string" and player:HasItemByID("notepad")) then
		player:SetCharacterData("Notepad", string.sub(data, 0, 500));
	end;
end);

Clockwork:HookDataStream("CreateAlliance", function(player, data)
	if (type(data) == "string") then
		local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
		local schemaFolder = Clockwork:GetSchemaFolder();
		local alliance = tmysql.escape(string.gsub(string.sub(data, 1, 32), "[%p%d]", ""));
		
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Data LIKE \"%\\\"alliance\\\":\\\""..alliance.."\\\"\"%", function(result)
			if (IsValid(player)) then
				if (result and type(result) == "table" and #result > 0) then
					Clockwork.player:Notify(player, "An alliance with the name '"..alliance.."' already exists!");
				else
					player:SetCharacterData("Leader", true);
					player:SetCharacterData("Alliance", alliance);
					
					Clockwork.player:Notify(player, "You have created the '"..alliance.."' alliance.");
				end;
			end;
		end, 1);
	end;
end);

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Schema:Register();