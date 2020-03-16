--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local COMMAND = {};
local cashName = nexus.schema.GetOption("name_cash");

COMMAND = {};
COMMAND.tip = "Kick a player from the server.";
COMMAND.text = "<string Name> <reason>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] );
	local reason = table.concat(arguments, " ", 2);
	
	if (!reason or reason == "") then
		reason = "N/A";
	end;
	
	if (target) then
		nexus.player.NotifyAll(player:Name().." has kicked '"..target:Name().."' ("..reason..").");
		
		target:Kick(reason);
		
		target.kicked = true;
	else
		nexus.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

nexus.command.Register(COMMAND, "PlyKick");

COMMAND = {};
COMMAND.tip = "Unban a Steam ID from the server.";
COMMAND.text = "<string SteamID|IPAddress>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = nexus.config.Get("mysql_players_table"):Get();
	local schemaFolder = NEXUS:GetSchemaFolder();
	local identifier = string.upper( arguments[1] );
	
	if ( NEXUS.BanList[identifier] ) then
		nexus.player.NotifyAll(player:Name().." has unbanned '"..NEXUS.BanList[identifier].steamName.."'.");
		
		NEXUS:RemoveBan(identifier);
	else
		nexus.player.Notify(player, "There are no banned players with the '"..identifier.."' identifier!");
	end;
end;

nexus.command.Register(COMMAND, "PlyUnban");

COMMAND = {};
COMMAND.tip = "Ban a player from the server.";
COMMAND.text = "<string Name|SteamID|IPAddress> <number Minutes> [string Reason]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local schemaFolder = NEXUS:GetSchemaFolder();
	local duration = tonumber( arguments[2] );
	local reason = table.concat(arguments, " ", 3);
	
	if (!reason or reason == "") then
		reason = nil;
	end;
	
	if (duration) then
		NEXUS:AddBan(arguments[1], duration * 60, reason, function(steamName, duration, reason)
			if ( IsValid(player) ) then
				if (steamName) then
					if (duration > 0) then
						local hours = duration / 60;
						
						if (hours >= 1) then
							nexus.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").");
						else
							nexus.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..duration.." minute(s) ("..reason..").");
						end;
					else
						nexus.player.NotifyAll(player:Name().." has banned '"..steamName.."' permanently ("..reason..").");
					end;
				else
					nexus.player.Notify(player, "This is not a valid identifier!");
				end;
			end;
		end);
	else
		nexus.player.Notify(player, "This is not a valid duration!");
	end;
end;

nexus.command.Register(COMMAND, "PlyBan");

COMMAND = {};
COMMAND.tip = "Send a private message to a player.";
COMMAND.text = "<string Name> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local voicemail = target:GetCharacterData("voicemail");
		
		if (voicemail and voicemail != "") then
			nexus.chatBox.Add(player, target, "pm", voicemail);
		else
			nexus.chatBox.Add( {player, target}, player, "pm", table.concat(arguments, " ", 2) );
		end;
	else
		nexus.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

nexus.command.Register(COMMAND, "PM");

COMMAND = {};
COMMAND.tip = "Add a player to a whitelist.";
COMMAND.text = "<string Name> <string Faction>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local faction = table.concat(arguments, " ", 2);
		
		if ( nexus.faction.stored[faction] ) then
			if (nexus.faction.stored[faction].whitelist) then
				if ( !nexus.player.IsWhitelisted(target, faction) ) then
					nexus.player.SetWhitelisted(target, faction, true);
					nexus.player.SaveCharacter(target);
					
					nexus.player.NotifyAll(player:Name().." has added "..target:Name().." to the "..faction.." whitelist.");
				else
					nexus.player.Notify(player, target:Name().." is already on the "..faction.." whitelist!");
				end;
			else
				nexus.player.Notify(player, faction.." does not have a whitelist!");
			end;
		else
			nexus.player.Notify(player, faction.." is not a valid faction!");
		end;
	else
		nexus.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

nexus.command.Register(COMMAND, "PlyWhitelist");

COMMAND = {};
COMMAND.tip = "Remove a player from a whitelist.";
COMMAND.text = "<string Name> <string Faction>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local faction = table.concat(arguments, " ", 2);
		
		if ( nexus.faction.stored[faction] ) then
			if (nexus.faction.stored[faction].whitelist) then
				if ( nexus.player.IsWhitelisted(target, faction) ) then
					nexus.player.SetWhitelisted(target, faction, false);
					nexus.player.SaveCharacter(target);
					
					nexus.player.NotifyAll(player:Name().." has removed "..target:Name().." from the "..faction.." whitelist.");
				else
					nexus.player.Notify(player, target:Name().." is not on the "..faction.." whitelist!");
				end;
			else
				nexus.player.Notify(player, faction.." does not have a whitelist!");
			end;
		else
			nexus.player.Notify(player, faction.." is not a valid faction!");
		end;
	else
		nexus.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

nexus.command.Register(COMMAND, "PlyUnwhitelist");

