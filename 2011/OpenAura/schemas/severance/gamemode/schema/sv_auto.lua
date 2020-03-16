--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vtf");
resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vmt");
resource.AddFile("models/weapons/v_sledgehammer/v_sledgehammer.mdl");
resource.AddFile("materials/vgui/entities/aura_zombie.vtf");
resource.AddFile("materials/vgui/entities/aura_zombie.vmt");
resource.AddFile("resource/fonts/nu_century_gothic.ttf");
resource.AddFile("models/weapons/v_shovel/v_shovel.mdl");
resource.AddFile("materials/models/weapons/sledge.vtf");
resource.AddFile("materials/models/weapons/sledge.vmt");
resource.AddFile("materials/models/weapons/shovel.vtf");
resource.AddFile("materials/models/weapons/shovel.vmt");
resource.AddFile("materials/models/weapons/axe.vtf");
resource.AddFile("materials/models/weapons/axe.vmt");
resource.AddFile("models/weapons/w_sledgehammer.mdl");
resource.AddFile("models/weapons/v_plank/v_plank.mdl");
resource.AddFile("models/weapons/v_axe/v_axe.mdl");
resource.AddFile("models/weapons/w_remingt.mdl");
resource.AddFile("models/weapons/v_remingt.mdl");
resource.AddFile("models/weapons/w_shovel.mdl");
resource.AddFile("models/weapons/w_plank.mdl");
resource.AddFile("models/weapons/w_remingt.mdl");
resource.AddFile("models/weapons/v_remingt.mdl");
resource.AddFile("models/weapons/w_axe.mdl");
resource.AddFile("models/sprayca2.mdl");

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/apocal*.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/apocal*.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/bloocobalt/clothes/*.*") ) do
	resource.AddFile("materials/models/bloocobalt/clothes/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/pmc/pmc_shared/*.*") ) do
	resource.AddFile("materials/models/pmc/pmc_shared/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/weapons/ashotgunskin1/*.*") ) do
	resource.AddFile("materials/models/weapons/ashotgunskin1/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/pmc/pmc_4/*.*") ) do
	resource.AddFile("materials/models/pmc/pmc_4/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/zed/male/*.*") ) do
	resource.AddFile("materials/models/zed/male/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/lagmite/*.*") ) do
	resource.AddFile("materials/models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/spraycan3.*") ) do
	resource.AddFile("materials/models/"..v);
end;

for k, v in pairs( _file.Find("../materials/severance/*.*") ) do
	resource.AddFile("materials/severance/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/deadbodies/*.*") ) do
	resource.AddFile("materials/models/deadbodies/"..v);
end;

for k, v in pairs( _file.Find("../models/bloocobalt/clothes/*.*") ) do
	resource.AddFile("models/bloocobalt/clothes/"..v);
end;

for k, v in pairs( _file.Find("../models/deadbodies/*.*") ) do
	resource.AddFile("models/deadbodies/"..v);
end;

for k, v in pairs( _file.Find("../models/lagmite/*.*") ) do
	resource.AddFile("models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../sound/runner/*.*") ) do
	resource.AddFile("sound/runner/"..v);
end;

for k, v in pairs( _file.Find("../models/zed/*.*") ) do
	resource.AddFile("models/zed/"..v);
end;

for k, v in pairs( _file.Find("../models/pmc/pmc_4/*.mdl") ) do
	resource.AddFile("models/pmc/pmc_4/"..v);
end;

local groups = {34, 35, 36, 37, 38, 39, 40, 41};

for k, v in pairs(groups) do
	local groupName = "group"..v;
	
	for k2, v2 in pairs( _file.Find("../models/humans/"..groupName.."/*.*") ) do
		resource.AddFile("models/humans/"..groupName.."/"..v2);
	end;
end;

openAura.config:Add("intro_text_small", "The dead walk the streets.", true);
openAura.config:Add("intro_text_big", "THE CITY OF LONDON, 2013.", true);

openAura.config:Get("enable_gravgun_punt"):Set(false);
openAura.config:Get("default_inv_weight"):Set(5);
openAura.config:Get("enable_crosshair"):Set(false);
openAura.config:Get("disable_sprays"):Set(false);
openAura.config:Get("cash_enabled"):Set(false, nil, true);
openAura.config:Get("door_cost"):Set(0);

openAura.hint:Add("Admins", "The admins are here to help you, please respect them.");
openAura.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
openAura.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
openAura.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
openAura.hint:Add("F4 Hotkey", "Press F3 while looking at a tied character to search them.");
openAura.hint:Add("Metagaming", "Metagaming is when you use OOC information in-character.");
openAura.hint:Add("Development", "Develop your character, give them a story to tell.");
openAura.hint:Add("Powergaming", "Powergaming is when you force your actions on others.");

openAura:HookDataStream("ObjectPhysDesc", function(player, data)
	if (type(data) == "table" and type( data[1] ) == "string") then
		if ( player.objectPhysDesc == data[2] ) then
			local physDesc = data[1];
			
			if (string.len(physDesc) > 80) then
				physDesc = string.sub(physDesc, 1, 80).."...";
			end;
			
			data[2]:SetNetworkedString("physDesc", physDesc);
		end;
	end;
end);

-- A function to load the radios.
function openAura.schema:LoadRadios()
	local radios = openAura:RestoreSchemaData( "plugins/radios/"..game.GetMap() );
	
	for k, v in pairs(radios) do
		local entity;
		
		if (v.frequency) then
			entity = ents.Create("aura_radio");
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

-- A function to load the belongings.
function openAura.schema:LoadBelongings()
	local belongings = openAura:RestoreSchemaData( "plugins/belongings/"..game.GetMap() );
	
	for k, v in pairs(belongings) do
		local entity = ents.Create("aura_belongings");
		
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
		if (v.areBelongings and v.cash and v.inventory) then
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
	
	openAura:SaveSchemaData("plugins/radios/"..game.GetMap(), radios);
end;

-- A function to permanently kill a player.
function openAura.schema:PermaKillPlayer(player, ragdoll)
	if ( player:Alive() ) then
		player:Kill(); ragdoll = player:GetRagdollEntity();
	end;
	
	local inventory = openAura.player:GetInventory(player);
	local cash = openAura.player:GetCash(player);
	local info = {};
	
	if ( !player:GetCharacterData("permakilled") ) then
		info.inventory = inventory;
		info.cash = cash;
		
		if ( !IsValid(ragdoll) ) then
			info.entity = ents.Create("aura_belongings");
		end;
		
		openAura.plugin:Call("PlayerAdjustPermaKillInfo", player, info);
		
		for k, v in pairs(info.inventory) do
			local itemTable = openAura.item:Get(k);
			
			if (itemTable and itemTable.allowStorage == false) then
				info.inventory[k] = nil;
			end;
		end;
		
		player:SetCharacterData("inventory", {}, true);
		player:SetCharacterData("cash", 0, true);
		player:SetCharacterData("permakilled", true);
		
		if ( !IsValid(ragdoll) ) then
			if (table.Count(info.inventory) > 0 or info.cash > 0) then
				info.entity:SetData(info.inventory, info.cash);
				info.entity:SetPos( player:GetPos() + Vector(0, 0, 48) );
				info.entity:Spawn();
			else
				info.entity:Remove();
			end;
		else
			ragdoll.areBelongings = true;
			ragdoll.inventory = info.inventory;
			ragdoll.cash = info.cash;
		end;
		
		openAura.player:SaveCharacter(player);
	end;
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

-- A function to make a player wear clothes.
function openAura.schema:PlayerWearClothes(player, itemTable, noMessage)
	local clothes = player:GetCharacterData("clothes");
	
	if (itemTable) then
		local model = openAura.class:GetAppropriateModel(player:Team(), player, true);
		
		if (!model) then
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

-- A function to bust down a door.
function openAura.schema:BustDownDoor(player, door, force)
	door.bustedDown = true;
	
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	if ( IsValid(door.breach) ) then
		door.breach:BreachEntity();
	end;
	
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
				physicsObject:ApplyForceCenter( (door:GetPos() - player:GetPos() ):Normalize() * 10000 );
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	openAura.entity:Decay(fakeDoor, 300);
	
	openAura:CreateTimer("reset_door_"..door:EntIndex(), 300, 1, function()
		if ( IsValid(door) ) then
			door.bustedDown = nil;
			
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
		end;
	end);
end;

-- A function to tie or untie a player.
function openAura.schema:TiePlayer(player, isTied, reset)
	if (isTied) then
		player:SetSharedVar("tied", 1);
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