--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.kernel:AddFile("materials/models/weapons/temptexture/handsmesh1.vtf");
Clockwork.kernel:AddFile("materials/models/weapons/temptexture/handsmesh1.vmt");
Clockwork.kernel:AddFile("models/weapons/v_sledgehammer/v_sledgehammer.mdl");
Clockwork.kernel:AddFile("materials/vgui/entities/csZombie.vtf");
Clockwork.kernel:AddFile("materials/vgui/entities/csZombie.vmt");
Clockwork.kernel:AddFile("resource/fonts/nu_century_gothic.ttf");
Clockwork.kernel:AddFile("models/weapons/v_shovel/v_shovel.mdl");
Clockwork.kernel:AddFile("materials/models/weapons/sledge.vtf");
Clockwork.kernel:AddFile("materials/models/weapons/sledge.vmt");
Clockwork.kernel:AddFile("materials/models/weapons/shovel.vtf");
Clockwork.kernel:AddFile("materials/models/weapons/shovel.vmt");
Clockwork.kernel:AddFile("materials/models/weapons/axe.vtf");
Clockwork.kernel:AddFile("materials/models/weapons/axe.vmt");
Clockwork.kernel:AddFile("models/weapons/w_sledgehammer.mdl");
Clockwork.kernel:AddFile("models/weapons/v_plank/v_plank.mdl");
Clockwork.kernel:AddFile("models/weapons/v_axe/v_axe.mdl");
Clockwork.kernel:AddFile("models/weapons/w_remingt.mdl");
Clockwork.kernel:AddFile("models/weapons/v_remingt.mdl");
Clockwork.kernel:AddFile("models/weapons/w_shovel.mdl");
Clockwork.kernel:AddFile("models/weapons/w_plank.mdl");
Clockwork.kernel:AddFile("models/weapons/w_remingt.mdl");
Clockwork.kernel:AddFile("models/weapons/v_remingt.mdl");
Clockwork.kernel:AddFile("models/weapons/w_axe.mdl");
Clockwork.kernel:AddFile("models/sprayca2.mdl");

Clockwork.kernel:AddDirectory("materials/models/humans/female/group01/apocal*.*");
Clockwork.kernel:AddDirectory("materials/models/humans/male/group01/apocal*.*");
Clockwork.kernel:AddDirectory("materials/models/bloocobalt/clothes/*.*");
Clockwork.kernel:AddDirectory("materials/models/pmc/pmc_shared/*.*");
Clockwork.kernel:AddDirectory("materials/models/weapons/ashotgunskin1/*.*");
Clockwork.kernel:AddDirectory("materials/models/pmc/pmc_4/*.*");
Clockwork.kernel:AddDirectory("materials/models/zed/male/*.*");
Clockwork.kernel:AddDirectory("materials/models/lagmite/*.*");
Clockwork.kernel:AddDirectory("materials/models/spraycan3.*");
Clockwork.kernel:AddDirectory("materials/severance/*.*");
Clockwork.kernel:AddDirectory("materials/models/deadbodies/*.*");
Clockwork.kernel:AddDirectory("models/bloocobalt/clothes/*.*");
Clockwork.kernel:AddDirectory("models/deadbodies/*.*");
Clockwork.kernel:AddDirectory("models/lagmite/*.*");
Clockwork.kernel:AddDirectory("sound/runner/*.*");
Clockwork.kernel:AddDirectory("models/zed/*.*");
Clockwork.kernel:AddDirectory("models/pmc/pmc_4/*.mdl");

Clockwork.config:Add("intro_text_small", "They walk the streets all over.", true);
Clockwork.config:Add("intro_text_big", "THE CITY OF THE DEAD, 2013.", true);

Clockwork.config:Get("enable_gravgun_punt"):Set(false);
Clockwork.config:Get("default_inv_weight"):Set(5);
Clockwork.config:Get("enable_crosshair"):Set(false);
Clockwork.config:Get("disable_sprays"):Set(false);
Clockwork.config:Get("cash_enabled"):Set(false, nil, true);
Clockwork.config:Get("door_cost"):Set(0);

