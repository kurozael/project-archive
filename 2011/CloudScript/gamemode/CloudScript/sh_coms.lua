--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local cashName = CloudScript.option:GetKey("name_cash");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Kick a player from the server.";
COMMAND.text = "<string Name> <reason>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] );
	local reason = table.concat(arguments, " ", 2);
	
	if (!reason or reason == "") then
		reason = "N/A";
	end;
	
	if (target) then
		CloudScript.player:NotifyAll(player:Name().." has kicked '"..target:Name().."' ("..reason..").");
		
		target:Kick(reason);
		
		target.kicked = true;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyKick");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set a player's user group.";
COMMAND.text = "<string Name> <string UserGroup>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] );
	local userGroup = arguments[2];
	
	if (userGroup != "superadmin" and userGroup != "admin"
	and userGroup != "operator") then
		CloudScript.player:Notify(player, "The user group must be superadmin, admin or operator!");
		
		return;
	end;
	
	if (target) then
		CloudScript.player:NotifyAll(player:Name().." has set "..target:Name().."'s user group to "..userGroup..".");
		target:SetCloudScriptUserGroup(userGroup);
		
		CloudScript.player:LightSpawn(target, true, true);
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlySetGroup");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Demote a player from their user group.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] );
	
	if (target) then
		local userGroup = target:GetCloudScriptUserGroup();
		
		if (userGroup != "user") then
			CloudScript.player:NotifyAll(player:Name().." has demoted "..target:Name().." from "..userGroup.." to user.");
			target:SetCloudScriptUserGroup("user");
			
			CloudScript.player:LightSpawn(target, true, true);
		else
			CloudScript.player:Notify(player, "This player is only a user and cannot be demoted!");
		end;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyDemote");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Unban a Steam ID from the server.";
COMMAND.text = "<string SteamID|IPAddress>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = CloudScript.config:Get("mysql_players_table"):Get();
	local schemaFolder = CloudScript:GetSchemaFolder();
	local identifier = string.upper( arguments[1] );
	
	if ( CloudScript.BanList[identifier] ) then
		CloudScript.player:NotifyAll(player:Name().." has unbanned '"..CloudScript.BanList[identifier].steamName.."'.");
		
		CloudScript:RemoveBan(identifier);
	else
		CloudScript.player:Notify(player, "There are no banned players with the '"..identifier.."' identifier!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyUnban");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Ban a player from the server.";
COMMAND.text = "<string Name|SteamID|IPAddress> <number Minutes> [string Reason]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local schemaFolder = CloudScript:GetSchemaFolder();
	local duration = tonumber( arguments[2] );
	local reason = table.concat(arguments, " ", 3);
	
	if (!reason or reason == "") then
		reason = nil;
	end;
	
	if (duration) then
		CloudScript:AddBan(arguments[1], duration * 60, reason, function(steamName, duration, reason)
			if ( IsValid(player) ) then
				if (steamName) then
					if (duration > 0) then
						local hours = math.Round(duration / 3600);
						
						if (hours >= 1) then
							CloudScript.player:NotifyAll(player:Name().." has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").");
						else
							CloudScript.player:NotifyAll(player:Name().." has banned '"..steamName.."' for "..math.Round(duration / 60).." minute(s) ("..reason..").");
						end;
					else
						CloudScript.player:NotifyAll(player:Name().." has banned '"..steamName.."' permanently ("..reason..").");
					end;
				else
					CloudScript.player:Notify(player, "This is not a valid identifier!");
				end;
			end;
		end);
	else
		CloudScript.player:Notify(player, "This is not a valid duration!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyBan");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Send a private message to a player.";
COMMAND.text = "<string Name> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local voicemail = target:GetCharacterData("voicemail");
		
		if (voicemail and voicemail != "") then
			CloudScript.chatBox:Add(player, target, "pm", voicemail);
		else
			CloudScript.chatBox:Add( {player, target}, player, "pm", table.concat(arguments, " ", 2) );
		end;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PM");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Add a player to a whitelist.";
COMMAND.text = "<string Name> <string Faction>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local faction = table.concat(arguments, " ", 2);
		
		if ( CloudScript.faction.stored[faction] ) then
			if (CloudScript.faction.stored[faction].whitelist) then
				if ( !CloudScript.player:IsWhitelisted(target, faction) ) then
					CloudScript.player:SetWhitelisted(target, faction, true);
					CloudScript.player:SaveCharacter(target);
					
					CloudScript.player:NotifyAll(player:Name().." has added "..target:Name().." to the "..faction.." whitelist.");
				else
					CloudScript.player:Notify(player, target:Name().." is already on the "..faction.." whitelist!");
				end;
			else
				CloudScript.player:Notify(player, faction.." does not have a whitelist!");
			end;
		else
			CloudScript.player:Notify(player, faction.." is not a valid faction!");
		end;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyWhitelist");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Teleport a player to your target location.";
