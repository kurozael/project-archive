--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.game.autoDispatches = {};
kuroScript.game.timeDispatches = {};
kuroScript.game.scannerSounds = {
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
kuroScript.game.scanners = {};
kuroScript.game.cwuProps = {
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

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add some resource files.
resource.AddFile("models/humans/group03/male_soldier.mdl");
resource.AddFile("models/humans/group01/jasona.mdl");
resource.AddFile("models/eliteghostcp.mdl");
resource.AddFile("models/eliteshockcp.mdl");
resource.AddFile("models/policetrench.mdl");
resource.AddFile("models/leet_police2.mdl");
resource.AddFile("models/sect_police2.mdl");
resource.AddFile("models/sprayca2.mdl");

-- Loop through each value in a table.
for k, v in pairs( file.Find("../materials/models/spraycan3.*") ) do
	resource.AddFile("materials/models/"..v);
end;

-- Loop through each value in a table.
for k, v in pairs( file.Find("../materials/models/police/*.*") ) do
	resource.AddFile("materials/models/police/"..v);
end;

-- Loop through each value in a table.
for k, v in pairs( file.Find("../materials/models/humans/male/jas/*.*") ) do
	resource.AddFile("materials/models/humans/male/jas/"..v);
end;

-- Loop through each value in a table.
for k, v in pairs( file.Find("../materials/models/humans/male/soldier/*.*") ) do
	resource.AddFile("materials/models/humans/male/soldier/"..v);
end;

-- Add some animation models.
kuroScript.animation.AddCivilProtectionModel("models/eliteghostcp.mdl");
kuroScript.animation.AddCivilProtectionModel("models/eliteshockcp.mdl");
kuroScript.animation.AddCivilProtectionModel("models/leet_police2.mdl");
kuroScript.animation.AddCivilProtectionModel("models/sect_police2.mdl");
kuroScript.animation.AddCivilProtectionModel("models/policetrench.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group03/male_soldier.mdl");
kuroScript.animation.AddMaleHumanModel("models/humans/group01/jasona.mdl");

-- The identity used for the server whitelist (leave blank for no identity).
kuroScript.config.Add("server_whitelist_identity", "");

-- Whether or not the merchant permits are active.
kuroScript.config.Add("combine_lock_overrides", false);

-- Whether or not different clothes should be hidden on the scoreboard.
kuroScript.config.Add("hide_different_clothes", true, true);

-- The method used for calculating the depression.
kuroScript.config.Add("depression_method", 1, true);

-- The small text displayed for the introduction.
kuroScript.config.Add("intro_text_small", "http://kuromeku.com", true);

-- The big text displayed for the introduction.
kuroScript.config.Add("intro_text_big", "Half-Life 2 - Roleplay", true);

-- The model used for shipments.
kuroScript.config.Add("shipment_model", "models/items/item_item_crate.mdl");

-- The time that a player gets knocked out for (seconds).
kuroScript.config.Add("knockout_time", 60);

-- The amount that it costs to start a business.
kuroScript.config.Add("business_cost", 1200, true);

-- The city number used for the default Combine squad.
kuroScript.config.Add("city_number", "18", true);

-- Whether or not to use Civil Worker's Union props.
kuroScript.config.Add("cwu_props", true);

-- Whether or not permits are enabled.
kuroScript.config.Add("permits", true, true);

-- Set some config values.
kuroScript.config.Get("enable_gravgun_punt"):Set(false);
kuroScript.config.Get("default_inv_weight"):Set(10);
kuroScript.config.Get("enable_crosshair"):Set(false);
kuroScript.config.Get("anonymous_name"):Set("Unknown");
kuroScript.config.Get("disable_sprays"):Set(false);
kuroScript.config.Get("minute_time"):Set(60);
kuroScript.config.Get("door_cost"):Set(20);

-- A function to add a human hint.
function kuroScript.hint.AddHumanHint(name, text, combine)
	kuroScript.hint.Add(name, text, function(player)
		if (player) then
			return !kuroScript.game:PlayerIsCombine(player, combine);
		end;
	end);
end;

-- Add some human hints.
kuroScript.hint.AddHumanHint("Life", "Your character is only human, refrain from jumping off high ledges.", false);
kuroScript.hint.AddHumanHint("Sleep", "Don't forget to sleep, your character does get tired.", false);
kuroScript.hint.AddHumanHint("Eating", "Just because you don't have to eat, it doesn't mean your character isn't hungry.", false);
kuroScript.hint.AddHumanHint("Friends", "Try to make some friends, misery loves company.", false);

-- Add some human hints.
kuroScript.hint.AddHumanHint("Curfew", "Curfew? Bored? Ask to be assigned a roommate.");
kuroScript.hint.AddHumanHint("Prison", "Don't do the crime if you're not prepared to do the time.");
kuroScript.hint.AddHumanHint("Rebels", "Don't chase the resistance, the Combine may group you together.");
kuroScript.hint.AddHumanHint("Talking", "The Combine don't like it when you talk, so whisper.");
kuroScript.hint.AddHumanHint("Rations", "Rations, they're bags filled with goodies. Behave.");
kuroScript.hint.AddHumanHint("Combine", "Don't mess with the Combine, they took over Earth in 7 hours.");
kuroScript.hint.AddHumanHint("Jumping", "Bunny hopping is uncivilized, and the Combine will remind you with their stunsticks.");
kuroScript.hint.AddHumanHint("Punching", "Got that feeling you just wanna punch somebody? Don't.");
kuroScript.hint.AddHumanHint("Merchant", "Wanna make a quick buck or set up a store? Ask for a merchant permit.");
kuroScript.hint.AddHumanHint("Compliance", "Obey the Combine, you'll be glad that you did.");
kuroScript.hint.AddHumanHint("Combine Raids", "When the Combine come knocking, get your ass on the floor.");
kuroScript.hint.AddHumanHint("Request Device", "Need to reach Civil Protection? Invest in a request device.");
kuroScript.hint.AddHumanHint("Civil Protection", "Civil Protection, protecting civilized society, not you.");

-- Add some hints.
kuroScript.hint.Add("Admins", "The admins are here to help you, please respect them.");
kuroScript.hint.Add("Action", "Action. Stop looking for it, wait until it comes to you.");
kuroScript.hint.Add("Grammar", "Try to speak correctly in-character, and don't use emoticons.");
kuroScript.hint.Add("Running", "Got somewhere to go? Fancy a run? Well don't, it's uncivilized.");
kuroScript.hint.Add("Healing", "You can heal players by using the Give command in your inventory.");
kuroScript.hint.Add("Breaching", "When breaching a door, a good idea is to use a weapon.");
kuroScript.hint.Add("F3 Hotkey", "Press F3 while looking at a character to use a zip tie.");
kuroScript.hint.Add("F4 Hotkey", "Press F3 while looking at a tied character to search them.");
kuroScript.hint.Add("Attributes", "Whoring attributes is a permanant ban, we don't recommend it.");
kuroScript.hint.Add("Firefights", "When engaged in a firefight, shoot to miss to make it enjoyable.");
kuroScript.hint.Add("Metagaming", "Metagaming is when you use OOC information in-character. Don't do it.");
kuroScript.hint.Add("Passive RP", "If you're bored and there's no action, try some passive roleplay.");
kuroScript.hint.Add("Development", "Develop your character, give them a story to tell.");
kuroScript.hint.Add("Powergaming", "Powergaming is when you force your actions on others. Leave it open for returned roleplay.");

-- Hook a data stream.
datastream.Hook("ks_EditObjectives", function(player, handler, uniqueID, rawData, procData)
	if (player._EditObjectivesAuthorised and type(procData) == "string") then
		if (kuroScript.game.combineObjectives != procData) then
			kuroScript.game:AddCombineDisplayLine( "Downloading recent objectives...", Color(255, 100, 255, 255) );
			kuroScript.game.combineObjectives = string.sub(procData, 0, 500);
		end;
		
		-- Set some information.
		player._EditObjectivesAuthorised = nil;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_EditStaffData", function(player, handler, uniqueID, rawData, procData)
	if (player._EditStaffDataAuthorised and type(procData) == "string") then
		kuroScript.game.staffData = string.sub(procData, 0, 500);
		
		-- Set some information.
		player._EditStaffDataAuthorised = nil;
	end;
end);

-- Hook a data stream.
datastream.Hook("ks_EditData", function(player, handler, uniqueID, rawData, procData)
	if (player._EditDataAuthorised == procData[1] and type( procData[2] ) == "string") then
		procData[1]:SetCharacterData( "combinedata", string.sub(procData[2], 0, 500) );
		
		-- Set some information.
		player._EditDataAuthorised = nil;
	end;
end);

-- A function to calculate a player's scanner think.
function kuroScript.game:CalculateScannerThink(player, curTime)
	if ( !self.scanners[player] ) then return; end;
	
	-- Set some information.
	local spotlight = self.scanners[player][3];
	local scanner = self.scanners[player][1];
	local marker = self.scanners[player][2];
	
	-- Check if a statement is true.
	if ( ValidEntity(scanner) and ValidEntity(marker) and ValidEntity(spotlight) ) then
		scanner:SetMaxHealth( player:GetMaxHealth() );
		
		-- Set some information.
		player:SetMoveType(MOVETYPE_OBSERVER);
		player:SetHealth( math.max(scanner:Health(), 0) );
		
		-- Check if a statement is true.
		if (!player._NextScannerSound or curTime >= player._NextScannerSound) then
			player._NextScannerSound = curTime + math.random(8, 48);
			
			-- Emit a sound from the entity.
			scanner:EmitSound( self.scannerSounds[ math.random(1, #self.scannerSounds) ] );
		end;
	end;
end;

-- A function to reset a player's scanner.
function kuroScript.game:ResetPlayerScanner(player, silent)
	if ( self.scanners[player] ) then
		local spotlight = self.scanners[player][3];
		local scanner = self.scanners[player][1];
		local marker = self.scanners[player][2];
		
		-- Check if a statement is true.
		if ( ValidEntity(spotlight) ) then
			self:RemoveSpotlight(spotlight);
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(scanner) ) then
			scanner:Remove();
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(marker) ) then
			marker:Remove();
		end;
		
		-- Set some information.
		self.scanners[player] = nil;
		
		-- Check if a statement is true.
		if (!silent) then
			player:SetMoveType(MOVETYPE_WALK);
			player:UnSpectate();
			player:KillSilent();
		end;
	end;
end;

-- A function to make a player a scanner.
function kuroScript.game:MakePlayerScanner(player, silent, lightSpawn)
	self:ResetPlayerScanner(player, silent);
	
	-- Set some information.
	local scannerClass = "npc_cscanner";
	local spotlightPosition = Vector(8.2910, -0.4793, 14.0038);
	
	-- Check if a statement is true.
	if ( self:IsPlayerCombineRank(player, "SYNTH") ) then
		scannerClass = "npc_clawscanner";
		spotlightPosition = Vector(7.4746, -6.0824, 2.1015);
	end;
	
	-- Set some information.
	local spotlight = ents.Create("point_spotlight");
	local position = player:GetShootPos();
	local uniqueID = player:UniqueID();
	local scanner = ents.Create(scannerClass);
	local marker = ents.Create("path_corner");
	
	-- Set the entity's player.
	kuroScript.entity.SetPlayer(scanner, player);
	
	-- Set some information.
	scanner:SetPos( position + Vector(0, 0, 16) );
	scanner:SetAngles( player:GetAimVector():Angle() );
	scanner:SetKeyValue("targetname", "scanner_"..uniqueID);
	scanner:SetKeyValue("spawnflags", 8592);
	scanner:SetKeyValue("renderfx", 0);
	scanner:Spawn(); scanner:Activate();
	
	-- Set some information.
	spotlight:SetParent(scanner);
	spotlight:SetKeyValue("spotlightlength", 320);
	spotlight:SetKeyValue("spotlightwidth", 16);
	spotlight:SetKeyValue("targetname", "spotlight_"..uniqueID);
	spotlight:SetLocalPos(spotlightPosition);
	spotlight:SetLocalAngles( Angle(0, 0, 0) );
	spotlight:Spawn(); spotlight:Activate();
	
	-- Set some information.
	marker:SetKeyValue("targetname", "marker_"..uniqueID);
	marker:SetPos(position);
	marker:Spawn(); marker:Activate();
	
	-- Check if a statement is true.
	if (!lightSpawn) then
		player:Flashlight(false);
		player:RunCommand("-duck");
		
		-- Check if a statement is true.
		if (scannerClass == "npc_clawscanner") then
			player:SetHealth(200);
		end;
	end;
	
	-- Set some information.
	player:SetArmor(0);
	player:Spectate(OBS_MODE_CHASE);
	player:StripWeapons();
	player:SetSharedVar("ks_Scanner", scanner);
	player:SetMoveType(MOVETYPE_OBSERVER);
	player:SpectateEntity(scanner);
	
	-- Set some information.
	scanner:SetMaxHealth( player:GetMaxHealth() );
	scanner:SetHealth( player:Health() );
	scanner:Fire("SetDistanceOverride", 64, 0);
	scanner:Fire("SetFollowTarget", "marker_"..uniqueID, 0);
	
	-- Set some information.
	self.scanners[player] = {scanner, marker, spotlight};
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Scanner Spotlight: "..uniqueID, 0.01, 1, function()
		if ( ValidEntity(spotlight) ) then
			self:TurnSpotlightOn(spotlight);
		end;
		
		-- Check if a statement is true.
		if ( ValidEntity(scanner) ) then
			scanner._FlyLoop = CreateSound(scanner, "npc/scanner/cbot_fly_loop.wav");
			scanner._FlyLoop:Play();
		end;
	end);
	
	-- Call a function when the scanner is removed.
	scanner:CallOnRemove("Fly Loop", function(scanner)
		if (scanner._FlyLoop) then
			scanner._FlyLoop:Stop();
		end;
	end);
end;

-- A function to remove a spotlight.
function kuroScript.game:RemoveSpotlight(spotlight)
	if ( ValidEntity(spotlight._EntityBeam) ) then
		spotlight._EntityBeam:Remove();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(spotlight._EntityEnd) ) then
		spotlight._EntityEnd:Remove();
	end;
	
	-- Remove the entity.
	spotlight:Remove();
end;

-- A function to turn a spotlight on.
function kuroScript.game:TurnSpotlightOn(spotlight)
	self.currentSpotlight = spotlight;
	self.currentSpotlight:Fire("LightOn", "", 0);
	self.currentSpotlight._NextRelight = CurTime() + 8;
end;

-- A function to add a Combine display line.
function kuroScript.game:AddCombineDisplayLine(text, color, player, exclude)
	if (player) then
		datastream.StreamToClients( player, "ks_CombineDisplayLine", {text, color} );
	else
		local players = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in ipairs( g_Player.GetAll() ) do
			if (self:PlayerIsCombine(v) and v != exclude) then
				players[#players + 1] = v;
			end;
		end;
		
		-- Start a data stream.
		datastream.StreamToClients( players, "ks_CombineDisplayLine", {text, color} );
	end;
end;

-- A function to handle a player's recoil.
function kuroScript.game:HandlePlayerRecoil(player, curTime)
	if (!curTime) then
		curTime = CurTime();
	end;
	
	-- Check if a statement is true.
	local weapon = player:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local class = weapon:GetClass();
		local clip = weapon:Clip1();
		
		-- Check if a statement is true.
		if (clip != -1) then
			local accuracy = kuroScript.attributes.Get(player, ATB_ACCURACY) or 0;
			local scale = ( (self.defaultWeapons[class] or 6) * 2 ) / (1 + (0.0266666667 * accuracy) );
			
			-- Set some information.
			timer.Simple(FrameTime() * 0.5, function()
				if ( ValidEntity(weapon) and ValidEntity(player) and player:Alive() and !player:IsRagdolled() ) then
					if (weapon:Clip1() < clip) then
						player:SetEyeAngles( player:EyeAngles() - Angle(scale, 0, 0) );
						
						-- Progress the player's attribute.
						kuroScript.attributes.Progress(player, ATB_ACCURACY, 0.5, true);
					end;
				end;
			end);
		end;
	end;
end;

-- A function to load the objectives.
function kuroScript.game:LoadObjectives()
	self.combineObjectives = kuroScript.frame:RestoreGameData("objectives", "");
	self.staffData = kuroScript.frame:RestoreGameData("staffdata", "");
end;

-- A function to load the NPCs.
function kuroScript.game:LoadNPCs()
	local npcs = kuroScript.frame:RestoreGameData( "mounts/npcs/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(npcs) do
		local entity = ents.Create(v.class);
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetKeyValue("spawnflags", v.spawnFlags);
			entity:SetKeyValue("additionalequipment", v.equipment);
			entity:SetAngles(v.angles);
			entity:SetPos(v.position);
			entity:Spawn();
			
			-- Check if a statement is true.
			if ( ValidEntity(entity) ) then
				entity:Activate();
				
				-- Set some information.
				entity:SetNetworkedString("ks_Name", v.name);
				entity:SetNetworkedString("ks_Title", v.title);
			end;
		end;
	end;
end;

-- A function to save the NPCs.
function kuroScript.game:SaveNPCs()
	local npcs = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("npc_*") ) do
		local name = v:GetNetworkedString("ks_Name");
		local title = v:GetNetworkedString("ks_Title");
		
		-- Check if a statement is true.
		if (name != "" and title != "") then
			local keyValues = table.LowerKeyNames( v:GetKeyValues() );
			
			-- Set some information.
			npcs[#npcs + 1] = {
				spawnFlags = keyValues["spawnflags"],
				equipment = keyValues["additionequipment"],
				position = v:GetPos(),
				angles = v:GetAngles(),
				title = title,
				class = v:GetClass(),
				name = name
			};
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/npcs/"..game.GetMap(), npcs);
end;

-- A function to load the Combine locks.
function kuroScript.game:LoadCombineLocks()
	local combineLocks = kuroScript.frame:RestoreGameData( "mounts/combinelocks/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(combineLocks) do
		local entity = ents.FindInSphere(v.doorPosition, 16)[1];
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			local combineLock = self:ApplyCombineLock(entity);
			
			-- Check if a statement is true.
			if (combineLock) then
				kuroScript.player.GivePropertyOffline(v.key, v.uniqueID, entity);
				
				-- Set some information.
				combineLock:SetLocalAngles(v.angles);
				combineLock:SetLocalPos(v.position);
				
				-- Check if a statement is true.
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
function kuroScript.game:SaveCombineLocks()
	local combineLocks = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_combinelock") ) do
		if ( ValidEntity(v._Entity) ) then
			combineLocks[#combineLocks + 1] = {
				key = kuroScript.entity.QueryProperty(v, "key"),
				locked = v:IsLocked(),
				angles = v:GetLocalAngles(),
				position = v:GetLocalPos(),
				uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
				doorPosition = v._Entity:GetPos()
			};
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/combinelocks/"..game.GetMap(), combineLocks);
end;

-- A function to load the radios.
function kuroScript.game:LoadRadios()
	local radios = kuroScript.frame:RestoreGameData( "mounts/radios/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(radios) do
		local entity = ents.Create("ks_radio");
		
		-- Give the property to an offline player.
		kuroScript.player.GivePropertyOffline(v.key, v.uniqueID, entity);
		
		-- Set some information.
		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetFrequency(v.frequency);
			entity:SetOff(v.off);
		end;
		
		-- Check if a statement is true.
		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to load the ration dispensers.
function kuroScript.game:LoadRationDispensers()
	local dispensers = kuroScript.frame:RestoreGameData( "mounts/dispensers/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(dispensers) do
		local entity = ents.Create("ks_rationdispenser");
		
		-- Set some information.
		entity:SetPos(v.position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			entity:SetAngles(v.angles);
			
			-- Check if a statement is true.
			if (!v.locked) then
				entity:Unlock();
			else
				entity:Lock();
			end;
		end;
	end;
end;

-- A function to save the ration dispensers.
function kuroScript.game:SaveRationDispensers()
	local dispensers = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_rationdispenser") ) do
		dispensers[#dispensers + 1] = {
			locked = v:IsLocked(),
			angles = v:GetAngles(),
			position = v:GetPos()
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/dispensers/"..game.GetMap(), dispensers);
end;

-- A function to save the radios.
function kuroScript.game:SaveRadios()
	local radios = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_radio") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		-- Check if a statement is true.
		if ( ValidEntity(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		-- Set some information.
		radios[#radios + 1] = {
			off = v:IsOff(),
			key = kuroScript.entity.QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			frequency = v:GetSharedVar("ks_Frequency")
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/radios/"..game.GetMap(), radios);
end;

-- A function to say a message as a request.
function kuroScript.game:SayRequest(player, text)
	local isCitizen = (player:QueryCharacter("class") == CLASS_CIT);
	local listeners = { request = {}, eavesdrop = {} };
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (v:QueryCharacter("class") == CLASS_CIT and isCitizen and player != v) then
				if ( v:GetShootPos():Distance( player:GetShootPos() ) <= kuroScript.config.Get("talk_radius"):Get() ) then
					listeners.eavesdrop[v] = v;
				end;
			else
				local isCityAdmin = (v:QueryCharacter("class") == CLASS_CAD);
				local isCombine = self:PlayerIsCombine(v);
				
				-- Check if a statement is true.
				if (kuroScript.inventory.HasItem(v, "request_device") or isCombine or isCityAdmin) then
					listeners.request[v] = v;
				end;
			end;
		end;
	end;
	
	-- Add a Combine display line.
	self:AddCombineDisplayLine("Downloading request packet...");
	
	-- Add a chat box message.
	local info = kuroScript.chatBox.Add(listeners.request, player, "request", text);
	
	-- Check if a statement is true.
	if ( info and ValidEntity(info.speaker) ) then
		kuroScript.chatBox.Add(listeners.eavesdrop, info.speaker, "request_eavesdrop", info.text);
	end;
end;

-- A function to get a player's location.
function kuroScript.game:PlayerGetLocation(player)
	local areaNames = kuroScript.mount.Get("Area Names");
	local closest;
	local k, v;
	
	-- Check if a statement is true.
	if (areaNames) then
		for k, v in pairs(areaNames.areaNames) do
			if ( kuroScript.entity.IsInBox(player, v.minimum, v.maximum) ) then
				if (string.sub(string.lower(v.name), 1, 4) == "the ") then
					return string.sub(v.name, 5);
				else
					return v.name;
				end;
			else
				local distance = player:GetShootPos():Distance(v.minimum);
				
				-- Check if a statement is true.
				if ( !closest or distance < closest[1] ) then
					closest = {distance, v.name};
				end;
			end;
		end;
		
		-- Check if a statement is true.
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
	
	-- Return the location.
	return "unknown location";
end;

-- A function to say a message as a broadcast.
function kuroScript.game:SayBroadcast(player, text)
	kuroScript.chatBox.Add(nil, player, "broadcast", text);
end;

-- A function to say a message as a dispatch.
function kuroScript.game:SayDispatch(player, text)
	kuroScript.chatBox.Add(nil, player, "dispatch", text);
end;

-- A function to check if a statement is true.
function kuroScript.game:PlayerIsCombine(player, human)
	if ( ValidEntity(player) and player:GetCharacter() ) then
		local class = player:QueryCharacter("class");
		
		-- Check if a statement is true.
		if ( self:IsCombineClass(class) ) then
			if (human) then
				if (class == CLASS_CPA) then
					return true;
				end;
			elseif (human == false) then
				if (class == CLASS_CPA) then
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
function kuroScript.game:ApplyCombineLock(entity, position, angles)
	local combineLock = ents.Create("ks_combinelock");
	
	-- Set some information.
	combineLock:SetParent(entity);
	combineLock:SetDoor(entity);
	
	-- Check if a statement is true.
	if (position) then
		if (type(position) == "table") then
			combineLock:SetLocalPos( Vector(-1.0313, 43.7188, -1.2258) );
			combineLock:SetPos( combineLock:GetPos() + (position.HitNormal * 4) );
		else
			combineLock:SetPos(position);
		end;
	end;
	
	-- Check if a statement is true.
	if (angles) then
		combineLock:SetAngles(angles);
	end;
	
	-- Spawn the entity.
	combineLock:Spawn();
	
	-- Check if a statement is true.
	if ( ValidEntity(combineLock) ) then
		return combineLock;
	end;
end;

-- A function to make a player wear clothes.
function kuroScript.game:PlayerWearClothes(player, item, silent, force)
	local curTime = CurTime();
	local position = player:GetPos();
	
	-- Check if a statement is true.
	if (force) then
		if (player:GetCharacterData("clothes") == item.uniqueID) then
			item:OnChangeClothes(player, false);
			
			-- Set some information.
			player:SetCharacterData("clothes", nil);
		else
			item:OnChangeClothes(player, true);
			
			-- Set some information.
			player:SetCharacterData("clothes", item.uniqueID);
		end;
		
		-- Update the player's inventory.
		kuroScript.inventory.Update(player, item.uniqueID);
	else
		kuroScript.player.SetAction(player, "clothes", 5);
		
		-- Set some information.
		kuroScript.player.ConditionTimer(player, 5, function()
			return player:Alive() and !player:IsRagdolled() and player:GetPos() == position;
		end, function(success)
			if (success) then
				self:PlayerWearClothes(player, item, silent, true);
			end;
		end);
	end;
end;

-- A function to get a player's heal amount.
function kuroScript.game:GetHealAmount(player, scale)
	local medical = kuroScript.attributes.Get(player, ATB_MEDICAL) or 0;
	
	-- Return the dexterity time.
	return ( 15 + (0.466666667 * medical) ) * (scale or 1);
end;

-- A function to get a player's dexterity time.
function kuroScript.game:GetDexterityTime(player)
	local dexterity = kuroScript.attributes.Get(player, ATB_DEXTERITY) or 0;
	
	-- Return the dexterity time.
	return 7 - (0.0666666667 * dexterity);
end;

-- A function to bust down a door.
function kuroScript.game:BustDownDoor(player, door, force)
	door._BustedDown = true;
	
	-- Set some information.
	door:SetNotSolid(true);
	door:DrawShadow(false);
	door:SetNoDraw(true);
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav");
	door:Fire("Unlock", "", 0);
	
	-- Check if a statement is true.
	if ( ValidEntity(door._CombineLock) ) then
		door._CombineLock:Explode();
		door._CombineLock:Remove();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(door._Breach) ) then
		door._Breach:BreachEntity();
	end;
	
	-- Set some information.
	local fakeDoor = ents.Create("prop_physics");
	
	-- Set some information.
	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD);
	fakeDoor:SetAngles( door:GetAngles() );
	fakeDoor:SetModel( door:GetModel() );
	fakeDoor:SetSkin( door:GetSkin() );
	fakeDoor:SetPos( door:GetPos() );
	fakeDoor:Spawn();
	
	-- Set some information.
	local physicsObject = fakeDoor:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		if (!force) then
			if ( ValidEntity(player) ) then
				physicsObject:ApplyForceCenter( (door:GetPos() - player:GetPos() ):Normalize() * 10000 );
			end;
		else
			physicsObject:ApplyForceCenter(force);
		end;
	end;
	
	-- Decay the entity.
	kuroScript.entity.Decay(fakeDoor, 300);
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Reset Door: "..door:EntIndex(), 300, 1, function()
		if ( ValidEntity(door) ) then
			door._BustedDown = nil;
			
			-- Set some information.
			door:SetNotSolid(false);
			door:DrawShadow(true);
			door:SetNoDraw(false);
		end;
	end);
end;

-- A function to permanently kill a player.
function kuroScript.game:PermaKillPlayer(player)
	local inventory = player:QueryCharacter("inventory");
	local currency = player:QueryCharacter("currency");
	local k, v;
	local i;
	
	-- Check if a statement is true.
	if ( !player:GetCharacterData("permakilled") ) then
		if ( player:IsRagdolled() ) then
			local ragdoll = player:GetRagdollEntity();
			
			-- Set some information.
			ragdoll:SetNetworkedString( "ks_Name", player:Name() );
			ragdoll:SetNetworkedBool("ks_PermaKilled", true);
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(inventory) do
			if ( !kuroScript.item.IsBasedFrom(k, "clothes_base") ) then
				for i = 1, v do
					kuroScript.entity.CreateItem( player, k, player:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
				end;
			end;
			
			-- Update the player's inventory.
			kuroScript.inventory.Update(player, k, -v, true);
		end;
		
		-- Set some information.
		player:SetCharacterData("permakilled", true);
		player:SetSharedVar("ks_PermaKilled", true);
		
		-- Check if a statement is true.
		if (currency > 0) then
			kuroScript.player.GiveCurrency(player, -currency, "Perma-Kill");
			kuroScript.entity.CreateCurrency( player, currency, player:GetPos() + Vector(0, 0, 32) );
		end;
		
		-- Save the player's character.
		kuroScript.player.SaveCharacter(player);
		
		-- Set some information.
		timer.Simple(5, function()
			if ( ValidEntity(player) ) then
				player:RunCommand("retry");
			end;
		end);
	end;
end;

-- A function to tie or untie a player.
function kuroScript.game:TiePlayer(player, boolean, reset, combine)
	if (boolean) then
		if (combine) then
			player:SetSharedVar("ks_Tied", 2);
		else
			player:SetSharedVar("ks_Tied", 1);
		end;
	else
		player:SetSharedVar("ks_Tied", 0);
	end;
	
	-- Check if a statement is true.
	if (boolean) then
		kuroScript.player.DropWeapons(player);
		
		-- Print a debug message.
		kuroScript.frame:PrintDebug(player:Name().." has been tied.");
		
		-- Set some information.
		player:Flashlight(false);
		player:StripWeapons();
	elseif (!reset) then
		if ( player:Alive() and !player:IsRagdolled() ) then 
			kuroScript.player.LightSpawn(player, true, true);
		end;
		
		-- Print a debug message.
		kuroScript.frame:PrintDebug(player:Name().." has been untied.");
	end;
end;

-- Set some information.
kuroScript.frame:CreateTimer("Auto-Dispatches", 300, 0, function()
	if (#kuroScript.game.autoDispatches > 0) then
		local hour = kuroScript.time.hour;
		local minute = kuroScript.time.minute;
		local dispatch = kuroScript.game.autoDispatches[ math.random(1, #kuroScript.game.autoDispatches) ];
		
		-- Check if a statement is true.
		if (hour == 24) then hour = 0; end;
		if (minute == 60) then minute = 0; end;
		
		-- Check the length of the hour and minute.
		if (string.len( tostring(hour) ) == 1) then hour = "0"..hour; end;
		if (string.len( tostring(minute) ) == 1) then minute = "0"..minute; end;
		
		-- Check if a statement is true.
		if ( !kuroScript.game.timeDispatches[hour..":"..minute] ) then
			if (dispatch) then
				kuroScript.game:SayDispatch(nil, dispatch);
			end;
		end;
	end;
end);