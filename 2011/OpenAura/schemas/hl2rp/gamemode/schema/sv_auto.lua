--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.schema.scannerSounds = {
	"npc/scanner/cbot_servochatter.wav",
	"npc/scanner/cbot_servoscared.wav",
	"npc/scanner/scanner_blip1.wav",
	"npc/scanner/scanner_scan1.wav",
	"npc/scanner/scanner_scan2.wav",
	"npc/scanner/scanner_scan4.wav",
	"npc/scanner/scanner_scan5.wav",
	"npc/scanner/combat_scan1.wav",
	"npc/scanner/combat_scan2.wav",
	"npc/scanner/combat_scan3.wav",
	"npc/scanner/combat_scan4.wav",
	"npc/scanner/combat_scan5.wav"
};
openAura.schema.scanners = {};
openAura.schema.cwuProps = {
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_interiors/furniture_vanity01a.mdl",
	"models/props_interiors/furniture_couch02a.mdl",
	"models/props_interiors/furniture_shelf01a.mdl",
	"models/props_interiors/furniture_chair01a.mdl",
	"models/props_interiors/furniture_desk01a.mdl",
	"models/props_interiors/furniture_lamp01a.mdl",
	"models/props_c17/furniturecupboard001a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"props/props_c17/furniturefridge001a.mdl",
	"models/props_c17/furniturestove001a.mdl",
	"models/props_interiors/radiator01a.mdl",
	"props/props_c17/furniturecouch001a.mdl",
	"models/props_combine/breenclock.mdl",
	"props/props_combine/breenchair.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"props/props_combine/breendesk.mdl",
	"models/props_lab/monitor01b.mdl",
	"models/props_lab/monitor01a.mdl",
	"models/props_lab/monitor02.mdl",
	"models/props_c17/frame002a.mdl",
	"models/props_c17/bench01a.mdl"
};

openAura:IncludePrefixed("sh_auto.lua");

resource.AddFile("resource/fonts/mailartrubberstamp.ttf");
resource.AddFile("models/eliteghostcp.mdl");
resource.AddFile("models/eliteshockcp.mdl");
resource.AddFile("models/policetrench.mdl");
resource.AddFile("models/leet_police2.mdl");
resource.AddFile("models/sect_police2.mdl");
resource.AddFile("models/sprayca2.mdl");

for k, v in pairs( _file.Find("../materials/models/humans/female/group01/cityadm_sheet.*") ) do
	resource.AddFile("materials/models/humans/female/group01/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/humans/male/group01/cityadm_sheet.*") ) do
	resource.AddFile("materials/models/humans/male/group01/"..v);
end;

for k, v in pairs( _file.Find("../models/humans/group17/*.mdl") ) do
	resource.AddFile("models/humans/group17/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/deadbodies/*.*") ) do
	resource.AddFile("materials/models/deadbodies/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/spraycan3.*") ) do
	resource.AddFile("materials/models/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/police/*.*") ) do
	resource.AddFile("materials/models/police/"..v);
end;

for k, v in pairs( _file.Find("../materials/models/lagmite/*.*") ) do
	resource.AddFile("materials/models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../materials/halfliferp/*.*") ) do
	resource.AddFile("materials/halfliferp/"..v);
end;

for k, v in pairs( _file.Find("../models/lagmite/*.*") ) do
	resource.AddFile("models/lagmite/"..v);
end;

for k, v in pairs( _file.Find("../models/deadbodies/*.*") ) do
	resource.AddFile("models/deadbodies/"..v);
end;

openAura.config:Add("server_whitelist_identity", "");
openAura.config:Add("combine_lock_overrides", false);
openAura.config:Add("intro_text_small", "It is safer here.", true);
openAura.config:Add("intro_text_big", "CITY EIGHTEEN, 2016.", true);
openAura.config:Add("knockout_time", 60);
openAura.config:Add("business_cost", 160, true);
openAura.config:Add("cwu_props", true);
openAura.config:Add("permits", true, true);