COMMAND.text = "<string Name>";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] );
	
	if (target) then
		CloudScript.player:SetSafePosition(player, player:GetEyeTraceNoCursor().HitPos);
		CloudScript.player:NotifyAll(player:Name().." has teleported "..target:Name().." to their target location.");
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyTeleport");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Goto a player's location.";
COMMAND.text = "<string Name>";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] );
	
	if (target) then
		CloudScript.player:SetSafePosition( player, target:GetPos() );
		CloudScript.player:NotifyAll(player:Name().." has gone to "..target:Name().."'s location.");
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyGoto");


COMMAND = CloudScript.command:New();
COMMAND.tip = "Remove a player from a whitelist.";
COMMAND.text = "<string Name> <string Faction>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local faction = table.concat(arguments, " ", 2);
		
		if ( CloudScript.faction.stored[faction] ) then
			if (CloudScript.faction.stored[faction].whitelist) then
				if ( CloudScript.player:IsWhitelisted(target, faction) ) then
					CloudScript.player:SetWhitelisted(target, faction, false);
					CloudScript.player:SaveCharacter(target);
					
					CloudScript.player:NotifyAll(player:Name().." has removed "..target:Name().." from the "..faction.." whitelist.");
				else
					CloudScript.player:Notify(player, target:Name().." is not on the "..faction.." whitelist!");
				end;
			else
				CloudScript.player:Notify(player, faction.." does not have a whitelist!");
			end;
		else
			CloudScript.player:Notify(player, faction.." is not a valid faction!");
		end;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "PlyUnwhitelist");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Unban a character from being used.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( v:Name() == arguments[1] ) then
				CloudScript.player:NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
				CloudScript.player:SetBanned(player, false);
				
				return;
			else
				for k2, v2 in pairs( v:GetCharacters() ) do
					if ( v2.name == arguments[1] ) then
						CloudScript.player:NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
						v2.data.banned = false;
						
						return;
					end;
				end;
			end;
		end;
	end;
	
	local charactersTable = CloudScript.config:Get("mysql_players_table"):Get();
	local charName = tmysql.escape( arguments[1] );
	
	tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Name = \""..tmysql.escape(charName).."\"", function(result)
		if (result and type(result) == "table" and #result > 0) then
			tmysql.query("UPDATE "..charactersTable.." SET _Data = REPLACE(_Data, \"\"banned\":true\", \"\"banned\":false\") WHERE _Name = \""..tmysql.escape(charName).."\"");
			
			CloudScript.player:NotifyAll(player:Name().." unbanned the character '"..arguments[1].."'.");
		else
			CloudScript.player:NotifyAll("This is not a valid character!");
		end;
	end);
end;