COMMAND = {};
COMMAND.tip = "Unban a character from being used.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( v:Name() == arguments[1] ) then
				nexus.player.NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
				nexus.player.SetBanned(player, false);
				
				return;
			else
				for k2, v2 in pairs( v:GetCharacters() ) do
					if ( v2.name == arguments[1] ) then
						nexus.player.NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
						v2.data.banned = false;
						
						return;
					end;
				end;
			end;
		end;
	end;
	
	local charactersTable = nexus.config.Get("mysql_players_table"):Get();
	local charName = tmysql.escape( arguments[1] );
	
	tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Name = \""..charName.."\"", function(result)
		if (result and type(result) == "table" and #result > 0) then
			tmysql.query("UPDATE "..charactersTable.." SET _Data = REPLACE(_Data, \"\"banned\":true\", \"\"banned\":false\") WHERE _Name = \""..charName.."\"");
			
			nexus.player.NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
		else
			nexus.player.NotifyAll("This is not a valid character!");
		end;
	end);
end;

nexus.command.Register(COMMAND, "CharUnban");

COMMAND = {};
COMMAND.tip = "Ban a character from being used.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( table.concat(arguments, " ") );
	
	if (target) then
		nexus.player.SetBanned(target, true);
		nexus.player.NotifyAll(player:Name().." banned the character '"..target:Name().."'.");
		
		target:KillSilent();
	else
		nexus.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

nexus.command.Register(COMMAND, "CharBan");

COMMAND = {};
COMMAND.tip = "Set a character's model permanently.";
COMMAND.text = "<string Name> <string Model>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local model = table.concat(arguments, " ", 2);
		
		target:SetCharacterData("model", model, true);
		target:SetModel(model);
		
		nexus.player.NotifyAll(player:Name().." set "..target:Name().."'s model to "..model..".");
	else
		nexus.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

nexus.command.Register(COMMAND, "CharSetModel");

COMMAND = {};
COMMAND.tip = "Change your character's physical description.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( arguments[1] ) then
		local minimumPhysDesc = nexus.config.Get("minimum_physdesc"):Get();
		local text = table.concat(arguments, " ");
		
		if (string.len(text) < minimumPhysDesc) then
			nexus.player.Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
			
			return;
		end;
		
		player:SetCharacterData( "physdesc", NEXUS:ModifyPhysDesc(text) );
	else
		umsg.Start("nx_PhysDesc", player);
		umsg.End();
	end;
end;

nexus.command.Register(COMMAND, "CharPhysDesc");

COMMAND = {};
COMMAND.tip = "Give an item to a character.";
COMMAND.text = "<string Name> <string Item>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( nexus.player.HasFlags(player, "G") ) then
		local target = nexus.player.Get( arguments[1] );
		
		if (target) then
			local item = nexus.item.Get( arguments[2] );
			
			if (item) then
				local success, fault = target:UpdateInventory(item.uniqueID, 1, true, true);
				
				if (!success) then
					nexus.player.Notify(player, target:Name().." does not have enough space for this item!");
				else
					if (string.sub(item.name, -1) == "s") then
						nexus.player.Notify(player, "You have given "..target:Name().." some "..item.name..".");
					else
						nexus.player.Notify(player, "You have given "..target:Name().." a "..item.name..".");
					end;
					
					if (player != target) then
						if (string.sub(item.name, -1) == "s") then
							nexus.player.Notify(target, player:Name().." has given you some "..item.name..".");
						else
							nexus.player.Notify(target, player:Name().." has given you a "..item.name..".");
						end;
					end;
				end;
			else
				nexus.player.Notify(player, "This is not a valid item!");
			end;
		else
			nexus.player.Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		nexus.player.Notify(player, "I'm sorry, it seems like you cannot be trusted with this command!");
	end;
end;

nexus.command.Register(COMMAND, "CharGiveItem");

COMMAND = {};
COMMAND.tip = "Set a character's name permanently.";
COMMAND.text = "<string Name> <string Name>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local name = table.concat(arguments, " ", 2);
		
		nexus.player.NotifyAll(player:Name().." set "..target:Name().."'s name to "..name..".");
		
		nexus.player.SetName(target, name);
	else
		nexus.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

nexus.command.Register(COMMAND, "CharSetName");

COMMAND = {};
COMMAND.tip = "Transfer a character to a faction.";
COMMAND.text = "<string Name> <string Faction> [string Data]";
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		local faction = arguments[2];
		local name = target:Name();
		
		if ( nexus.faction.stored[faction] ) then
			if ( !nexus.faction.stored[faction].whitelist or nexus.player.IsWhitelisted(target, faction) ) then
				local targetFaction = target:QueryCharacter("faction");
				
				if (targetFaction != faction) then
					if ( nexus.faction.IsGenderValid( faction, nexus.player.GetGender(target) ) ) then
						if (nexus.faction.stored[faction].OnTransferred) then
							local success, fault = nexus.faction.stored[faction]:OnTransferred( target, nexus.faction.stored[targetFaction], arguments[3] );
							
							if (success != false) then
								target:SetCharacterData("faction", faction, true);
								
								nexus.player.LoadCharacter( target, nexus.player.GetCharacterID(target) );
								nexus.player.NotifyAll(player:Name().." has transferred "..name.." to the "..faction.." faction.");
							else
								nexus.player.Notify(player, fault or target:Name().." could not be transferred to the "..faction.." faction!");
							end;
						else
							nexus.player.Notify(player, target:Name().." cannot be transferred to the "..faction.." faction!");
						end;
					else
						nexus.player.Notify(player, target:Name().." is not the correct gender for the "..faction.." faction!");
					end;
				else
					nexus.player.Notify(player, target:Name().." is already the "..faction.." faction!");
				end;
			else
				nexus.player.Notify(player, target:Name().." is not on the "..faction.." whitelist!");
			end;
		else
			nexus.player.Notify(player, faction.." is not a valid faction!");
		end;
	else
		nexus.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

