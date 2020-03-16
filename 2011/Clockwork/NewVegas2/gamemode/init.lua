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

-- A function to load the trash spawns.
function Schema:LoadTrashSpawns()
	self.trashSpawns = Clockwork:RestoreSchemaData("plugins/trash/"..game.GetMap());
	
	if (!self.trashSpawns) then
		self.trashSpawns = {};
	end;
end;

-- A function to get a random trash spawn.
function Schema:GetRandomTrashSpawn()
	local position = self.trashSpawns[math.random(1, #self.trashSpawns)];
	local players = _player.GetAll();
	
	for k, v in ipairs(players) do
		if (v:HasInitialized() and v:GetPos():Distance(position) <= 1024) then
			if (!Clockwork.player:IsNoClipping(v)) then
				return self:GetRandomTrashSpawn();
			end;
		end;
	end;
	
	return position;
end;

-- A function to get a random trash item.
function Schema:GetRandomTrashItem()
	local trashItem = self.trashItems[math.random(1, #self.trashItems)];
	
	if (trashItem and math.random() <= (1 / (trashItem.worth * 2))) then
		return trashItem;
	else
		return self:GetRandomTrashItem();
	end;
end;

-- A function to save the trash spawns.
function Schema:SaveTrashSpawns()
	Clockwork:SaveSchemaData("plugins/trash/"..game.GetMap(), self.trashSpawns);
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

-- A function to get a player's heal amount.
function Schema:GetHealAmount(player, scale)
	return 15 * (scale or 1);
end;

-- A function to get a player's dexterity time.
function Schema:GetDexterityTime(player)
	return 7;
end;

resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vtf");
resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vmt");
resource.AddFile("models/weapons/v_sledgehammer/v_sledgehammer.mdl");
resource.AddFile("materials/models/weapons/v_katana/katana.vtf");
resource.AddFile("materials/models/weapons/v_katana/katana.vmt");
resource.AddFile("models/weapons/v_shovel/v_shovel.mdl");
resource.AddFile("models/weapons/v_axe/v_axe.mdl");
resource.AddFile("materials/models/weapons/sledge.vtf");
resource.AddFile("materials/models/weapons/sledge.vmt");
resource.AddFile("materials/models/weapons/shovel.vtf");
resource.AddFile("materials/models/weapons/shovel.vmt");
resource.AddFile("materials/models/weapons/axe.vtf");
resource.AddFile("materials/models/weapons/axe.vmt");
resource.AddFile("models/weapons/w_sledgehammer.mdl");
resource.AddFile("models/quake4pm/quakencr.mdl");
resource.AddFile("models/weapons/w_remingt.mdl");
resource.AddFile("models/weapons/v_remingt.mdl");
resource.AddFile("models/power_armor/slow.mdl");
resource.AddFile("models/weapons/w_katana.mdl");
resource.AddFile("models/weapons/v_katana.mdl");
resource.AddFile("models/weapons/w_shovel.mdl");
resource.AddFile("models/tactical_rebel.mdl");
resource.AddFile("resource/fonts/spranq.ttf");
resource.AddFile("models/weapons/w_axe.mdl");
resource.AddFile("models/ghoul/slow.mdl");
resource.AddFile("sound/way_back_home.mp3");

for k, v in pairs(_file.Find("../materials/models/player/slow/fallout_3/power_armor/*.*")) do
	resource.AddFile("materials/models/player/slow/fallout_3/power_armor/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group03/caesars_sheet.*")) do
	resource.AddFile("materials/models/humans/female/group03/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group03/caesars_sheet.*")) do
	resource.AddFile("materials/models/humans/male/group03/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/female/group01/apoca*.*")) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/slow/fallout_3/ghoul/*.*")) do
	resource.AddFile("materials/models/player/slow/fallout_3/ghoul/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/humans/male/group01/apoca*.*")) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/gasmask/tac_rbe/*.*")) do
	resource.AddFile("materials/models/gasmask/tac_rbe/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/player/ncrs/*.*")) do
	resource.AddFile("materials/models/player/ncrs/"..v);
end;

for k, v in pairs(_file.Find("../materials/cwNewVegas/*.*")) do
	resource.AddFile("materials/cwNewVegas/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/deadbodies/*.*")) do
	resource.AddFile("materials/models/deadbodies/"..v);
end;

for k, v in pairs(_file.Find("../materials/models/nukacola/*.*")) do
	resource.AddFile("materials/models/nukacola/"..v);
end;

for k, v in pairs(_file.Find("../models/deadbodies/*.*")) do
	resource.AddFile("models/deadbodies/"..v);
end;

for k, v in pairs(_file.Find("../models/nukacola/*.*")) do
	resource.AddFile("models/nukacola/"..v);
end;

for k, v in pairs({34, 37, 38, 40, 41, 42, 43, 51}) do
	local groupName = "group"..v;
	
	for k2, v2 in pairs(_file.Find("../models/humans/"..groupName.."/*.*")) do
		resource.AddFile("models/humans/"..groupName.."/"..v2);
	end;
end;

Clockwork.config:Add("intro_text_small", "What happens in Vegas... stays in Vegas.", true);
Clockwork.config:Add("intro_text_big", "NEW VEGAS, 2280.", true);

Clockwork.config:Get("enable_gravgun_punt"):Set(false);
Clockwork.config:Get("default_inv_weight"):Set(2);
Clockwork.config:Get("enable_crosshair"):Set(false);
Clockwork.config:Get("scale_prop_cost"):Set(0);
Clockwork.config:Get("default_cash"):Set(20);
Clockwork.config:Get("door_cost"):Set(10);

Clockwork.hint:Add("Staff", "The staff are here to help you, please respect them.");
Clockwork.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
Clockwork.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
Clockwork.hint:Add("Wasteland", "Bored and alone in the wasteland? Travel with a friend.");
Clockwork.hint:Add("Metagaming", "Metagaming is when you use out-of-character information in-character.");
Clockwork.hint:Add("Development", "Develop your character, give them a story to tell.");
Clockwork.hint:Add("Powergaming", "Powergaming is when you force your actions on others.");

Clockwork:HookDataStream("ObjectPhysDesc", function(player, data)
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

--[[
	The schema must be registered so that the kernel information
	can be included (entities, effects, weapons, etc). This must
	be done at the end of the init.lua and cl_init.lua files.
--]]

Clockwork.plugin:Register(Schema);