CloudScript.command:Register(COMMAND, "CharUnban");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Ban a character from being used.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( table.concat(arguments, " ") );
	
	if (target) then
		CloudScript.player:SetBanned(target, true);
		CloudScript.player:NotifyAll(player:Name().." banned the character '"..target:Name().."'.");
		
		target:KillSilent();
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharBan");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set a character's model permanently.";
COMMAND.text = "<string Name> <string Model>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local model = table.concat(arguments, " ", 2);
		
		target:SetCharacterData("model", model, true);
		target:SetModel(model);
		
		CloudScript.player:NotifyAll(player:Name().." set "..target:Name().."'s model to "..model..".");
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharSetModel");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Change your character's physical description.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( arguments[1] ) then
		local minimumPhysDesc = CloudScript.config:Get("minimum_physdesc"):Get();
		local text = table.concat(arguments, " ");
		
		if (string.len(text) < minimumPhysDesc) then
			CloudScript.player:Notify(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
			
			return;
		end;
		
		player:SetCharacterData( "physdesc", CloudScript:ModifyPhysDesc(text) );
	else
		umsg.Start("cloud_PhysDesc", player);
		umsg.End();
	end;
end;

CloudScript.command:Register(COMMAND, "CharPhysDesc");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Give an item to a character.";
COMMAND.text = "<string Name> <string Item>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( CloudScript.player:HasFlags(player, "G") ) then
		local target = CloudScript.player:Get( arguments[1] );
		
		if (target) then
			local item = CloudScript.item:Get( arguments[2] );
			
			if (item) then
				local success, fault = target:UpdateInventory(item.uniqueID, 1, true, true);
				
				if (!success) then
					CloudScript.player:Notify(player, target:Name().." does not have enough space for this item!");
				else
					if (string.sub(item.name, -1) == "s") then
						CloudScript.player:Notify(player, "You have given "..target:Name().." some "..item.name..".");
					else
						CloudScript.player:Notify(player, "You have given "..target:Name().." a "..item.name..".");
					end;
					
					if (player != target) then
						if (string.sub(item.name, -1) == "s") then
							CloudScript.player:Notify(target, player:Name().." has given you some "..item.name..".");
						else
							CloudScript.player:Notify(target, player:Name().." has given you a "..item.name..".");
						end;
					end;
				end;
			else
				CloudScript.player:Notify(player, "This is not a valid item!");
			end;
		else
			CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		CloudScript.player:Notify(player, "I'm sorry, it seems like you cannot be trusted with this command!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharGiveItem");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set a character's name permanently.";
COMMAND.text = "<string Name> <string Name>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local name = table.concat(arguments, " ", 2);
		
		CloudScript.player:NotifyAll(player:Name().." set "..target:Name().."'s name to "..name..".");
		
		CloudScript.player:SetName(target, name);
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharSetName");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Transfer a character to a faction.";
COMMAND.text = "<string Name> <string Faction> [string Data]";
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		local faction = arguments[2];
		local name = target:Name();
		
		if ( CloudScript.faction.stored[faction] ) then
			if ( !CloudScript.faction.stored[faction].whitelist or CloudScript.player:IsWhitelisted(target, faction) ) then
				local targetFaction = target:QueryCharacter("faction");
				
				if (targetFaction != faction) then
					if ( CloudScript.faction:IsGenderValid( faction, CloudScript.player:GetGender(target) ) ) then
						if (CloudScript.faction.stored[faction].OnTransferred) then
							local success, fault = CloudScript.faction.stored[faction]:OnTransferred( target, CloudScript.faction.stored[targetFaction], arguments[3] );
							
							if (success != false) then
								target:SetCharacterData("faction", faction, true);
								
								CloudScript.player:LoadCharacter( target, CloudScript.player:GetCharacterID(target) );
								CloudScript.player:NotifyAll(player:Name().." has transferred "..name.." to the "..faction.." faction.");
							else
								CloudScript.player:Notify(player, fault or target:Name().." could not be transferred to the "..faction.." faction!");
							end;
						else
							CloudScript.player:Notify(player, target:Name().." cannot be transferred to the "..faction.." faction!");
						end;
					else
						CloudScript.player:Notify(player, target:Name().." is not the correct gender for the "..faction.." faction!");
					end;
				else
					CloudScript.player:Notify(player, target:Name().." is already the "..faction.." faction!");
				end;
			else
				CloudScript.player:Notify(player, target:Name().." is not on the "..faction.." whitelist!");
			end;
		else
			CloudScript.player:Notify(player, faction.." is not a valid faction!");
		end;
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharTransfer");

COMMAND.tip = "Give flags to a character.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o") ) then
			CloudScript.player:Notify(player, "You cannot give 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		CloudScript.player:GiveFlags( target, arguments[2] );
		
		CloudScript.player:NotifyAll(player:Name().." gave "..target:Name().." '"..arguments[2].."' flags.");
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharGiveFlags");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Take flags from a character.";
COMMAND.text = "<string Name> <string Flag(s)>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = CloudScript.player:Get( arguments[1] )
	
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o") ) then
			CloudScript.player:Notify(player, "You cannot take 'o', 'a' or 's' flags!");
			
			return;
		end;
		
		CloudScript.player:TakeFlags( target, arguments[2] );
		
		CloudScript.player:NotifyAll(player:Name().." took '"..arguments[2].."' flags from "..target:Name()..".");
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

CloudScript.command:Register(COMMAND, "CharTakeFlags");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Change the current map.";
COMMAND.text = "<string Map>";
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local map = string.lower( arguments[1] );
	
	if ( file.Exists("../maps/"..map..".bsp") ) then
		CloudScript.player:NotifyAll(player:Name().." is changing the map to "..map.." in 5 seconds!");
		
		timer.Simple(5, RunConsoleCommand, "changelevel", map);
	else
		CloudScript.player:Notify(player, arguments[1].." is not a valid map!");
	end;
end;

CloudScript.command:Register(COMMAND, "MapChange");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Restart the current map.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local map = string.lower( game.GetMap() );
	CloudScript.player:NotifyAll(player:Name().." is restarting the map in 5 seconds!");
	
	timer.Simple(5, RunConsoleCommand, "changelevel", map);
end;

CloudScript.command:Register(COMMAND, "MapRestart");

COMMAND = CloudScript.command:New();
COMMAND.tip = "List the CloudScript config variables.";
COMMAND.text = "[string Find]";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player:PrintMessage(2, "######## CloudScript -> Config ########");
		local search = arguments[1];
		local config = {};
		
		if (search) then
			search = string.lower(search);
		end;
		
		for k, v in pairs(CloudScript.config.stored) do
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
			local adminValues = CloudScript.config:GetSystem( v[1] );
			
			if (adminValues) then
				player:PrintMessage(2, "// "..systemValues.help);
			end;
			
			player:PrintMessage(2, v[1].." = \""..v[2].."\";");
		end;
	player:PrintMessage(2, "######## CloudScript -> Config ########");
	
	CloudScript.player:Notify(player, "The config variables have been printed to the console.");
end;

CloudScript.command:Register(COMMAND, "CfgListVars");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set a CloudScript config variable.";
COMMAND.text = "<string Key> [all Value] [string Map]";
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local key = arguments[1];
	local value = arguments[2] or "";
	local configObject = CloudScript.config:Get(key);
	
	if ( configObject:IsValid() ) then
		local keyPrefix = "";
		local useMap = arguments[3];
		
		if (useMap == "") then
			useMap = nil;
		end;
		
		if (useMap) then
			useMap = string.lower( CloudScript:Replace(useMap, ".bsp", "") );
			keyPrefix = useMap.."'s ";
			
			if ( !file.Exists("../maps/"..useMap..".bsp") ) then
				CloudScript.player:Notify(player, useMap.." is not a valid map!");
				
				return;
			end;
		end;
		
		if ( !configObject:Query("isStatic") ) then
			value = configObject:Set(value, useMap);
			
			if (value != nil) then
				local printValue = tostring(value);
				
				if ( configObject:Query("isPrivate") ) then
					if ( configObject:Query("needsRestart") ) then
						CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep( "*", string.len(printValue) ).."' for the next restart.");
					else
						CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..string.rep( "*", string.len(printValue) ).."'.");
					end;
				elseif ( configObject:Query("needsRestart") ) then
					CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."' for the next restart.");
				else
					CloudScript.player:NotifyAll(player:Name().." set "..keyPrefix..key.." to '"..printValue.."'.");
				end;
			else
				CloudScript.player:Notify(player, key.." was unable to be set!");
			end;
		else
			CloudScript.player:Notify(player, key.." is a static config key!");
		end;
	else
		CloudScript.player:Notify(player, key.." is not a valid config key!");
	end;