nexus.command.Register(COMMAND, "CharTransfer");

COMMAND.tip = "Give flags to a character.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o") ) then
			nexus.player.Notify(player, "You cannot give 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		nexus.player.GiveFlags( target, arguments[2] );
		
		nexus.player.NotifyAll(player:Name().." gave "..target:Name().." '"..arguments[2].."' flags.");
	else
		nexus.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

nexus.command.Register(COMMAND, "CharGiveFlags");

COMMAND = {};
COMMAND.tip = "Take flags from a character.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = nexus.player.Get( arguments[1] )
	
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o") ) then
			nexus.player.Notify(player, "You cannot take 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		nexus.player.TakeFlags( target, arguments[2] );
		
		nexus.player.NotifyAll(player:Name().." took '"..arguments[2].."' flags from "..target:Name()..".");
	else
		nexus.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

nexus.command.Register(COMMAND, "CharTakeFlags");

COMMAND = {};
COMMAND.tip = "List the nexus config variables.";
COMMAND.text = "[string Find]";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player:PrintMessage(2, "////////// [nexus - Config Variables] //////////");
		local search = arguments[1];
		local config = {};
		
		if (search) then
			search = string.lower(search);
		end;
		
		for k, v in pairs(nexus.config.stored) do
			if ( type(v.value) != "table" and ( !search or string.find(string.lower(k), search) ) ) then
				if (!v.isStatic) then
					if (v.isPrivate) then
						config[#config + 1] = { k, string.rep( "*", string.len( tostring(v.value) ) ) };
					else
						config[#config + 1] = { k, tostring(v.value) };
					end;
				end;
			end;
		end;
		
		table.sort(config, function(a, b)
			return a[1] < b[1];
		end);
		
		for k, v in ipairs(config) do
			local overwatchValues = nexus.config.GetOverwatch( v[1] );
			
			if (overwatchValues) then
				player:PrintMessage(2, "// "..overwatchValues.help);
			end;
			
			player:PrintMessage(2, v[1].." = \""..v[2].."\";");
		end;
	player:PrintMessage(2, "////////// [nexus - Config Variables] //////////");
	
	nexus.player.Notify(player, "The config variables have been printed to the console.");
end;

nexus.command.Register(COMMAND, "CfgListVars");

COMMAND = {};
COMMAND.tip = "Set a nexus config variable.";
COMMAND.text = "<string Key> [all Value] [string Map]";
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local key = arguments[1];
	local value = arguments[2] or "";
	local configObject = nexus.config.Get(key);
	
	if ( configObject:IsValid() ) then
		local keyPrefix = "";
		local useMap = arguments[3];
		
		if (useMap == "") then
			useMap = nil;
		end;
		
		if (useMap) then
			useMap = string.lower( string.Replace(useMap, ".bsp", "") );
			keyPrefix = useMap.."'s ";
			
			if ( !file.Exists("../maps/"..useMap..".bsp") ) then
				nexus.player.Notify(player, useMap.." is not a valid map!");
				
				return;
			end;
		end;
		
		if ( !configObject:Query("isStatic") ) then
			value = configObject:Set(value, useMap);
			
			if (value != nil) then
				local printValue = tostring(value);
				
				if ( configObject:Query("isPrivate") ) then
					if ( configObject:Query("needsRestart") ) then
						nexus.player.NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep( "*", string.len(printValue) ).."' for the next restart.");
					else
						nexus.player.NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep( "*", string.len(printValue) ).."'.");
					end;
				elseif ( configObject:Query("needsRestart") ) then
					nexus.player.NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."' for the next restart.");
				else
					nexus.player.NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."'.");
				end;
			else
				nexus.player.Notify(player, key.." was unable to be set!");
			end;
		else
			nexus.player.Notify(player, key.." is a static config key!");
		end;
	else
		nexus.player.Notify(player, key.." is not a valid config key!");
	end;
end;

nexus.command.Register(COMMAND, "CfgSetVar");

