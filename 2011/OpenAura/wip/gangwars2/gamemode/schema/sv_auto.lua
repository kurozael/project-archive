--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua");

resource.AddFile("materials/achievements/achieved.vtf");
resource.AddFile("materials/achievements/achieved.vmt");
resource.AddFile("materials/upgrades/purchased.vtf");
resource.AddFile("materials/upgrades/purchased.vmt");
resource.AddFile("resource/fonts/sketch.ttf");

for k, v in pairs( _file.Find("../materials/models/player/slow/napalm_atc/*.*") ) do
	resource.AddFile("materials/models/player/slow/napalm_atc/"..v);
end;

for k, v in pairs( _file.Find("../materials/gangwars2/classes/*.*") ) do
	resource.AddFile("materials/gangwars2/classes/"..v);
end;

for k, v in pairs( _file.Find("../materials/gangwars2/gangs/*.*") ) do
	resource.AddFile("materials/gangwars2/gangs/"..v);
end;

for k, v in pairs( _file.Find("../models/napalm_atc/*.mdl") ) do
	resource.AddFile("models/napalm_atc/"..v);
end;

for k, v in pairs( _file.Find("../materials/achievements/*.*") ) do
	resource.AddFile("materials/achievements/"..v);
end;

for k, v in pairs( _file.Find("../materials/gangwars2/*.*") ) do
	resource.AddFile("materials/gangwars2/"..v);
end;

for k, v in pairs( _file.Find("../materials/upgrades/*.*") ) do
	resource.AddFile("materials/upgrades/"..v);
end;

openAura.hint:Remove("F2 Hotkey");
openAura.hint:Remove("Raise Weapon");

openAura.hint:Add("Kick down a door by using it whilst you are sprinting.");

openAura.config:Add("intro_text_small", "in the future, gangs have taken over", true);
openAura.config:Add("intro_text_big", "JAPAN, 2081", true);

openAura.config:Get("raised_weapon_system"):Set(false);
openAura.config:Get("enable_gravgun_punt"):Set(false);
openAura.config:Get("default_inv_weight"):Set(10);
openAura.config:Get("recognise_system"):Set(false);
openAura.config:Get("enable_crosshair"):Set(false);
openAura.config:Get("minimum_physdesc"):Set(24);
openAura.config:Get("scale_prop_cost"):Set(0.2);
openAura.config:Get("scale_head_dmg"):Set(2);
openAura.config:Get("disable_sprays"):Set(false);
openAura.config:Get("wages_interval"):Set(360);
openAura.config:Get("default_flags"):Set("p");
openAura.config:Get("default_cash"):Set(200);
openAura.config:Get("minute_time"):Set(1);
openAura.config:Get("give_hands"):Set(false);
openAura.config:Get("give_keys"):Set(false);

openAura:HookDataStream("SetTitle", function(player, data)
	if (type(data) == "string") then
		local achievementTable = openAura.achievement:Get(data);
		
		if (achievementTable and achievementTable.unlockTitle) then
			if ( openAura.achievements:Has(player, data) ) then
				player:SetCharacterData("title", achievementTable.uniqueID);
				openAura.player:Notify(player, "You have set your title to "..string.Replace( achievementTable.unlockTitle, "%n", player:Name() )..".");
			end;
		end;
	end;
end);

openAura:HookDataStream("GetUpgrade", function(player, data)
	local upgradeTable = openAura.upgrade:Get(data);
	
	if (upgradeTable) then
		if ( openAura.player:CanAfford(player, upgradeTable.cost) ) then
			if ( !openAura.upgrades:Has(player, upgradeTable.uniqueID) ) then
				openAura.upgrades:Give(player, upgradeTable.uniqueID);
				
				openAura.player:GiveCash(player, -upgradeTable.cost, upgradeTable.name);
				openAura.player:Notify(player, "You have gotten the '"..upgradeTable.name.."' upgrade.");
			end;
		else
			openAura.player:Notify(player, "You need another "..FORMAT_CASH(upgradeTable.cost - openAura.player:GetCash(player), nil, true).."!");
		end;
	end;
end);

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

-- A function to get a player's weapons.
function openAura.schema:GetWeapons(player)
	local team = player:Team();
	
	if (team == CLASS_ASSAULT) then
		return { {"rcs_sg552", "smg1", 512}, {"rcs_glock", "pistol", 768}, {"aura_smokegrenade", "grenade", 3} };
	elseif (team == CLASS_POINTMAN) then
		return {"aura_stealthcamo", {"rcs_glock", "pistol", 768}, {"aura_smokegrenade", "grenade", 3}, "aura_knife"};
	elseif (team == CLASS_MARKSMAN) then
		return {"aura_thermalvision", "rcs_scout", "aura_knife"};
	elseif (team == CLASS_MEDIC) then
		return { {"rcs_m3", "buckshot", 256}, {"rcs_glock", "pistol", 768}, "aura_bandage"};
	elseif (team == CLASS_SUPPORT) then
		return { {"rcs_spas12", "buckshot", 256}, {"rcs_glock", "pistol", 256}, {"aura_flashgrenade", "grenade", 3}, "aura_wrench"};
	end;
end;

-- A function to spawn a flash.
function openAura.schema:SpawnFlash(position)
	local effectData = EffectData();
	local curTime = CurTime();
	
	effectData:SetStart(position);
	effectData:SetOrigin(position);
	effectData:SetScale(16);
	
	util.Effect("Explosion", effectData, true, true);
	
	local effectData = EffectData();
		effectData:SetOrigin(position);
		effectData:SetScale(2);
	util.Effect("aura_effect_smoke", effectData, true, true);
	
	for k, v in ipairs( _player.GetAll() ) do
		if (v:HasInitialized() and v:GetPos():Distance(position) <= 768) then
			if ( openAura.player:CanSeePosition(v, position, 0.9, true) ) then
				umsg.Start("aura_Flashed", v);
				umsg.End();
			end;
		end;
	end;
end;

-- A function to get a player's heal amount.
function openAura.schema:GetHealAmount(player, scale)
	return 15;
end;

-- A function to bust down a door.
function openAura.schema:BustDownDoor(player, door, force)
	door.canNotBeOpened = true;
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
			door.canNotBeOpened = nil;
		end;
	end);
end;