end;

CloudScript.command:Register(COMMAND, "CfgSetVar");

COMMAND = CloudScript.command:New();
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
			
			if (cash and cash > 1) then
				cash = math.floor(cash);
				
				if ( CloudScript.player:CanAfford(player, cash) ) then
					local playerName = player:Name();
					local targetName = target:Name();
					
					if ( !CloudScript.player:DoesRecognise(player, target) ) then
						targetName = CloudScript.config:Get("unrecognised_name"):Get();
					end;
					
					if ( !CloudScript.player:DoesRecognise(target, player) ) then
						playerName = CloudScript.config:Get("unrecognised_name"):Get();
					end;
					
					CloudScript.player:GiveCash(player, -cash, targetName);
					CloudScript.player:GiveCash(target, cash, playerName);
				else
					local amount = cash - CloudScript.player:GetCash(player);
					CloudScript.player:Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
				end;
			else
				CloudScript.player:Notify(player, "This is not a valid amount!");
			end;
		else
			CloudScript.player:Notify(player, "This character is too far away!");
		end;
	else
		CloudScript.player:Notify(player, "You must look at a valid character!");
	end;
end;

CloudScript.command:Register( COMMAND, "Give"..string.gsub(cashName, "%s", "") );

COMMAND = CloudScript.command:New();
COMMAND.tip = "Drop "..string.lower(cashName).." at your target position.";
COMMAND.text = "<number "..string.gsub(cashName, "%s", "")..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local cash = tonumber( arguments[1] );
	
	if (cash and cash > 1) then
		cash = math.floor(cash);
		
		if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
			if ( CloudScript.player:CanAfford(player, cash) ) then
				CloudScript.player:GiveCash( player, -cash, CloudScript.option:GetKey("name_cash") );
				
				local entity = CloudScript.entity:CreateCash(player, cash, trace.HitPos);
				
				if ( IsValid(entity) ) then
					CloudScript.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
				end;
			else
				local amount = cash - CloudScript.player:GetCash(player);
				CloudScript.player:Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
			end;
		else
			CloudScript.player:Notify(player, "You cannot drop "..string.lower(cashName).." that far away!");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid amount!");
	end;
end;

CloudScript.command:Register( COMMAND, "Drop"..string.gsub(cashName, "%s", "") );

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set your personal message voicemail.";
COMMAND.text = "[string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1] == "none") then
		player:SetCharacterData("voicemail", nil);
		
		CloudScript.player:Notify(player, "You have removed your voicemail.");
	else
		player:SetCharacterData( "voicemail", arguments[1] );
		
		CloudScript.player:Notify(player, "You have set your voicemail to '"..arguments[1].."'.");
	end;
end;

CloudScript.command:Register(COMMAND, "SetVoicemail");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set the class of your character.";
COMMAND.text = "<string Class>";
COMMAND.flags = CMD_HEAVY;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local class = CloudScript.class:Get( arguments[1] );
	
	if ( player:InVehicle() ) then
		CloudScript.player:Notify(player, "You don't have permission to do this right now!");
		
		return;
	end;
	
	if (class) then
		local limit = CloudScript.class:GetLimit(class.name);
		
		if ( CloudScript.plugin:Call("PlayerCanBypassClassLimit", player, class.index) ) then
			limit = MaxPlayers();
		end;
		
		if (_team.NumPlayers(class.index) >= limit) then
			CloudScript.player:Notify(player, "There are too many characters with this class!");
		else
			local previousTeam = player:Team();
			
			if (player:Team() != class.index) then
				if ( CloudScript:HasObjectAccess(player, class) ) then
					if ( CloudScript.plugin:Call("PlayerCanChangeClass", player, class) ) then
						local success, fault = CloudScript.class:Set(player, class.index, nil, true);
						
						if (!success) then
							CloudScript.player:Notify(player, fault);
						end;
					end;
				else
					CloudScript.player:Notify(player, "You do not have access to this class!");
				end;
			end;
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid class!");
	end;