COMMAND = {};
COMMAND.tip = "Give "..string.lower(cashName).." to the target character.";
COMMAND.text = "<number "..string.gsub(cashName, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if ( target and target:IsPlayer() ) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			local cash = tonumber( arguments[1] );
			
			if (cash and cash > 0) then
				cash = math.floor(cash);
				
				if ( nexus.player.CanAfford(player, cash) ) then
					local playerName = player:Name();
					local targetName = target:Name();
					
					if ( !nexus.player.DoesRecognise(player, target) ) then
						targetName = nexus.config.Get("unrecognised_name"):Get();
					end;
					
					if ( !nexus.player.DoesRecognise(target, player) ) then
						playerName = nexus.config.Get("unrecognised_name"):Get();
					end;
					
					nexus.player.GiveCash(player, -cash, targetName);
					nexus.player.GiveCash(target, cash, playerName);
				else
					local amount = cash - nexus.player.GetCash(player);
					
					nexus.player.Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
				end;
			else
				nexus.player.Notify(player, "This is not a valid amount!");
			end;
		else
			nexus.player.Notify(player, "This character is too far away!");
		end;
	else
		nexus.player.Notify(player, "You must look at a valid character!");
	end;
end;

nexus.command.Register(COMMAND, string.gsub(cashName, "%s", "").."Give");

COMMAND = {};
COMMAND.tip = "Drop "..string.lower(cashName).." at your target position.";
COMMAND.text = "<number "..string.gsub(cashName, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local cash = tonumber( arguments[1] );
	
	if (cash and cash > 0) then
		cash = math.floor(cash);
		
		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if ( nexus.player.CanAfford(player, cash) ) then
				nexus.player.GiveCash( player, -cash, nexus.schema.GetOption("name_cash") );
				
				local entity = nexus.entity.CreateCash(player, cash, trace.HitPos);
				
				if ( IsValid(entity) ) then
					nexus.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
				end;
			else
				local amount = cash - nexus.player.GetCash(player);
				
				nexus.player.Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
			end;
		else
			nexus.player.Notify(player, "You cannot drop "..string.lower(cashName).." that far away!");
		end;
	else
		nexus.player.Notify(player, "This is not a valid amount!");
	end;
end;

nexus.command.Register(COMMAND, string.gsub(cashName, "%s", "").."Drop");

COMMAND = {};
COMMAND.tip = "Set your personal message voicemail.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1] == "none") then
		player:SetCharacterData("voicemail", nil);
		
		nexus.player.Notify(player, "You have removed your voicemail.");
	else
		player:SetCharacterData( "voicemail", arguments[1] );
		
		nexus.player.Notify(player, "You have set your voicemail to '"..arguments[1].."'.");
	end;
end;

nexus.command.Register(COMMAND, "SetVoicemail");

COMMAND = {};
COMMAND.tip = "Set the class of your character.";
COMMAND.text = "<string Class>";
COMMAND.flags = CMD_HEAVY;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local class = nexus.class.Get( arguments[1] );
	
	if ( player:InVehicle() ) then
		nexus.player.Notify(player, "You don't have permission to do this right now!");
		
		return;
	end;
	
	if (class) then
		local limit = nexus.class.GetLimit(class.name);
		
		if ( nexus.mount.Call("PlayerCanBypassClassLimit", player, class.index) ) then
			limit = MaxPlayers();
		end;
		
		if (g_Team.NumPlayers(class.index) >= limit) then
			nexus.player.Notify(player, "There are too many characters with this class!");
		else
			local previousTeam = player:Team();
			
			if (player:Team() != class.index) then
				if ( NEXUS:HasObjectAccess(player, class) ) then
					if ( nexus.mount.Call("PlayerCanChangeClass", player, class) ) then
						local success, fault = nexus.class.Set(player, class.index, nil, true);
						
						if (!success) then
							nexus.player.Notify(player, fault);
						end;
					end;
				else
					nexus.player.Notify(player, "You do not have access to this class!");
				end;
			end;
		end;
	else
		nexus.player.Notify(player, "This is not a valid class!");
	end;
end;

nexus.command.Register(COMMAND, "SetClass");

COMMAND = {};
COMMAND.tip = "Close the active storage.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		nexus.player.CloseStorage(player, true);
	else
		nexus.player.Notify(player, "You do not have storage open!");
	end;
end;

nexus.command.Register(COMMAND, "StorageClose");

COMMAND = {};
COMMAND.tip = "Take some "..string.lower(cashName).." from storage.";
COMMAND.text = "<number "..string.gsub(cashName, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		local target = storageTable.entity;
		
		if ( IsValid(target) ) then
			if ( nexus.config.Get("cash_enabled"):Get() ) then
				local cash = tonumber( arguments[1] );
				
				if (cash and cash > 0) then
					if (cash <= storageTable.cash) then
						if ( !storageTable.CanTakeCash or (storageTable.CanTakeCash(player, storageTable, cash) != false) ) then
							if ( !target:IsPlayer() ) then
								nexus.player.GiveCash(player, cash, nil, true);
								nexus.player.UpdateStorageCash(player, storageTable.cash - cash);
							else
								nexus.player.GiveCash(player, cash, nil, true);
								nexus.player.GiveCash(target, -cash, nil, true);
								nexus.player.UpdateStorageCash( player, nexus.player.GetCash(target) );
							end;
							
							if (storageTable.OnTakeCash) then
								if ( storageTable.OnTakeCash(player, storageTable, cash) ) then
									nexus.player.CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		nexus.player.Notify(player, "You do not have storage open!");
	end;
end;

nexus.command.Register( COMMAND, "StorageTake"..string.gsub(cashName, "%s", "") );

COMMAND = {};
COMMAND.tip = "Give some "..string.lower(cashName).." to storage.";
COMMAND.text = "<number "..string.gsub(cashName, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		local target = storageTable.entity;
		
		if ( IsValid(target) ) then
			if ( nexus.config.Get("cash_enabled"):Get() ) then
				local cash = tonumber( arguments[1] );
				
				if (cash and cash > 0) then
					if ( nexus.player.CanAfford(player, cash) ) then
						if ( !storageTable.CanGiveCash or (storageTable.CanGiveCash(player, storageTable, cash) != false) ) then
							if ( !target:IsPlayer() ) then
								if (nexus.player.GetStorageWeight(player) + (nexus.config.Get("cash_weight"):Get() * cash) <= storageTable.weight) then
									nexus.player.GiveCash(player, -cash, nil, true);
									nexus.player.UpdateStorageCash(player, storageTable.cash + cash);
								end;
							else
								nexus.player.GiveCash(player, -cash, nil, true);
								nexus.player.GiveCash(target, cash, nil, true);
								nexus.player.UpdateStorageCash( player, nexus.player.GetCash(target) );
							end;
							
							if (storageTable.OnGiveCash) then
								if ( storageTable.OnGiveCash(player, storageTable, cash) ) then
									nexus.player.CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		nexus.player.Notify(player, "You do not have storage open!");
	end;
end;

nexus.command.Register( COMMAND, "StorageGive"..string.gsub(cashName, "%s", "") );

COMMAND = {};
COMMAND.tip = "Take an item from storage.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		local target = storageTable.entity;
		
		if ( IsValid(target) ) then
			local itemTable = nexus.item.Get( arguments[1] );
			
			if (itemTable) then
				local uniqueID = itemTable.uniqueID;
				
				if ( nexus.player.CanTakeFromStorage(player, uniqueID) ) then
					local newUniqueID = !itemTable.CanTakeStorage or itemTable:CanTakeStorage(player, storageTable);
					
					if (newUniqueID != false) then
						local result = !storageTable.CanTake or storageTable.CanTake(player, storageTable, uniqueID);
						local newItemTable = nexus.item.Get(newUniqueID);
						
						if ( type(newUniqueID) != "string" or !newItemTable ) then
							newItemTable = itemTable;
							newUniqueID = uniqueID;
						else
							newUniqueID = newItemTable.uniqueID;
						end;
						
						if (result != false) then
							if ( !target:IsPlayer() ) then
								if ( storageTable.inventory[uniqueID] ) then
									if ( player:UpdateInventory(newUniqueID, 1, nil, true) ) then
										nexus.player.UpdateStorageItem(player, uniqueID, -1);
										
										if (storageTable.OnTake) then
											if ( storageTable.OnTake(player, storageTable, newItemTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageTake) then
											if ( newItemTable:OnStorageTake(player, storageTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
									end
								end
							elseif ( target:HasItem(uniqueID) ) then
								local success = target:UpdateInventory(uniqueID, -1, nil, true);
								
								if (success) then
									local success = player:UpdateInventory(newUniqueID, 1, nil, true);
									
									if (!success) then
										target:UpdateInventory(uniqueID, 1, true, true);
									else
										if (storageTable.OnTake) then
											if ( storageTable.OnTake(player, storageTable, newItemTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageTake) then
											if ( newItemTable:OnStorageTake(player, storageTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
									end;
									
									nexus.player.UpdateStorageWeight( player, nexus.inventory.GetMaximumWeight(target) );
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		nexus.player.Notify(player, "You do not have storage open!");
	end;
end;

nexus.command.Register(COMMAND, "StorageTakeItem");

COMMAND = {};
COMMAND.tip = "Give an item to storage.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		local target = storageTable.entity;
		
		if ( IsValid(target) ) then
			local itemTable = nexus.item.Get( arguments[1] );
			
			if (itemTable) then
				local uniqueID = itemTable.uniqueID;
				
				if ( nexus.player.CanGiveToStorage(player, uniqueID) ) then
					local newUniqueID = !itemTable.CanGiveStorage or itemTable:CanGiveStorage(player, storageTable);
					
					if (newUniqueID != false) then
						local result = !storageTable.CanGive or storageTable.CanGive(player, storageTable, uniqueID);
						local newItemTable = nexus.item.Get(newUniqueID);
						
						if ( type(newUniqueID) != "string" or !newItemTable ) then
							newItemTable = itemTable;
							newUniqueID = uniqueID;
						else
							newUniqueID = newItemTable.uniqueID;
						end;
						
						if (result != false) then
							if ( !target:IsPlayer() ) then
								if ( player:HasItem(uniqueID) ) then
									if ( player:UpdateInventory(uniqueID, -1, nil, true) ) then
										local weight = newItemTable.storageWeight or newItemTable.weight;
										
										if (nexus.player.GetStorageWeight(player) + math.max(weight, 0) <= storageTable.weight) then
											nexus.player.UpdateStorageItem(player, newUniqueID, 1);
											
											if (storageTable.OnGive) then
												if ( storageTable.OnGive(player, storageTable, newItemTable) ) then
													nexus.player.CloseStorage(player);
												end;
											end;
											
											if (newItemTable.OnStorageGive) then
												if ( newItemTable:OnStorageGive(player, storageTable) ) then
													nexus.player.CloseStorage(player);
												end;
											end;
										else
											player:UpdateInventory(uniqueID, 1, true, true);
										end;
									end;
								end;
							elseif ( player:HasItem(uniqueID) ) then
								local success = player:UpdateInventory(uniqueID, -1, nil, true);
								
								if (success) then
									local success = target:UpdateInventory(newUniqueID, 1, nil, true);
									
									if (!success) then
										player:UpdateInventory(uniqueID, 1, true, true);
									else
										if (storageTable.OnGive) then
											if ( storageTable.OnGive(player, storageTable, newItemTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageGive) then
											if ( newItemTable:OnStorageGive(player, storageTable) ) then
												nexus.player.CloseStorage(player);
											end;
										end;
									end;
									
									nexus.player.UpdateStorageWeight( player, nexus.inventory.GetMaximumWeight(target) );
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		nexus.player.Notify(player, "You do not have storage open!");
	end;
end;

nexus.command.Register(COMMAND, "StorageGiveItem");

COMMAND = {};
COMMAND.tip = "Run an inventory action on an item.";
COMMAND.text = "<string Item> <string Action>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = arguments[1];
	local amount = player:HasItem(item);
	local itemTable = nexus.item.Get(item);
	local itemFunction = string.lower( arguments[2] );
	
	if (itemTable) then
		item = itemTable.uniqueID;
		
		if (amount and amount > 0) then
			if (itemTable.customFunctions) then
				for k, v in ipairs(itemTable.customFunctions) do
					if (string.lower(v) == itemFunction) then
						if (itemTable.OnCustomFunction) then
							itemTable:OnCustomFunction(player, v);
							
							return;
						end;
					end;
				end;
			end;
			
			if (itemFunction == "destroy") then
				if ( nexus.mount.Call("PlayerCanDestroyItem", player, itemTable) ) then
					nexus.item.Destroy(player, item);
				end;
			elseif (itemFunction == "drop") then
				local position = player:GetEyeTraceNoCursor().HitPos;
				
				if (player:GetShootPos():Distance(position) <= 192) then
					if ( nexus.mount.Call("PlayerCanDropItem", player, itemTable, position) ) then
						nexus.item.Drop(player, item);
					end;
				else
					nexus.player.Notify(player, "You cannot drop the item that far away!");
				end;
			elseif (itemFunction == "use") then
				if (player:InVehicle() and itemTable.useInVehicle == false) then
					nexus.player.Notify(player, "You cannot use this item in a vehicle!");
					
					return;
				end;
				
				if ( nexus.mount.Call("PlayerCanUseItem", player, itemTable) ) then
					return nexus.item.Use(player, item);
				end;
			else
				nexus.mount.Call( "PlayerUseUnknownItemFunction", player, itemTable, arguments[2] );
			end;
		else
			nexus.player.Notify(player, "You do not own a "..itemTable.name.."!");
			
			player:UpdateInventory(item, 0);
		end;
	end;
end;

nexus.command.Register(COMMAND, "InvAction");

COMMAND = {};
COMMAND.tip = "Drop your weapon at your target position.";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		local class = weapon:GetClass();
		local itemTable = nexus.item.GetWeapon(weapon);
		
		if (itemTable) then
			if ( nexus.mount.Call("PlayerCanDropWeapon", player, nil, itemTable) ) then
				local trace = player:GetEyeTraceNoCursor();
				
				if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
					local entity = nexus.entity.CreateItem(player, itemTable.uniqueID, trace.HitPos);
					
					if ( IsValid(entity) ) then
						nexus.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						
						player:StripWeapon(class);
						player:SelectWeapon("nx_hands");
						
						nexus.mount.Call("PlayerDropWeapon", player, itemTable, entity);
					end;
				else
					nexus.player.Notify(player, "You cannot drop your weapon that far away!");
				end;
			end;
		else
			nexus.player.Notify(player, "This is not a valid weapon!");
		end;
	else
		nexus.player.Notify(player, "This is not a valid weapon!");
	end;
end;

nexus.command.Register(COMMAND, "DropWeapon");

COMMAND = {};
COMMAND.tip = "Order an item shipment at your target position.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = nexus.item.Get( arguments[1] );
	
	if (item) then
		item = table.Copy(item);
		
		if (item.business and !item.isBaseItem) then
			if ( !NEXUS:HasObjectAccess(player, item) ) then
				nexus.player.Notify(player, "You not have access to order this item!");
				
				return false;
			else
				nexus.mount.Call("PlayerAdjustOrderItemTable", player, item);
				
				if ( nexus.mount.Call("PlayerCanOrderShipment", player, item) ) then
					if ( nexus.player.CanAfford(player, item.cost * item.batch) ) then
						if (item.CanOrder) then
							if (item:CanOrder(player, v) == false) then
								return;
							end;
						end;
						
						if (item.batch > 1) then
							nexus.player.GiveCash(player, -(item.cost * item.batch), item.batch.." "..item.plural);
							
							NEXUS:PrintDebug(player:Name().." ordered "..item.batch.." "..item.plural..".");
						else
							nexus.player.GiveCash(player, -(item.cost * item.batch), item.batch.." "..item.name);
							
							NEXUS:PrintDebug(player:Name().." ordered "..item.batch.." "..item.name..".");
						end;
						
						local trace = player:GetEyeTraceNoCursor();
						local entity;
						
						if (item.OnCreateShipmentEntity) then
							entity = item:OnCreateShipmentEntity(player, item.batch, trace.HitPos);
						end;
						
						if ( !IsValid(entity) ) then
							if (item.batch > 1) then
								entity = nexus.entity.CreateShipment(player, item.uniqueID, item.batch, trace.HitPos);
							else
								entity = nexus.entity.CreateItem(player, item.uniqueID, trace.HitPos);
							end;
						end;
						
						if ( IsValid(entity) ) then
							nexus.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						end;
						
						if (item.OnOrder) then
							item:OnOrder(player, entity);
						end;
						
						nexus.mount.Call("PlayerOrderShipment", player, item, entity);
						
						player.nextOrderItem = CurTime() + (5 * item.batch);
					else
						local amount = (item.cost * item.batch) - nexus.player.GetCash(player);
						
						nexus.player.Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
					end;
				end;
			end;
		else
			nexus.player.Notify(player, "This item is not available for order!");
		end;
	else
		nexus.player.Notify(player, "This is not a valid item!");
	end;
end;

nexus.command.Register(COMMAND, "OrderShipment");

COMMAND = {};
COMMAND.tip = "Get your character up from the floor.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:GetRagdollState() == RAGDOLL_FALLENOVER and player:GetSharedVar("sh_FallenOver") ) then
		if ( nexus.mount.Call("PlayerCanGetUp", player) ) then
			nexus.player.SetUnragdollTime(player, 5);
			
			player:SetSharedVar("sh_FallenOver", false);
		end;
	end;
end;

nexus.command.Register(COMMAND, "CharGetUp");

COMMAND = {};
COMMAND.tip = "Make your character fall to the floor.";
COMMAND.text = "[number Seconds]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( !player:InVehicle() ) then
		local seconds = tonumber( arguments[1] );
		
		if (seconds) then
			seconds = math.Clamp(seconds, 1, 30);
		end;
		
		if ( !player:IsRagdolled() ) then
			nexus.player.SetRagdollState(player, RAGDOLL_FALLENOVER, seconds);
			
			player:SetSharedVar("sh_FallenOver", true);
		end;
	else
		nexus.player.Notify(player, "You don't have permission to do this right now!");
	end;
end;

nexus.command.Register(COMMAND, "CharFallOver");

COMMAND = {};
COMMAND.tip = "Attempt to load a mount.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local mount = nexus.mount.Get( arguments[1] );
	
	if (mount) then
		if ( !nexus.mount.IsDisabled(mount.name) ) then
			local success = nexus.mount.SetUnloaded(mount.name, false);
			local recipients = {};
			
			if (success) then
				nexus.player.NotifyAll(player:Name().." has loaded the "..mount.name.." mount for the next restart.");
				
				for k, v in ipairs( g_Player.GetAll() ) do
					if ( v:HasInitialized() ) then
						if ( nexus.player.HasFlags(v, loadTable.access)
						or nexus.player.HasFlags(v, unloadTable.access) ) then
							recipients[#recipients + 1] = v;
						end;
					end;
				end;
				
				if (#recipients > 0) then
					NEXUS:StartDataStream( recipients, "OverwatchMntSet", {mount.name, false} );
				end;
			else
				nexus.player.Notify(player, "This mount could not be loaded!");
			end;
		else
			nexus.player.Notify(player, "This mount depends on another mount!");
		end;
	else
		nexus.player.Notify(player, "This mount is not valid!");
	end;
end;

nexus.command.Register(COMMAND, "MountLoad");

COMMAND = {};
COMMAND.tip = "Attempt to unload a mount.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local mount = nexus.mount.Get( arguments[1] );
	
	if (mount) then
		if ( !nexus.mount.IsDisabled(mount.name) ) then
			local success = nexus.mount.SetUnloaded(mount.name, true);
			local recipients = {};
			
			if (success) then
				nexus.player.NotifyAll(player:Name().." has unloaded the "..mount.name.." mount for the next restart.");
				
				for k, v in ipairs( g_Player.GetAll() ) do
					if ( v:HasInitialized() ) then
						if ( nexus.player.HasFlags(v, loadTable.access)
						or nexus.player.HasFlags(v, unloadTable.access) ) then
							recipients[#recipients + 1] = v;
						end;
					end;
				end;
				
				if (#recipients > 0) then
					NEXUS:StartDataStream( recipients, "OverwatchMntSet", {mount.name, true} );
				end;
			else
				nexus.player.Notify(player, "This mount could not be unloaded!");
			end;
		else
			nexus.player.Notify(player, "This mount depends on another mount!");
		end;
	else
		nexus.player.Notify(player, "This mount is not valid!");
	end;
end;

nexus.command.Register(COMMAND, "MountUnload");

COMMAND = {};
COMMAND.tip = "Send a radio message out to other characters.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	nexus.player.SayRadio(player, table.concat(arguments, " "), true);
end;

nexus.command.Register(COMMAND, "Radio");

COMMAND = {};
COMMAND.tip = "Send an event to all characters.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	nexus.chatBox.Add( nil, player, "event",  table.concat(arguments, " ") );
end;

nexus.command.Register(COMMAND, "Event");

COMMAND = {};
COMMAND.tip = "Roll a number between 0 and 100.";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	nexus.chatBox.AddInRadius( player, "roll", "has rolled "..math.random(0, 100).." out of 100.", player:GetPos(), nexus.config.Get("talk_radius"):Get() );
end;

nexus.command.Register(COMMAND, "Roll");

COMMAND = {};
COMMAND.tip = "Yell to characters near you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		nexus.player.Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	nexus.chatBox.AddInRadius(player, "yell", text, player:GetPos(), nexus.config.Get("talk_radius"):Get() * 2);
end;

nexus.command.Register(COMMAND, "Y");

COMMAND = {};
COMMAND.tip = "Describe a local action or event.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (string.len(text) < 8) then
		nexus.player.Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	nexus.chatBox.AddInTargetRadius(player, "it", text, player:GetPos(), nexus.config.Get("talk_radius"):Get() * 2);
end;

nexus.command.Register(COMMAND, "It");

COMMAND = {};
COMMAND.tip = "Speak in third person to others around you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		nexus.player.Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	nexus.chatBox.AddInTargetRadius(player, "me", string.gsub(text, "^.", string.lower), player:GetPos(), nexus.config.Get("talk_radius"):Get() * 2);
end;

nexus.command.Register(COMMAND, "Me");

COMMAND = {};
COMMAND.tip = "Whisper to characters near you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local talkRadius = math.min(nexus.config.Get("talk_radius"):Get() / 3, 80);
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		nexus.player.Notify(player, "You did not specify enough text!");
		
		return;
	end;
	
	nexus.chatBox.AddInRadius(player, "whisper", text, player:GetPos(), talkRadius);
end;

nexus.command.Register(COMMAND, "W");

if (SERVER) then
	concommand.Add("nx_status", function(player, command, arguments)
		if ( IsValid(player) ) then
			if ( nexus.player.IsAdmin(player) ) then
				player:PrintMessage(2, "# User ID | Name | Steam Name | Steam ID | IP Address");
				
				for k, v in ipairs( g_Player.GetAll() ) do
					if ( v:HasInitialized() ) then
						local status = nexus.mount.Call("PlayerCanSeeStatus", player, v);
						
						if (status) then
							player:PrintMessage(2, status);
						end;
					end;
				end;
			else
				player:PrintMessage(2, "You do not have access to this command, "..player:Name()..".");
			end;
		else
			print("# User ID | Name | Steam Name | Steam ID | IP Address");
			
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					print( "# "..v:UserID().." | "..v:Name().." | "..v:SteamName().." | "..v:SteamID().." | "..v:IPAddress() );
				end;
			end;
		end;
	end);
	
	concommand.Add("nx_dsStart", function(player, command, arguments)
		local name = arguments[1];
		local index = tonumber( arguments[2] );
		
		if (name and index) then
			player.NX_DS_NAME = name;
			player.NX_DS_DATA = "";
			player.NX_DS_INDEX = index;
		end;
	end);
	
	concommand.Add("nx_dsData", function(player, command, arguments)
		if (player.NX_DS_NAME and player.NX_DS_DATA and player.NX_DS_INDEX) then
			local data = arguments[1];
			local index = tonumber( arguments[2] );
			local replaceTable = { ["\\"] = "\\", ["n"] = "\n" };
			
			if (data and index) then
				player.NX_DS_DATA = player.NX_DS_DATA..data;
				
				if (player.NX_DS_INDEX == index) then
					player.NX_DS_DATA = string.gsub(player.NX_DS_DATA, "\\(.)", replaceTable);
					
					if ( NEXUS.DataStreamHooks[player.NX_DS_NAME] ) then
						NEXUS.DataStreamHooks[player.NX_DS_NAME]( player, glon.decode(player.NX_DS_DATA) );
					end;
					
					player.NX_DS_NAME = nil;
					player.NX_DS_DATA = nil;
					player.NX_DS_INDEX = nil;
				end;
			end;
		end;
	end);

	concommand.Add("nx_deathCode", function(player, command, arguments)
		if (player.deathCode) then
			if (arguments and tonumber( arguments[1] ) == player.deathCode) then
				player.deathCodeAuthenticated = true;
			end;
		end;
	end);
end;