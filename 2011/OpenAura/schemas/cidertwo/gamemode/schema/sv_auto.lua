--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

resource.AddFile("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");
resource.AddFile("models/katharsmodels/syringe_out/syringe_out.mdl");
resource.AddFile("models/katharsmodels/syringe_out/heroine_out.mdl");
resource.AddFile("materials/cidertwo/bg_gradient.vtf");
resource.AddFile("materials/cidertwo/bg_gradient.vmt");
resource.AddFile("materials/cidertwo/scratch_final.vtf");
resource.AddFile("materials/cidertwo/scratch_final.vmt");
resource.AddFile("materials/cidertwo/dirty_final.vtf");
resource.AddFile("materials/cidertwo/dirty_final.vmt");
resource.AddFile("materials/cidertwo/star_empty.vtf");
resource.AddFile("materials/cidertwo/star_empty.vmt");
resource.AddFile("materials/cidertwo/star_full.vtf");
resource.AddFile("materials/cidertwo/star_full.vmt");
resource.AddFile("models/pmc/pmc_4/pmc__07.mdl");
resource.AddFile("resource/fonts/sansation.ttf");
resource.AddFile("models/jaanus/morphi.mdl");
resource.AddFile("models/jaanus/ecstac.mdl");
resource.AddFile("models/sprayca2.mdl");
resource.AddFile("models/cocn.mdl");

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cikizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cikizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cirizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cirizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/ciaizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/ciaizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cilizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cilizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cibizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cibizen_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cityadm_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cityadm_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/freerun_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/freerun_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/pmc/pmc_4/*.*") ) do
	resource.AddFile("materials/models/pmc/pmc_4/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/pmc/pmc_shared/*.*") ) do
	resource.AddFile("materials/models/pmc/pmc_shared/"..v);
end;

for k, v in pairs( _file.Find("../materials/katharsmodels/contraband/*.*") ) do
	resource.AddFile("materials/katharsmodels/contraband/"..v);
end;

for k, v in pairs( _file.Find("../materials/katharsmodels/syringe_out/*.*") ) do
	resource.AddFile("materials/katharsmodels/syringe_out/"..v);
end;

for k, v in pairs( _file.Find("../materials/katharsmodels/syringe_in/*.*") ) do
	resource.AddFile("materials/katharsmodels/syringe_in/"..v);
end;

for k, v in pairs( _file.Find("../materials/jaanus/ecstac_a.*") ) do
	resource.AddFile("materials/jaanus/"..v);
end;

for k, v in pairs( _file.Find("../materials/jaanus/morphi_a.*") ) do
	resource.AddFile("materials/jaanus/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/drug/*.*") ) do
	resource.AddFile("materials/models/drug/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/lagmite/*.*") ) do
	resource.AddFile("materials/models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/spraycan3.*") ) do
	resource.AddFile("materials/models/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/deadbodies/*.*") ) do
	resource.AddFile("materials/models/deadbodies/"..v);
end;

for k, v in pairs( _file.Find("../models/deadbodies/*.*") ) do
	resource.AddFile("models/deadbodies/"..v);
end;

for k, v in pairs( _file.Find("../models/lagmite/*.*") ) do
	resource.AddFile("models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group17/*.mdl") ) do
	resource.AddFile("models/humans/group17/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group99/*.mdl") ) do
	resource.AddFile("models/humans/group99/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group09/*.mdl") ) do
	resource.AddFile("models/humans/group09/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group10/*.mdl") ) do
	resource.AddFile("models/humans/group10/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group08/*.mdl") ) do
	resource.AddFile("models/humans/group08/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group07/*.mdl") ) do
	resource.AddFile("models/humans/group07/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group04/*.mdl") ) do
	resource.AddFile("models/humans/group04/"..v);
end;

openAura.config:Add("using_life_system", true, true);
openAura.config:Add("using_star_system", true, true);
openAura.config:Add("intro_text_small", "Where the rich get famous.", true);
openAura.config:Add("intro_text_big", "DEEP WITHIN EVOCITY, 2010.", true);

openAura.config:Get("change_class_interval"):Set(60);
openAura.config:Get("enable_gravgun_punt"):Set(false);
openAura.config:Get("default_inv_weight"):Set(8);
openAura.config:Get("minimum_physdesc"):Set(16);
openAura.config:Get("scale_prop_cost"):Set(0);
openAura.config:Get("disable_sprays"):Set(false);
openAura.config:Get("wages_interval"):Set(360);
openAura.config:Get("default_cash"):Set(80);

openAura.hint:Add("911", "You can contact the police by using the command $command_prefix$911.");
openAura.hint:Add("912", "You can contact secretaries by using the command $command_prefix$912.");
openAura.hint:Add("Call", "Call somebody by using the command $command_prefix$call.");
openAura.hint:Add("Admins", "The admins are here to help you, please respect them.");
openAura.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
openAura.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
openAura.hint:Add("Headset", "You can speak to other characters with your class by using $command_prefix$Headset.");
openAura.hint:Add("Alliance", "You can create an alliance by using the command $command_prefix$AllyCreate.");
openAura.hint:Add("Broadcast", "As the president, you can broadcast to the city with $command_prefix$Broadcast.");
openAura.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
openAura.hint:Add("F4 Hotkey", "Press F4 while looking at a tied character to search them.");
openAura.hint:Add("Caller ID", "Set your cell phone number by using the command $command_prefix$SetCallerID.");

openAura:HookDataStream("TakeDownBillboard", function(player, data)
	local billboard = openAura.schema.billboards[data];
	
	if (billboard and billboard.data) then
		if (billboard.data.owner == player) then
			openAura:StartDataStream(nil, "BillboardRemove", data);
			
			billboard.uniqueID = nil;
			billboard.data = nil;
			billboard.key = nil;
		end;
	end;
end);

openAura:HookDataStream("PurchaseLottery", function(player, data)
	if (type(data) == "table") then
		local numberOne = tonumber( data[1] ) or 1;
		local numberTwo = tonumber( data[2] ) or 1;
		local numberThree = tonumber( data[3] ) or 1;
		
		local nextLotteryTime = openAura:GetSharedVar("lottery");
		local lotteryTicket = player:GetSharedVar("lottery");
		local curTime = CurTime();
		
		if (nextLotteryTime > curTime and !lotteryTicket) then
			if ( openAura.player:CanAfford(player, 40) ) then
				openAura.player:GiveCash(player, -40, "purchasing a lottery ticket");
				
				openAura.schema.lotteryCash = openAura.schema.lotteryCash + 40;
				
				player:SetSharedVar("lottery", true);
				player.lottery = {numberOne, numberTwo, numberThree};
			else
				openAura.player:Notify(player, "You need another "..FORMAT_CASH(40 - openAura.player:GetCash(player), nil, true).."!");
			end;
		elseif (!lotteryTicket) then
			openAura.player:Notify(player, "The lottery is currently in progress, please wait!");
		else
			openAura.player:Notify(player, "You have already purchased a lottery ticket, please wait.");
		end;
	end;
end);

openAura:HookDataStream("UpdateBillboard", function(player, data)
	if (type(data) == "table") then
		local billboard = openAura.schema.billboards[data.id];
		local color = Color(255, 255, 255, 255);
		local title = string.sub(data.title or "", 0, 18);
		local text = string.sub(data.text or "", 0, 80);
		
		if (data.color) then
			color.r = data.color.r or 255;
			color.g = data.color.g or 255;
			color.b = data.color.b or 255;
		end;
		
		if (billboard) then
			if ( billboard.data and IsValid(billboard.data.owner) ) then
				if (billboard.data.owner == player) then
					billboard.data = {
						color = color,
						owner = player,
						title = title,
						text = text
					};
					
					openAura:StartDataStream( nil, "BillboardAdd", {id = data.id, data = billboard.data} );
				end;
			else
				if ( openAura.player:CanAfford(player, 60) ) then
					billboard.uniqueID = player:UniqueID();
					billboard.data = {
						owner = player,
						color = color,
						title = title,
						text = text
					};
					billboard.key = player:QueryCharacter("key");
					
					openAura:StartDataStream( nil, "BillboardAdd", {id = data.id, data = billboard.data} );
					
					openAura.player:GiveCash(player, -60, "purchasing a billboard");
				else
					openAura.player:Notify(player, "You need another "..FORMAT_CASH(60 - openAura.player:GetCash(player), nil, true).."!");
				end;
			end;
		end;
	end;
end);

openAura:HookDataStream("JoinAlliance", function(player, data)
	if (player.allianceAuthenticate == data) then
		player:SetCharacterData("leader", nil);
		player:SetCharacterData("alliance", data);
		
		openAura.player:Notify(player, "You have joined the '"..data.."' alliance.");
	end;
end);

openAura:HookDataStream("Notepad", function(player, data)
	if ( type(data) == "string" and player:HasItem("notepad") ) then
		player:SetCharacterData( "notepad", string.sub(data, 0, 500) );
	end;
end);

openAura:HookDataStream("CreateAlliance", function(player, data)
	if (type(data) == "string") then
		local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
		local schemaFolder = openAura:GetSchemaFolder();
		local alliance = tmysql.escape( string.gsub(string.sub(data, 1, 32), "[%p%d]", "") );
		
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Data LIKE \"%\\\"alliance\\\":\\\""..alliance.."\\\"\"%", function(result)
			if ( IsValid(player) ) then
				if (result and type(result) == "table" and #result > 0) then
					openAura.player:Notify(player, "An alliance with the name '"..alliance.."' already exists!");
				else
					player:SetCharacterData("leader", true);
					player:SetCharacterData("alliance", alliance);
					
					openAura.player:Notify(player, "You have created the '"..alliance.."' alliance.");
				end;
			end;
		end, 1);
	end;
end);

-- A function to load the radios.
function openAura.schema:LoadRadios()
	local radios = openAura:RestoreSchemaData( "plugins/radios/"..game.GetMap() );
	
	for k, v in pairs(radios) do
		local entity;
		
		if (v.frequency) then
			entity = ents.Create("aura_radio");
		else
			entity = ents.Create("aura_broadcaster");
		end;
		
		openAura.player:GivePropertyOffline(v.key, v.uniqueID, entity);
		
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if ( IsValid(entity) ) then
			entity:SetOff(v.off);
			
			if (v.frequency) then
				entity:SetFrequency(v.frequency);
			end;
		end;
		
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the radios.
function openAura.schema:SaveRadios()
	local radios = {};
	
	for k, v in pairs( ents.FindByClass("aura_radio") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if ( IsValid(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:IsOff(),
			key = openAura.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			frequency = v:GetSharedVar("frequency")
		};
	end;
	
	for k, v in pairs( ents.FindByClass("aura_broadcaster") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if ( IsValid(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		radios[#radios + 1] = {
			off = v:IsOff(),
			key = openAura.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	openAura:SaveSchemaData("plugins/radios/"..game.GetMap(), radios);
end;

-- A function to make an explosion.
function openAura.schema:MakeExplosion(position, scale)
	local explosionEffect = EffectData();
	local smokeEffect = EffectData();
	
	explosionEffect:SetOrigin(position);
	explosionEffect:SetScale(scale);
	smokeEffect:SetOrigin(position);
	smokeEffect:SetScale(scale);
	
	util.Effect("explosion", explosionEffect, true, true);
	util.Effect("aura_effect_smoke", smokeEffect, true, true);
end;

-- A function to get a player's location.
function openAura.schema:PlayerGetLocation(player)
	local areaNames = openAura.plugin:Get("Area Names");
	local closest;
	
	if (areaNames) then
		for k, v in pairs(areaNames.areaNames) do
			if ( openAura.entity:IsInBox(player, v.minimum, v.maximum) ) then
				if (string.sub(string.lower(v.name), 1, 4) == "the ") then
					return string.sub(v.name, 5);
				else
					return v.name;
				end;
			else
				local distance = player:GetShootPos():Distance(v.minimum);
				
				if ( !closest or distance < closest[1] ) then
					closest = {distance, v.name};
				end;
			end;
		end;
		
		if (!completed) then
			if (closest) then
				if (string.sub(string.lower( closest[2] ), 1, 4) == "the ") then
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
function openAura.schema:LoadLotteryCash()
	self.lotteryCash = openAura:RestoreSchemaData("lottery");
	
	if ( !tonumber(self.lotteryCash) ) then
		self.lotteryCash = 0;
	end;
end;

-- A function to save the lottery cash.
function openAura.schema:SaveLotteryCash()
	openAura:SaveSchemaData("lottery", self.lotteryCash);
end;

-- A function to make a player wear clothes.
function openAura.schema:PlayerWearClothes(player, itemTable)
	local clothes = player:GetCharacterData("clothes");
	local team = player:Team();
	
	if (itemTable) then
		if (team != CLASS_PRESIDENT and team != CLASS_SECRETARY) then
			itemTable:OnChangeClothes(player, true);
			
			player:SetCharacterData("clothes", itemTable.index);
			player:SetSharedVar("clothes", itemTable.index);
		end;
	else
		itemTable = openAura.item:Get(clothes);
		
		if (itemTable) then
			itemTable:OnChangeClothes(player, false);
			
			player:SetCharacterData("clothes", nil);
			player:SetSharedVar("clothes", 0);
		end;
	end;
	
	if (itemTable) then
		player:UpdateInventory(itemTable.uniqueID);
	end;
end;

-- A function to get a player's heal amount.
function openAura.schema:GetHealAmount(player, scale)
	local medical = openAura.attributes:Fraction(player, ATB_MEDICAL, 35);
	local healAmount = (15 + medical) * (scale or 1);
	
	return healAmount;
end;

-- A function to get a player's dexterity time.
function openAura.schema:GetDexterityTime(player)
	return 7 - openAura.attributes:Fraction(player, ATB_DEXTERITY, 5, 5);
end;

-- A function to get whether a player has won the lottery.
function openAura.schema:HasWonLottery(player, numbers, winningNumbers)
	local correctNumbers = 0;
	local numbersCopy = table.Copy(winningNumbers);
	
	for i = 1, 3 do
		for o = 1, 3 do
			if ( numbers[i] == numbersCopy[o] ) then
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
function openAura.schema:SendCrimes(player)
	player:SetSharedVar( "crimes", glon.encode(player:GetCharacterData("stars").crimes) );
end;

-- A function to give a player a star.
function openAura.schema:GivePlayerStar(player, crime)
	if (openAura.player:GetFaction(player) != FACTION_POLICE) then
		local stars = player:GetCharacterData("stars");
		local hasValue = (stars.crimes[crime] != nil);
		local increase = 1;
		
		if (crime == CRIME_MURDER) then
			increase = 4;
		elseif (crime == CRIME_WEAPON) then
			increase = 3;
		end;
		
		if ( (crime != CRIME_WEAPON and crime != CRIME_ASSAULT) or !hasValue ) then
			stars.stars = math.min(stars.stars + increase, 5);
			stars.crimes[crime] = (stars.crimes[crime] or 0) + 1;
			stars.clearTime = os.clock() + 1200;
			
			umsg.Start("aura_GiveStar", player);
				umsg.Short(crime);
			umsg.End();
			
			player:SetSharedVar("stars", stars.stars);
			self:SendCrimes(player);
		end;
	end;
end;

-- A function to bust down a door.
function openAura.schema:BustDownDoor(player, door, force)
	door.bustedDown = true;
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	local fakeDoor = ents.Create("prop_physics");
	
	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
	fakeDoor:SetAngles( door:GetAngles() );
	fakeDoor:SetModel( door:GetModel() );
	fakeDoor:SetSkin( door:GetSkin() );
	fakeDoor:SetPos( door:GetPos() );
	fakeDoor:Spawn();
	
	local physicsObject = fakeDoor:GetPhysicsObject();
	
	if ( IsValid(physicsObject) ) then
		if (!force) then
			if ( IsValid(player) ) then
				physicsObject:ApplyForceCenter( ( door:GetPos() - player:GetPos() ):Normalize() * 10000 );
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	openAura.entity:Decay(fakeDoor, 300);
	
	openAura:CreateTimer("reset_door_"..door:EntIndex(), 300, 1, function()
		if ( IsValid(door) ) then
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
			door.bustedDown = nil;
		end;
	end);
end;

-- A function to load the belongings.
function openAura.schema:LoadBelongings()
	local belongings = openAura:RestoreSchemaData( "plugins/belongings/"..game.GetMap() );
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("aura_belongings");
		
		if ( v.inventory["human_meat"] ) then
			v.inventory["human_meat"] = nil;
		end;
		
		entity:SetAngles(v.angles);
		entity:SetData(v.inventory, v.cash);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the belongings.
function openAura.schema:SaveBelongings()
	local belongings = {};
	
	for k, v in pairs( ents.FindByClass("prop_ragdoll") ) do
		if (v.areBelongings) then
			if (v.cash > 0 or table.Count(v.inventory) > 0) then
				belongings[#belongings + 1] = {
					cash = v.cash,
					angles = Angle(0, 0, -90),
					moveable = true,
					position = v:GetPos() + Vector(0, 0, 32),
					inventory = v.inventory
				};
			end;
		end;
	end;
	
	for k, v in pairs( ents.FindByClass("aura_belongings") ) do
		if ( v.cash and v.inventory and (v.cash > 0 or table.Count(v.inventory) > 0) ) then
			local physicsObject = v:GetPhysicsObject();
			local moveable;
			
			if ( IsValid(physicsObject) ) then
				moveable = physicsObject:IsMoveable();
			end;
			
			belongings[#belongings + 1] = {
				cash = v.cash,
				angles = v:GetAngles(),
				moveable = moveable,
				position = v:GetPos(),
				inventory = v.inventory
			};
		end;
	end;
	
	openAura:SaveSchemaData("plugins/belongings/"..game.GetMap(), belongings);
end;

-- A function to make a player drop random items.
function openAura.schema:PlayerDropRandomItems(player, ragdoll)
	local defaultModel = openAura.player:GetDefaultModel(player);
	local defaultSkin = openAura.player:GetDefaultSkin(player);
	local inventory = openAura.player:GetInventory(player);
	local clothes = player:GetCharacterData("clothes");
	local model = player:GetModel();
	local cash = openAura.player:GetCash(player);
	local info = {
		inventory = {},
		cash = cash
	};
	
	if ( !IsValid(ragdoll) ) then
		info.entity = ents.Create("aura_belongings");
	end;
	
	for k, v in pairs(inventory) do
		local itemTable = openAura.item:Get(k);
		
		if (itemTable and itemTable.allowStorage != false
		and !itemTable.isRareItem) then
			local success, fault = player:UpdateInventory(k, -v, true, true);
			
			if (success) then
				info.inventory[k] = v;
			end;
		end;
	end;
	
	player:SetCharacterData("cash", 0, true);
	
	if ( !IsValid(ragdoll) ) then
		if (table.Count(info.inventory) > 0 or info.cash > 0) then
			info.entity:SetAngles( Angle(0, 0, -90) );
			info.entity:SetData(info.inventory, info.cash);
			info.entity:SetPos( player:GetPos() + Vector(0, 0, 48) );
			info.entity:Spawn();
		else
			info.entity:Remove();
		end;
	else
		if (ragdoll:GetModel() != model) then
			ragdoll:SetModel(model);
		end;
		
		ragdoll.areBelongings = true;
		ragdoll.clothesData = {clothes, defaultModel, defaultSkin};
		ragdoll.inventory = info.inventory;
		ragdoll.cash = info.cash;
	end;
	
	if ( openAura.config:Get("using_life_system"):Get() ) then
		player:SetCharacterData("dead", true);
	end;
	
	openAura.player:SaveCharacter(player);
end;

-- A function to tie or untie a player.
function openAura.schema:TiePlayer(player, isTied, reset, government)
	if (isTied) then
		if (government) then
			player:SetSharedVar("tied", 2);
		else
			player:SetSharedVar("tied", 1);
		end;
	else
		player:SetSharedVar("tied", 0);
	end;
	
	if (isTied) then
		openAura.player:DropWeapons(player);
		openAura:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.");
		
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if ( player:Alive() and !player:IsRagdolled() ) then 
			openAura.player:LightSpawn(player, true, true);
		end;
		
		openAura:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.");
	end;
end;