end;

CloudScript.command:Register(COMMAND, "SetClass");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Close the active storage.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local storageTable = player:GetStorageTable();
	
	if (storageTable) then
		CloudScript.player:CloseStorage(player, true);
	else
		CloudScript.player:Notify(player, "You do not have storage open!");
	end;
end;

CloudScript.command:Register(COMMAND, "StorageClose");

COMMAND = CloudScript.command:New();
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
			if ( CloudScript.config:Get("cash_enabled"):Get() ) then
				local cash = tonumber( arguments[1] );
				
				if (cash and cash > 0) then
					if (cash <= storageTable.cash) then
						if ( !storageTable.CanTakeCash or (storageTable.CanTakeCash(player, storageTable, cash) != false) ) then
							if ( !target:IsPlayer() ) then
								CloudScript.player:GiveCash(player, cash, nil, true);
								CloudScript.player:UpdateStorageCash(player, storageTable.cash - cash);
							else
								CloudScript.player:GiveCash(player, cash, nil, true);
								CloudScript.player:GiveCash(target, -cash, nil, true);
								CloudScript.player:UpdateStorageCash( player, CloudScript.player:GetCash(target) );
							end;
							
							if (storageTable.OnTakeCash) then
								if ( storageTable.OnTakeCash(player, storageTable, cash) ) then
									CloudScript.player:CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		CloudScript.player:Notify(player, "You do not have storage open!");
	end;
end;

CloudScript.command:Register( COMMAND, "StorageTake"..string.gsub(cashName, "%s", "") );

COMMAND = CloudScript.command:New();
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
			if ( CloudScript.config:Get("cash_enabled"):Get() ) then
				local cash = tonumber( arguments[1] );
				
				if (cash and cash > 0) then
					if ( CloudScript.player:CanAfford(player, cash) ) then
						if ( !storageTable.CanGiveCash or (storageTable.CanGiveCash(player, storageTable, cash) != false) ) then
							if ( !target:IsPlayer() ) then
								if (CloudScript.player:GetStorageWeight(player) + (CloudScript.config:Get("cash_weight"):Get() * cash) <= storageTable.weight) then
									CloudScript.player:GiveCash(player, -cash, nil, true);
									CloudScript.player:UpdateStorageCash(player, storageTable.cash + cash);
								end;
							else
								CloudScript.player:GiveCash(player, -cash, nil, true);
								CloudScript.player:GiveCash(target, cash, nil, true);
								CloudScript.player:UpdateStorageCash( player, CloudScript.player:GetCash(target) );
							end;
							
							if (storageTable.OnGiveCash) then
								if ( storageTable.OnGiveCash(player, storageTable, cash) ) then
									CloudScript.player:CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		CloudScript.player:Notify(player, "You do not have storage open!");
	end;
end;

CloudScript.command:Register( COMMAND, "StorageGive"..string.gsub(cashName, "%s", "") );

COMMAND = CloudScript.command:New();
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
			local itemTable = CloudScript.item:Get( arguments[1] );
			
			if (itemTable) then
				local uniqueID = itemTable.uniqueID;
				
				if ( CloudScript.player:CanTakeFromStorage(player, uniqueID) ) then
					local newUniqueID = !itemTable.CanTakeStorage or itemTable:CanTakeStorage(player, storageTable);
					
					if (newUniqueID != false) then
						local result = !storageTable.CanTake or storageTable.CanTake(player, storageTable, uniqueID);
						local newItemTable = CloudScript.item:Get(newUniqueID);
						
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
										CloudScript.player:UpdateStorageItem(player, uniqueID, -1);
										
										if (storageTable.OnTake) then
											if ( storageTable.OnTake(player, storageTable, newItemTable) ) then
												CloudScript.player:CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageTake) then
											if ( newItemTable:OnStorageTake(player, storageTable) ) then
												CloudScript.player:CloseStorage(player);
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
												CloudScript.player:CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageTake) then
											if ( newItemTable:OnStorageTake(player, storageTable) ) then
												CloudScript.player:CloseStorage(player);
											end;
										end;
									end;
									
									CloudScript.player:UpdateStorageWeight( player, CloudScript.inventory:GetMaximumWeight(target) );
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		CloudScript.player:Notify(player, "You do not have storage open!");
	end;
end;

CloudScript.command:Register(COMMAND, "StorageTakeItem");