Clockwork.config:Add("max_zombies", 10, true);
Clockwork.config:Add("max_spawn_interval", 120, true);
Clockwork.config:Add("min_spawn_interval", 60, true);
Clockwork.config:Add("hunger_interval", 180, true);
Clockwork.config:Add("energy_interval", 300, true);
Clockwork.config:Add("thirst_interval", 80, true);

Clockwork.hint:Add("Admins", "The admins are here to help you, please respect them.");
Clockwork.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
Clockwork.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
Clockwork.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
Clockwork.hint:Add("F4 Hotkey", "Press F3 while looking at a tied character to search them.");
Clockwork.hint:Add("Metagaming", "Metagaming is when you use OOC information in-character.");
Clockwork.hint:Add("Development", "Develop your character, give them a story to tell.");
Clockwork.hint:Add("Powergaming", "Powergaming is when you force your actions on others.");
Clockwork.hint:Add("Infected", "They aren't what they look like anymore, that creature that looks like your mother isn't her.");
Clockwork.hint:Add("Looting", "Find supplies for yourself or your group, you're going to need them.");
Clockwork.hint:Add("Weapons", "Finding something to hit something with is essential.");
Clockwork.hint:Add("Bitten", "Your friend get bitten? Put him out them out of their misery before you become victim too.");
Clockwork.hint:Add("Whoring", "Don't whore your skills, you're ment to grow your character naturally.");
Clockwork.hint:Add("Light", "Need a light? Try finding a flashlight or a lantern.");
Clockwork.hint:Add("Tough", "Trying to be tough? Don't. You'll find yourself dead quickly.");

local groups = {34, 35, 36, 37, 38, 39, 40, 41};

for k, v in pairs(groups) do
	local groupName = "group"..v;
	Clockwork.kernel:AddDirectory("models/humans/"..groupName.."/*.*");
end;

-- A function to load the radios.
function Severance:LoadRadios()
	local radios = Clockwork.kernel:RestoreSchemaData("plugins/radios/"..game.GetMap());
	
	for k, v in pairs(radios) do
		local entity = nil;
		
		if (v.frequency) then
			entity = ents.Create("cw_radio");
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

-- A function to load the belongings.
function Severance:LoadBelongings()
	local belongings = Clockwork.kernel:RestoreSchemaData("plugins/belongings/"..game.GetMap());
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("cw_belongings");
		
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
function Severance:SaveBelongings()
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
	
	Clockwork.kernel:SaveSchemaData("plugins/belongings/"..game.GetMap(), belongings);
end;

-- A function to save the radios.
function Severance:SaveRadios()
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
	
	Clockwork.kernel:SaveSchemaData("plugins/radios/"..game.GetMap(), radios);
end;

-- A function to permanently kill a player.
function Severance:PermaKillPlayer(player, ragdoll)
	if (player:Alive()) then
		player:Kill(); ragdoll = player:GetRagdollEntity();
	end;
	
	local inventory = player:GetInventory();
	local cash = player:GetCash();
	local info = {};
	
	if (!player:GetCharacterData("PermaKilled")) then
		info.inventory = inventory;
		info.cash = cash;
		
		if (!IsValid(ragdoll)) then
			info.entity = ents.Create("cw_belongings");
		end;
		
		Clockwork.plugin:Call("PlayerAdjustPermaKillInfo", player, info);
		
		for k, v in pairs(info.inventory) do
			local itemTable = Clockwork.item:FindByID(k);
			
			if (itemTable and itemTable("allowStorage") == false) then
				info.inventory[k] = nil;
			end;
		end;
		
		player:SetCharacterData("Inventory", {}, true);
		player:SetCharacterData("Cash", 0, true);
		player:SetCharacterData("PermaKilled", true);
		
		if (!IsValid(ragdoll)) then
			if (table.Count(info.inventory) > 0 or info.cash > 0) then
				info.entity:SetData(info.inventory, info.cash);
				info.entity:SetPos(player:GetPos() + Vector(0, 0, 48));
				info.entity:Spawn();
			else
				info.entity:Remove();
			end;
		else
			ragdoll.cwIsBelongings = true;
			ragdoll.inventory = info.inventory;
			ragdoll.cash = info.cash;
		end;
		
		Clockwork.player:SaveCharacter(player);
	end;
end;

-- A function to make an explosion.
function Severance:MakeExplosion(position, scale)
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
function Severance:PlayerGetLocation(player)
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