openAura.config:Get("enable_gravgun_punt"):Set(false);
openAura.config:Get("default_inv_weight"):Set(6);
openAura.config:Get("enable_crosshair"):Set(false);
openAura.config:Get("disable_sprays"):Set(false);
openAura.config:Get("prop_cost"):Set(false);
openAura.config:Get("door_cost"):Set(0);

-- A function to add a human hint.
function openAura.hint:AddHumanHint(name, text, combine)
	openAura.hint:Add(name, text, function(player)
		if (player) then
			return !openAura.schema:PlayerIsCombine(player, combine);
		end;
	end);
end;

openAura.hint:AddHumanHint("Life", "Your character is only human, refrain from jumping off high ledges.", false);
openAura.hint:AddHumanHint("Sleep", "Don't forget to sleep, your character does get tired.", false);
openAura.hint:AddHumanHint("Eating", "Just because you don't have to eat, it doesn't mean your character isn't hungry.", false);
openAura.hint:AddHumanHint("Friends", "Try to make some friends, misery loves company.", false);

openAura.hint:AddHumanHint("Curfew", "Curfew? Bored? Ask to be assigned a roommate.");
openAura.hint:AddHumanHint("Prison", "Don't do the crime if you're not prepared to do the time.");
openAura.hint:AddHumanHint("Rebels", "Don't chase the resistance, the Combine may group you together.");
openAura.hint:AddHumanHint("Talking", "The Combine don't like it when you talk, so whisper.");
openAura.hint:AddHumanHint("Rations", "Rations, they're bags filled with goodies. Behave.");
openAura.hint:AddHumanHint("Combine", "Don't mess with the Combine, they took over Earth in 7 hours.");
openAura.hint:AddHumanHint("Jumping", "Bunny hopping is uncivilized, and the Combine will remind you with their stunsticks.");
openAura.hint:AddHumanHint("Punching", "Got that feeling you just wanna punch somebody? Don't.");
openAura.hint:AddHumanHint("Compliance", "Obey the Combine, you'll be glad that you did.");
openAura.hint:AddHumanHint("Combine Raids", "When the Combine come knocking, get your ass on the floor.");
openAura.hint:AddHumanHint("Request Device", "Need to reach Civil Protection? Invest in a request device.");
openAura.hint:AddHumanHint("Civil Protection", "Civil Protection, protecting civilized society, not you.");

openAura.hint:Add("Admins", "The admins are here to help you, please respect them.");
openAura.hint:Add("Action", "Action. Stop looking for it, wait until it comes to you.");
openAura.hint:Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
openAura.hint:Add("Running", "Got somewhere to go? Fancy a run? Well don't, it's uncivilized.");
openAura.hint:Add("Healing", "You can heal players by using the Give command in your inventory.");
openAura.hint:Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
openAura.hint:Add("F4 Hotkey", "Press F3 while looking at a tied character to search them.");
openAura.hint:Add("Attributes", "Whoring *(name_attributes)* is a permanant ban, we don't recommend it.");
openAura.hint:Add("Firefights", "When engaged in a firefight, shoot to miss to make it enjoyable.");
openAura.hint:Add("Metagaming", "Metagaming is when you use OOC information in-character.");
openAura.hint:Add("Passive RP", "If you're bored and there's no action, try some passive roleplay.");
openAura.hint:Add("Development", "Develop your character, give them a story to tell.");
openAura.hint:Add("Powergaming", "Powergaming is when you force your actions on others.");

openAura:HookDataStream("EditObjectives", function(player, data)
	if (player.editObjectivesAuthorised and type(data) == "string") then
		if (openAura.schema.combineObjectives != data) then
			openAura.schema:AddCombineDisplayLine( "Downloading recent objectives...", Color(255, 100, 255, 255) );
			openAura.schema.combineObjectives = string.sub(data, 0, 500);
		end;
		
		player.editObjectivesAuthorised = nil;
	end;
end);

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

openAura:HookDataStream("EditData", function(player, data)
	if (player.editDataAuthorised == data[1] and type( data[2] ) == "string") then
		data[1]:SetCharacterData( "combinedata", string.sub(data[2], 0, 500) );
		
		player.editDataAuthorised = nil;
	end;
end);