COMMAND = CloudScript.command:New();
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
			local itemTable = CloudScript.item:Get( arguments[1] );
			
			if (itemTable) then
				local uniqueID = itemTable.uniqueID;
				
				if ( CloudScript.player:CanGiveToStorage(player, uniqueID) ) then
					local newUniqueID = !itemTable.CanGiveStorage or itemTable:CanGiveStorage(player, storageTable);
					
					if (newUniqueID != false) then
						local result = !storageTable.CanGive or storageTable.CanGive(player, storageTable, uniqueID);
						local newItemTable = CloudScript.item:Get(newUniqueID);
						
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
										
										if (CloudScript.player:GetStorageWeight(player) + math.max(weight, 0) <= storageTable.weight) then
											CloudScript.player:UpdateStorageItem(player, newUniqueID, 1);
											
											if (storageTable.OnGive) then
												if ( storageTable.OnGive(player, storageTable, newItemTable) ) then
													CloudScript.player:CloseStorage(player);
												end;
											end;
											
											if (newItemTable.OnStorageGive) then
												if ( newItemTable:OnStorageGive(player, storageTable) ) then
													CloudScript.player:CloseStorage(player);
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
												CloudScript.player:CloseStorage(player);
											end;
										end;
										
										if (newItemTable.OnStorageGive) then
											if ( newItemTable:OnStorageGive(player, storageTable) ) then
												CloudScript.player:CloseStorage(player);
											end;
										end;
									end;
									
									CloudScript.player:UpdateStorageWeight( player, CloudScript.inventory:GetMaximumWeight(target) );
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	else
		CloudScript.player:Notify(player, "You do not have storage open!");
	end;
end;

CloudScript.command:Register(COMMAND, "StorageGiveItem");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Run an inventory action on an item.";
COMMAND.text = "<string Item> <string Action>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = arguments[1];
	local amount = player:HasItem(item);
	local itemTable = CloudScript.item:Get(item);
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
				if ( CloudScript.plugin:Call("PlayerCanDestroyItem", player, itemTable) ) then
					CloudScript.item:Destroy(player, item);
				end;
			elseif (itemFunction == "drop") then
				local position = player:GetEyeTraceNoCursor().HitPos;
				
				if (player:GetShootPos():Distance(position) <= 192) then
					if ( CloudScript.plugin:Call("PlayerCanDropItem", player, itemTable, position) ) then
						CloudScript.item:Drop(player, item);
					end;
				else
					CloudScript.player:Notify(player, "You cannot drop the item that far away!");
				end;
			elseif (itemFunction == "use") then
				if (player:InVehicle() and itemTable.useInVehicle == false) then
					CloudScript.player:Notify(player, "You cannot use this item in a vehicle!");
					
					return;
				end;
				
				if ( CloudScript.plugin:Call("PlayerCanUseItem", player, itemTable) ) then
					return CloudScript.item:Use(player, item);
				end;
			else
				CloudScript.plugin:Call( "PlayerUseUnknownItemFunction", player, itemTable, arguments[2] );
			end;
		else
			CloudScript.player:Notify(player, "You do not own a "..itemTable.name.."!");
			
			player:UpdateInventory(item, 0);
		end;
	end;
end;

CloudScript.command:Register(COMMAND, "InvAction");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Drop your weapon at your target position.";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		local class = weapon:GetClass();
		local itemTable = CloudScript.item:GetWeapon(weapon);
		
		if (itemTable) then
			if ( CloudScript.plugin:Call("PlayerCanDropWeapon", player, itemTable) ) then
				local trace = player:GetEyeTraceNoCursor();
				
				if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
					local entity = CloudScript.entity:CreateItem(player, itemTable.uniqueID, trace.HitPos);
					
					if ( IsValid(entity) ) then
						CloudScript.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						
						player:StripWeapon(class);
						player:SelectWeapon("cloud_hands");
						
						CloudScript.plugin:Call("PlayerDropWeapon", player, itemTable, entity);
					end;
				else
					CloudScript.player:Notify(player, "You cannot drop your weapon that far away!");
				end;
			end;
		else
			CloudScript.player:Notify(player, "This is not a valid weapon!");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid weapon!");
	end;
end;

CloudScript.command:Register(COMMAND, "DropWeapon");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Order an item shipment at your target position.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local itemTable = CloudScript.item:Get( arguments[1] );
	
	if (itemTable) then
		itemTable = table.Copy(itemTable);
		
		if (itemTable.business and !itemTable.isBaseItem) then
			if ( !CloudScript:HasObjectAccess(player, itemTable) ) then
				CloudScript.player:Notify(player, "You not have access to order this item!");
				
				return false;
			else
				CloudScript.plugin:Call("PlayerAdjustOrderItemTable", player, itemTable);
				
				if ( CloudScript.plugin:Call("PlayerCanOrderShipment", player, itemTable) ) then
					if ( CloudScript.player:CanAfford(player, itemTable.cost * itemTable.batch) ) then
						if (itemTable.CanOrder and itemTable:CanOrder(player, v) == false) then
							return;
						end;
						
						if (itemTable.batch > 1) then
							CloudScript.player:GiveCash(player, -(itemTable.cost * itemTable.batch), itemTable.batch.." "..itemTable.plural);
							CloudScript:PrintLog(4, player:Name().." has ordered "..itemTable.batch.." "..itemTable.plural..".");
						else
							CloudScript.player:GiveCash(player, -(itemTable.cost * itemTable.batch), itemTable.batch.." "..itemTable.name);
							CloudScript:PrintLog(4, player:Name().." has ordered "..itemTable.batch.." "..itemTable.name..".");
						end;
						
						local trace = player:GetEyeTraceNoCursor();
						local entity = nil;
						
						if (itemTable.OnCreateShipmentEntity) then
							entity = itemTable:OnCreateShipmentEntity(player, itemTable.batch, trace.HitPos);
						end;
						
						if ( !IsValid(entity) ) then
							if (itemTable.batch > 1) then
								entity = CloudScript.entity:CreateShipment(player, itemTable.uniqueID, itemTable.batch, trace.HitPos);
							else
								entity = CloudScript.entity:CreateItem(player, itemTable.uniqueID, trace.HitPos);
							end;
						end;
						
						if ( IsValid(entity) ) then
							CloudScript.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						end;
						
						if (itemTable.OnOrder) then
							itemTable:OnOrder(player, entity);
						end;
						
						CloudScript.plugin:Call("PlayerOrderShipment", player, itemTable, entity);
						player.nextOrderItem = CurTime() + (2 * itemTable.batch);
						
						umsg.Start("cloud_OrderTime", player);
							umsg.Long(player.nextOrderItem);
						umsg.End();
					else
						local amount = (itemTable.cost * itemTable.batch) - CloudScript.player:GetCash(player);
						CloudScript.player:Notify(player, "You need another "..FORMAT_CASH(amount, nil, true).."!");
					end;
				end;
			end;
		else
			CloudScript.player:Notify(player, "This item is not available for order!");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid item!");
	end;