-- A function that toggles a character into and out of ghost mode.
function Severance:ToggleGhost(ply)
	if (ply:GetNetworkedVar("GhostMode", true)) then
		ply:SetNetworkedVar("GhostMode", false);
		ply:DrawWorldModel(true);
		ply:DrawShadow(true);
		ply:SetNoDraw(false);
		ply:SetSolid(SOLID_VPHYSICS)
		Clockwork.player:Notify(ply, "You have spawned in!");
	else
		local color = ply:GetColor();
		ply:SetNetworkedVar("GhostMode", true)
		ply:DrawWorldModel(false);
		ply:DrawShadow(false);
		ply:SetNoDraw(true);
		ply:SetSolid(SOLID_NONE)
		ply:SetColor(Color(color.r, color.g, color.b, 0));
	end;
end;

-- A function to get a player's heal amount.
function Severance:GetHealAmount(player, scale)
	local medical = Clockwork.attributes:Fraction(player, ATB_MEDICAL, 35);
	local healAmount = (15 + medical) * (scale or 1);
	
	return healAmount;
end;

-- A function to get a player's dexterity time.
function Severance:GetDexterityTime(player)
	return 7 - Clockwork.attributes:Fraction(player, ATB_DEXTERITY, 5, 5);
end;

-- A function to bust down a door.
function Severance:BustDownDoor(player, door, force)
	door.cwIsBustedDown = true;
	
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	if (IsValid(door.cwBreachEnt)) then
		door.cwBreachEnt:BreachEntity();
	end;
	
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
	
	Clockwork.kernel:CreateTimer("ResetDoor"..door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door.cwIsBustedDown = nil;
			
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
		end;
	end);
end;

-- A function to tie or untie a player.
function Severance:TiePlayer(player, isTied, reset)
	if (isTied) then
		player:SetSharedVar("IsTied", 1);
	else
		player:SetSharedVar("IsTied", 0);
	end;
	
	if (isTied) then
		Clockwork.player:DropWeapons(player);
		Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.");
		
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if (player:Alive() and !player:IsRagdolled()) then 
			Clockwork.player:LightSpawn(player, true, true);
		end;
		
		Clockwork.kernel:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.");
	end;
end;

Clockwork.datastream:Hook("ObjectPhysDesc", function(player, data)
	if (type(data) == "table" and type(data[1]) == "string") then
		if (player.cwObjectPhysDesc == data[2]) then
			local physDesc = data[1];
			
			if (string.len(physDesc) > 80) then
				physDesc = string.sub(physDesc, 1, 80).."...";
			end;
			
			data[2]:SetNetworkedString("PhysDesc", physDesc);
		end;
	end;
end);

--A function to check a player's hunger status.
function Severance:CheckHunger(player)
	local hungerdata = player:GetCharacterData("Hunger");
	local hungervar = player:GetSharedVar("Hunger");

	if (hungerdata != hungervar) then
		player:SetCharacterData("Hunger", hungervar);
	end;

	return hungervar;
end;

--A function to set a player's hunger.
function Severance:SetHunger(player, amount)
	player:SetCharacterData("Hunger", amount);
	player:SetSharedVar("Hunger", amount);
end;

--A function to check a player's thirst status.
function Severance:CheckThirst(player)
	local thirstdata = player:GetCharacterData("Thirst");
	local thirstvar = player:GetSharedVar("Thirst");

	if (thirstdata != thirstvar) then
		player:SetCharacterData("Thirst", thirstvar);
	end;

	return thirstvar;
end;

--A function to set a player's thirst.
function Severance:SetThirst(player, amount)
	player:SetCharacterData("Thirst", amount);
	player:SetSharedVar("Thirst", amount);
end;

--A function to check a player's energy status.
function Severance:CheckEnergy(player)
	local energydata = player:GetCharacterData("Energy");
	local energyvar = player:GetSharedVar("Energy");

	if (energydata != energyvar) then
		player:SetCharacterData("Energy", energyvar);
	end;

	return energyvar;
end;

--A function to set a player's energy.
function Severance:SetEnergy(player, amount)
	player:SetCharacterData("Energy", amount);
	player:SetSharedVar("Energy", amount);
end;