-- A function to calculate a player's scanner think.
function openAura.schema:CalculateScannerThink(player, curTime)
	if ( !self.scanners[player] ) then return; end;
	
	local scanner = self.scanners[player][1];
	local marker = self.scanners[player][2];
	
	if ( IsValid(scanner) and IsValid(marker) ) then
		scanner:SetMaxHealth( player:GetMaxHealth() );
		
		player:SetMoveType(MOVETYPE_OBSERVER);
		player:SetHealth( math.max(scanner:Health(), 0) );
		
		if (!player.nextScannerSound or curTime >= player.nextScannerSound) then
			player.nextScannerSound = curTime + math.random(8, 48);
			
			scanner:EmitSound( self.scannerSounds[ math.random(1, #self.scannerSounds) ] );
		end;
	end;
end;

-- A function to reset a player's scanner.
function openAura.schema:ResetPlayerScanner(player, noMessage)
	if ( self.scanners[player] ) then
		local scanner = self.scanners[player][1];
		local marker = self.scanners[player][2];
		
		if ( IsValid(scanner) ) then
			scanner:Remove();
		end;
		
		if ( IsValid(marker) ) then
			marker:Remove();
		end;
		
		self.scanners[player] = nil;
		
		if (!noMessage) then
			player:SetMoveType(MOVETYPE_WALK);
			player:UnSpectate();
			player:KillSilent();
		end;
	end;
end;

-- A function to make a player a scanner.
function openAura.schema:MakePlayerScanner(player, noMessage, lightSpawn)
	self:ResetPlayerScanner(player, noMessage);
	
	local scannerClass = "npc_cscanner";
	
	if ( self:IsPlayerCombineRank(player, "SYNTH") ) then
		scannerClass = "npc_clawscanner";
	end;
	
	local position = player:GetShootPos();
	local uniqueID = player:UniqueID();
	local scanner = ents.Create(scannerClass);
	local marker = ents.Create("path_corner");
	
	openAura.entity:SetPlayer(scanner, player);
	
	scanner:SetPos( position + Vector(0, 0, 16) );
	scanner:SetAngles( player:GetAimVector():Angle() );
	scanner:SetKeyValue("targetname", "scanner_"..uniqueID);
	scanner:SetKeyValue("spawnflags", 8592);
	scanner:SetKeyValue("renderfx", 0);
	scanner:Spawn(); scanner:Activate();
	
	marker:SetKeyValue("targetname", "marker_"..uniqueID);
	marker:SetPos(position);
	marker:Spawn(); marker:Activate();
	
	if (!lightSpawn) then
		player:Flashlight(false);
		player:RunCommand("-duck");
		
		if (scannerClass == "npc_clawscanner") then
			player:SetHealth(200);
		end;
	end;
	
	player:SetArmor(0);
	player:Spectate(OBS_MODE_CHASE);
	player:StripWeapons();
	player:SetSharedVar("scanner", scanner);
	player:SetMoveType(MOVETYPE_OBSERVER);
	player:SpectateEntity(scanner);
	
	scanner:SetMaxHealth( player:GetMaxHealth() );
	scanner:SetHealth( player:Health() );
	scanner:Fire("SetDistanceOverride", 64, 0);
	scanner:Fire("SetFollowTarget", "marker_"..uniqueID, 0);
	
	self.scanners[player] = {scanner, marker};
	
	openAura:CreateTimer("scanner_sound_"..uniqueID, 0.01, 1, function()
		if ( IsValid(scanner) ) then
			scanner.flyLoop = CreateSound(scanner, "npc/scanner/cbot_fly_loop.wav");
			scanner.flyLoop:Play();
		end;
	end);
	
	scanner:CallOnRemove("Scanner Sound", function(scanner)
		if (scanner.flyLoop) then
			scanner.flyLoop:Stop();
		end;
	end);
end;

-- A function to add a Combine display line.
function openAura.schema:AddCombineDisplayLine(text, color, player, exclude)
	if (player) then
		openAura:StartDataStream( player, "CombineDisplayLine", {text, color} );
	else
		local players = {};
		
		for k, v in ipairs( _player.GetAll() ) do
			if (self:PlayerIsCombine(v) and v != exclude) then
				players[#players + 1] = v;
			end;
		end;
		
		openAura:StartDataStream( players, "CombineDisplayLine", {text, color} );
	end;
end;

-- A function to load the objectives.
function openAura.schema:LoadObjectives()
	self.combineObjectives = openAura:RestoreSchemaData("objectives", "");
end;

-- A function to load the NPCs.
function openAura.schema:LoadNPCs()
	local npcs = openAura:RestoreSchemaData( "plugins/npcs/"..game.GetMap() );
	
	for k, v in pairs(npcs) do
		local entity = ents.Create(v.class);
		
		if ( IsValid(entity) ) then
			entity:SetKeyValue("spawnflags", v.spawnFlags or 0);
			entity:SetKeyValue("additionalequipment", v.equipment or "");
			entity:SetAngles(v.angles);
			entity:SetModel(v.model);
			entity:SetPos(v.position);
			entity:Spawn();
			
			if ( IsValid(entity) ) then
				entity:Activate();
				
				entity:SetNetworkedString("aura_Name", v.name);
				entity:SetNetworkedString("aura_Title", v.title);
			end;
		end;
	end;
end;

-- A function to save the NPCs.
function openAura.schema:SaveNPCs()
	local npcs = {};
	
	for k, v in pairs( ents.FindByClass("npc_*") ) do
		local name = v:GetNetworkedString("aura_Name");
		local title = v:GetNetworkedString("aura_Title");
		
		if (name != "" and title != "") then
			local keyValues = table.LowerKeyNames( v:GetKeyValues() );
			
			npcs[#npcs + 1] = {
				spawnFlags = keyValues["spawnflags"],
				equipment = keyValues["additionequipment"],
				position = v:GetPos(),
				angles = v:GetAngles(),
				model = v:GetModel(),
				title = title,
				class = v:GetClass(),
				name = name
			};
		end;
	end;
	
	openAura:SaveSchemaData("plugins/npcs/"..game.GetMap(), npcs);
end;

-- A function to load the Combine locks.
function openAura.schema:LoadCombineLocks()
	local combineLocks = openAura:RestoreSchemaData( "plugins/locks/"..game.GetMap() );
	
	for k, v in pairs(combineLocks) do
		local entity = ents.FindInSphere(v.doorPosition, 16)[1];
		
		if ( IsValid(entity) ) then
			local combineLock = self:ApplyCombineLock(entity);
			
			if (combineLock) then
				openAura.player:GivePropertyOffline(v.key, v.uniqueID, entity);
				
				combineLock:SetLocalAngles(v.angles);
				combineLock:SetLocalPos(v.position);
				
				if (!v.locked) then
					combineLock:Unlock();
				else
					combineLock:Lock();
				end;
			end;
		end;
	end;
end;

-- A function to save the Combine locks.
function openAura.schema:SaveCombineLocks()
	local combineLocks = {};
	
	for k, v in pairs( ents.FindByClass("aura_combinelock") ) do
		if ( IsValid(v.entity) ) then
			combineLocks[#combineLocks + 1] = {
				key = openAura.entity:QueryProperty(v, "key"),
				locked = v:IsLocked(),
				angles = v:GetLocalAngles(),
				position = v:GetLocalPos(),
				uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
				doorPosition = v.entity:GetPos()
			};
		end;
	end;
	
	openAura:SaveSchemaData("plugins/locks/"..game.GetMap(), combineLocks);
end;

-- A function to load the radios.
function openAura.schema:LoadRadios()
	local radios = openAura:RestoreSchemaData( "plugins/radios/"..game.GetMap() );
	
	for k, v in pairs(radios) do
		local entity = ents.Create("aura_radio");
		
		openAura.player:GivePropertyOffline(v.key, v.uniqueID, entity);
		
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		if ( IsValid(entity) ) then
			entity:SetFrequency(v.frequency);
			entity:SetOff(v.off);
		end;
		
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			if ( IsValid(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to load the ration dispensers.
function openAura.schema:LoadRationDispensers()
	local dispensers = openAura:RestoreSchemaData( "plugins/dispensers/"..game.GetMap() );
	
	for k, v in pairs(dispensers) do
		local entity = ents.Create("aura_rationdispenser");
		
		entity:SetPos(v.position);
		entity:Spawn();
		
		if ( IsValid(entity) ) then
			entity:SetAngles(v.angles);
			
			if (!v.locked) then
				entity:Unlock();
			else
				entity:Lock();
			end;
		end;
	end;
end;

-- A function to save the ration dispensers.
function openAura.schema:SaveRationDispensers()
	local dispensers = {};
	
	for k, v in pairs( ents.FindByClass("aura_rationdispenser") ) do
		dispensers[#dispensers + 1] = {
			locked = v:IsLocked(),
			angles = v:GetAngles(),
			position = v:GetPos()
		};
	end;
	
	openAura:SaveSchemaData("plugins/dispensers/"..game.GetMap(), dispensers);
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

-- A function to say a message as a request.
function openAura.schema:SayRequest(player, text)
	local isCitizen = (player:QueryCharacter("faction") == FACTION_CITIZEN);
	local listeners = { request = {}, eavesdrop = {} };
	
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (v:QueryCharacter("faction") == FACTION_CITIZEN and isCitizen and player != v) then
				if ( v:GetShootPos():Distance( player:GetShootPos() ) <= openAura.config:Get("talk_radius"):Get() ) then
					listeners.eavesdrop[v] = v;
				end;
			else
				local isCityAdmin = (v:QueryCharacter("faction") == FACTION_ADMIN);
				local isCombine = self:PlayerIsCombine(v);
				
				if (v:HasItem("request_device") or isCombine or isCityAdmin) then
					listeners.request[v] = v;
				end;
			end;
		end;
	end;
	
	self:AddCombineDisplayLine("Downloading request packet...");
	
	local info = openAura.chatBox:Add(listeners.request, player, "request", text);
	
	if ( info and IsValid(info.speaker) ) then
		openAura.chatBox:Add(listeners.eavesdrop, info.speaker, "request_eavesdrop", info.text);
	end;
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

-- A function to say a message as a broadcast.
function openAura.schema:SayBroadcast(player, text)
	openAura.chatBox:Add(nil, player, "broadcast", text);
end;

-- A function to say a message as a dispatch.
function openAura.schema:SayDispatch(player, text)
	openAura.chatBox:Add(nil, player, "dispatch", text);
end;

-- A function to check if a player is Combine.
function openAura.schema:PlayerIsCombine(player, bHuman)
	if ( IsValid(player) and player:GetCharacter() ) then
		local faction = player:QueryCharacter("faction");
		
		if ( self:IsCombineFaction(faction) ) then
			if (bHuman) then
				if (faction == FACTION_MPF) then
					return true;
				end;
			elseif (bHuman == false) then
				if (faction == FACTION_MPF) then
					return false;
				else
					return true;
				end;
			else
				return true;
			end;
		end;
	end;
end;

-- A function to apply a Combine lock.
function openAura.schema:ApplyCombineLock(entity, position, angles)
	local combineLock = ents.Create("aura_combinelock");
	
	combineLock:SetParent(entity);
	combineLock:SetDoor(entity);
	
	if (position) then
		if (type(position) == "table") then
			combineLock:SetLocalPos( Vector(-1.0313, 43.7188, -1.2258) );
			combineLock:SetPos( combineLock:GetPos() + (position.HitNormal * 4) );
		else
			combineLock:SetPos(position);
		end;
	end;
	
	if (angles) then
		combineLock:SetAngles(angles);
	end;
	
	combineLock:Spawn();
	
	if ( IsValid(combineLock) ) then
		return combineLock;
	end;
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
	
	if ( IsValid(door.combineLock) ) then
		door.combineLock:Explode();
		door.combineLock:Remove();
	end;
	
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
		
		player:SetCharacterData("permakilled", true);
		player:SetCharacterData("inventory", {}, true);
		player:SetCharacterData("cash", 0, true);
		
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

-- A function to tie or untie a player.
function openAura.schema:TiePlayer(player, isTied, reset, combine)
	if (isTied) then
		if (combine) then
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