end;

CloudScript.command:Register(COMMAND, "OrderShipment");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Get your character up from the floor.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:GetRagdollState() == RAGDOLL_FALLENOVER and player:GetSharedVar("fallenOver") ) then
		if ( CloudScript.plugin:Call("PlayerCanGetUp", player) ) then
			CloudScript.player:SetUnragdollTime(player, 5);
			
			player:SetSharedVar("fallenOver", false);
		end;
	end;
end;

CloudScript.command:Register(COMMAND, "CharGetUp");

--[[
	Removing this command will make your serial key
	become invalid. Remove this command at your own risk
	but do not complain when your serial key gets banned.
--]]

COMMAND = CloudScript.command:New();
COMMAND.tip = "Find out the license holder of this CloudScript schema.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:SteamID() == "STEAM_0:1:8387555") then
		CloudScript.player:Notify(player, "The license holder of this CloudScript schema is "..CloudScript:GetLicenseHolder()..".");
	else
		CloudScript.player:Notify(player, "You do not have the authority to view the license holder.");
	end;
end;

CloudScript.command:Register(COMMAND, "License");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Make your character fall to the floor.";
COMMAND.text = "[number Seconds]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local curTime = CurTime();
	
	if (!player.nextFallOver or curTime >= player.nextFallOver) then
		player.nextFallOver = curTime + 5;
		
		if ( !player:InVehicle() and !CloudScript.player:IsNoClipping(player) ) then
			local seconds = tonumber( arguments[1] );
			
			if (seconds) then
				seconds = math.Clamp(seconds, 2, 30);
			elseif (seconds == 0) then
				seconds = nil;
			end;
			
			if ( !player:IsRagdolled() ) then
				CloudScript.player:SetRagdollState(player, RAGDOLL_FALLENOVER, seconds);
				
				player:SetSharedVar("fallenOver", true);
			end;
		else
			CloudScript.player:Notify(player, "You don't have permission to do this right now!");
		end;
	end;
end;

CloudScript.command:Register(COMMAND, "CharFallOver");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Attempt to load a plugin.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local plugin = CloudScript.plugin:Get( arguments[1] );
	
	if (plugin) then
		if ( !CloudScript.plugin:IsDisabled(plugin.name) ) then
			local success = CloudScript.plugin:SetUnloaded(plugin.name, false);
			local recipients = {};
			
			if (success) then
				CloudScript.player:NotifyAll(player:Name().." has loaded the "..plugin.name.." plugin for the next restart.");
				
				for k, v in ipairs( _player.GetAll() ) do
					if ( v:HasInitialized() ) then
						if ( CloudScript.player:HasFlags(v, loadTable.access)
						or CloudScript.player:HasFlags(v, unloadTable.access) ) then
							recipients[#recipients + 1] = v;
						end;
					end;
				end;
				
				if (#recipients > 0) then
					CloudScript:StartDataStream( recipients, "AdminMntSet", {plugin.name, false} );
				end;
			else
				CloudScript.player:Notify(player, "This plugin could not be loaded!");
			end;
		else
			CloudScript.player:Notify(player, "This plugin depends on another plugin!");
		end;
	else
		CloudScript.player:Notify(player, "This plugin is not valid!");
	end;
end;

CloudScript.command:Register(COMMAND, "PluginLoad");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Attempt to unload a plugin.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local plugin = CloudScript.plugin:Get( arguments[1] );
	
	if (plugin) then
		if ( !CloudScript.plugin:IsDisabled(plugin.name) ) then
			local success = CloudScript.plugin:SetUnloaded(plugin.name, true);
			local recipients = {};
			
			if (success) then
				CloudScript.player:NotifyAll(player:Name().." has unloaded the "..plugin.name.." plugin for the next restart.");
				
				for k, v in ipairs( _player.GetAll() ) do
					if ( v:HasInitialized() ) then
						if ( CloudScript.player:HasFlags(v, loadTable.access)
						or CloudScript.player:HasFlags(v, unloadTable.access) ) then
							recipients[#recipients + 1] = v;
						end;
					end;
				end;
				
				if (#recipients > 0) then
					CloudScript:StartDataStream( recipients, "AdminMntSet", {plugin.name, true} );
				end;
			else
				CloudScript.player:Notify(player, "This plugin could not be unloaded!");
			end;
		else
			CloudScript.player:Notify(player, "This plugin depends on another plugin!");
		end;
	else
		CloudScript.player:Notify(player, "This plugin is not valid!");
	end;
end;

CloudScript.command:Register(COMMAND, "PluginUnload");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Send a radio message out to other characters.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	CloudScript.player:SayRadio(player, table.concat(arguments, " "), true);
end;

CloudScript.command:Register(COMMAND, "Radio");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Send an event to all characters.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	CloudScript.chatBox:Add( nil, player, "event",  table.concat(arguments, " ") );
end;

CloudScript.command:Register(COMMAND, "Event");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Roll a number between 0 and 100.";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	CloudScript.chatBox:AddInRadius( player, "roll", "has rolled "..math.random(0, 100).." out of 100.", player:GetPos(), CloudScript.config:Get("talk_radius"):Get() );
end;

CloudScript.command:Register(COMMAND, "Roll");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Yell to characters near you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		CloudScript.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	CloudScript.chatBox:AddInRadius(player, "yell", text, player:GetPos(), CloudScript.config:Get("talk_radius"):Get() * 2);
end;

CloudScript.command:Register(COMMAND, "Y");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Describe a local action or event.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (string.len(text) < 8) then
		CloudScript.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	CloudScript.chatBox:AddInTargetRadius(player, "it", text, player:GetPos(), CloudScript.config:Get("talk_radius"):Get() * 2);
end;

CloudScript.command:Register(COMMAND, "It");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Speak in third person to others around you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		CloudScript.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	

	CloudScript.chatBox:AddInTargetRadius(player, "me", string.gsub(text, "^.", string.lower), player:GetPos(), CloudScript.config:Get("talk_radius"):Get() * 2);
end;

CloudScript.command:Register(COMMAND, "Me");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Whisper to characters near you.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local talkRadius = math.min(CloudScript.config:Get("talk_radius"):Get() / 3, 80);
	local text = table.concat(arguments, " ");
	
	if (text == "") then
		CloudScript.player:Notify(player, "You did not specify enough text!");
		
		return;
	end;
	
	CloudScript.chatBox:AddInRadius(player, "whisper", text, player:GetPos(), talkRadius);
end;

CloudScript.command:Register(COMMAND, "W");

if (SERVER) then
	concommand.Add("cloud_status", function(player, command, arguments)
		if ( IsValid(player) ) then
			if ( CloudScript.player:IsAdmin(player) ) then
				player:PrintMessage(2, "# User ID | Name | Steam Name | Steam ID | IP Address");
				
				for k, v in ipairs( _player.GetAll() ) do
					if ( v:HasInitialized() ) then
						local status = CloudScript.plugin:Call("PlayerCanSeeStatus", player, v);
						
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
			
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() ) then
					print( "# "..v:UserID().." | "..v:Name().." | "..v:SteamName().." | "..v:SteamID().." | "..v:IPAddress() );
				end;
			end;
		end;
	end);
	
	concommand.Add("cloud_dsStart", function(player, command, arguments)
		local name = arguments[1];
		local index = tonumber( arguments[2] );
		
		if (name and index) then
			player.NX_DS_NAME = name;
			player.NX_DS_DATA = "";
			player.NX_DS_INDEX = index;
		end;
	end);
	
	concommand.Add("cloud_dsData", function(player, command, arguments)
		if (player.NX_DS_NAME and player.NX_DS_DATA and player.NX_DS_INDEX) then
			local data = arguments[1];
			local index = tonumber( arguments[2] );
			local replaceTable = { ["\\"] = "\\", ["n"] = "\n" };
			
			if (data and index) then
				player.NX_DS_DATA = player.NX_DS_DATA..data;
				
				if (player.NX_DS_INDEX == index) then
					player.NX_DS_DATA = string.gsub(player.NX_DS_DATA, "\\(.)", replaceTable);
					
					if ( CloudScript.DataStreamHooks[player.NX_DS_NAME] ) then
						CloudScript.DataStreamHooks[player.NX_DS_NAME]( player, glon.decode(player.NX_DS_DATA) );
					end;
					
					player.NX_DS_NAME = nil;
					player.NX_DS_DATA = nil;
					player.NX_DS_INDEX = nil;
				end;
			end;
		end;
	end);

	concommand.Add("cloud_deathCode", function(player, command, arguments)
		if (player.deathCode) then
			if (arguments and tonumber( arguments[1] ) == player.deathCode) then
				player.deathCodeAuthenticated = true;
			end;
		end;
	end);
end;