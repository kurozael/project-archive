--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local COMMAND = {};

-- Set some information.
COMMAND.tip = "Give access to a character.";
COMMAND.text = "<character> <access>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s") ) then
			kuroScript.player.Notify(player, "You cannot give 'a' or 's' access!");
			
			-- Return to break the function.
			return;
		end;
		
		-- Give access to the player.
		kuroScript.player.GiveAccess( target, arguments[2] );
		
		-- Notify the player.
		kuroScript.player.NotifyAll(player:Name().." gave "..target:Name().." '"..arguments[2].."' access.");
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "giveaccess");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Take access from a character.";
COMMAND.text = "<character> <access>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s") ) then
			kuroScript.player.Notify(player, "You cannot take 'a' or 's' access!");
			
			-- Return to break the function.
			return;
		end;
		
		-- Take access from the player.
		kuroScript.player.TakeAccess( target, arguments[2] );
		
		-- Notify the player.
		kuroScript.player.NotifyAll(player:Name().." took '"..arguments[2].."' access from "..target:Name()..".");
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "takeaccess");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Kick a player.";
COMMAND.text = "<player> <reason>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] );
	local reason = table.concat(arguments, " ", 2);
	
	-- Check if a statement is true.
	if (!reason or reason == "") then
		reason = "N/A";
	end;
	
	-- Check if a statement is true.
	if (target) then
		kuroScript.player.NotifyAll(player:Name().." has kicked '"..target:Name().."' ("..reason..").");
		
		-- Kick the player.
		target:Kick(reason);
		
		-- Set some information.
		target._Kicked = true;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "kick");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Unban a Steam ID.";
COMMAND.text = "<ID|IP>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
	local game = GAME_FOLDER;
	
	-- Check if a statement is true.
	if ( string.find(string.upper( arguments[1] ), "STEAM") ) then
		local steamID = string.upper( arguments[1] );
		
		-- Check if a statement is true.
		if ( kuroScript.frame.BanList[steamID] ) then
			kuroScript.frame:RemoveBan(steamID);
			
			-- Perform a threaded query.
			tmysql.query("SELECT * FROM "..playersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..steamID.."\"", function(result)
				if ( ValidEntity(player) ) then
					if (result and type(result) == "table" and #result > 0) then
						kuroScript.frame:RemoveBan(result[1]._IPAddress);
						
						-- Notify each player.
						kuroScript.player.NotifyAll(player:Name().." has unbanned '"..result[1]._SteamName.."'.");
					else
						kuroScript.player.NotifyAll(player:Name().." has unbanned '"..steamID.."'.");
					end;
				end;
			end, 1);
		else
			kuroScript.player.Notify(player, steamID.." is not a banned Steam ID!");
		end;
	elseif ( string.find(arguments[1], "%d+%.%d+%.%d+%.%d+") ) then
		local ipAddress = arguments[1];
		
		-- Check if a statement is true.
		if ( kuroScript.frame.BanList[ipAddress] ) then
			kuroScript.frame:RemoveBan(ipAddress);
			
			-- Perform a threaded query.
			tmysql.query("SELECT * FROM "..playersTable.." WHERE _Game = \""..game.."\" AND _IPAddress = \""..ipAddress.."\"", function(result)
				if ( ValidEntity(player) ) then
					if (result and type(result) == "table" and #result > 0) then
						kuroScript.frame:RemoveBan(result[1]._SteamID);
						
						-- Notify each player.
						kuroScript.player.NotifyAll(player:Name().." has unbanned '"..result[1]._SteamName.."'.");
					else
						kuroScript.player.NotifyAll(player:Name().." has unbanned '"..ipAddress.."'.");
					end;
				end;
			end, 1);
		else
			kuroScript.player.Notify(player, ipAddress.." is not a banned IP address!");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unban");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Ban a player or Steam ID.";
COMMAND.text = "<player|ID|IP> <minutes> [reason]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local duration = tonumber( arguments[2] );
	local reason = table.concat(arguments, " ", 3);
	local target = kuroScript.player.Get( arguments[1] );
	local game = GAME_FOLDER;
	
	-- Check if a statement is true.
	if (!reason or reason == "") then
		reason = "N/A";
	end;
	
	-- Check if a statement is true.
	if (duration) then
		if (target) then
			if (duration > 0) then
				local hours = duration / 60;
				
				-- Check if a statement is true.
				if (hours >= 1) then
					kuroScript.player.NotifyAll(player:Name().." has banned '"..target:SteamName().."' for "..hours.." hour(s) ("..reason..").");
				else
					kuroScript.player.NotifyAll(player:Name().." has banned '"..target:SteamName().."' for "..duration.." minute(s) ("..reason..").");
				end;
			else
				kuroScript.player.NotifyAll(player:Name().." has banned '"..target:SteamName().."' permanently ("..reason..").");
			end;
			
			-- Add a ban.
			kuroScript.frame:AddBan(target:SteamID(), duration * 60, reason or "Kicked and Banned");
		elseif ( string.find(string.upper( arguments[1] ), "STEAM") ) then
			local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
			local steamID = string.upper( arguments[1] );
			
			-- Perform a threaded query.
			tmysql.query("SELECT * FROM "..playersTable.." WHERE _Game = \""..game.."\" AND _SteamID = \""..steamID.."\"", function(result)
				if ( ValidEntity(player) ) then
					local steamName = steamID;
					
					-- Check if a statement is true.
					if (result and type(result) == "table" and #result > 0) then
						steamName = result[1]._SteamName;
					end;
					
					-- Check if a statement is true.
					if (duration > 0) then
						local hours = duration / 60;
						
						-- Check if a statement is true.
						if (hours >= 1) then
							kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").");
						else
							kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..duration.." minute(s) ("..reason..").");
						end;
					else
						kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' permanently ("..reason..").");
					end;
					
					-- Add a ban.
					kuroScript.frame:AddBan(steamID, duration * 60, reason);
				end;
			end, 1);
		elseif ( string.find(arguments[1], "%d+%.%d+%.%d+%.%d+") ) then
			local playersTable = kuroScript.config.Get("mysql_players_table"):Get();
			
			-- Perform a threaded query.
			tmysql.query("SELECT * FROM "..playersTable.." WHERE _Game = \""..game.."\" AND _IPAddress = \""..ipAddress.."\"", function(result)
				if ( ValidEntity(player) ) then
					local steamName = ipAddress;
					
					-- Check if a statement is true.
					if (result and type(result) == "table" and #result > 0) then
						steamName = result[1]._SteamName;
					end;
					
					-- Check if a statement is true.
					if (duration > 0) then
						local hours = duration / 60;
						
						-- Check if a statement is true.
						if (hours >= 1) then
							kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..hours.." hour(s) ("..reason..").");
						else
							kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' for "..duration.." minute(s) ("..reason..").");
						end;
					else
						kuroScript.player.NotifyAll(player:Name().." has banned '"..steamName.."' permanently ("..reason..").");
					end;
					
					-- Add a ban.
					kuroScript.frame:AddBan(ipAddress, duration * 60, reason);
				end;
			end, 1);
		else
			kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid duration!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "ban");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Ban a character.";
COMMAND.text = "<character>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( table.concat(arguments, " ") );
	
	-- Check if a statement is true.
	if (target) then
		kuroScript.player.SetBanned(target, true);
		
		-- Notify each player.
		kuroScript.player.NotifyAll(player:Name().." banned the character '"..target:Name().."'.");
		
		-- Set some information.
		timer.Simple(3, function()
			if ( ValidEntity(target) ) then
				target:RunCommand("retry");
			end;
		end);
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "bancharacter");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Toggle whether your weapon is raised.";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.player.ToggleWeaponRaised(player);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "toggleraised");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set a character's name.";
COMMAND.text = "<character> <name>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		local name = table.concat(arguments, " ", 2);
		
		-- Notify the player.
		kuroScript.player.NotifyAll(player:Name().." set "..target:Name().."'s name to "..name..".");
		
		-- Set some information.
		kuroScript.player.SetName(target, name);
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "setname");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Transfer a character to a class.";
COMMAND.text = "<player> <class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		local class = arguments[2];
		local name = target:Name();
		
		-- Check if a statement is true.
		if ( kuroScript.class.stored[class] ) then
			if ( !kuroScript.class.stored[class].whitelist or kuroScript.player.IsWhitelisted(target, class) ) then
				local targetClass = target:QueryCharacter("class");
				
				-- Check if a statement is true.
				if (targetClass != class) then
					if ( kuroScript.class.IsGenderValid( class, target:QueryCharacter("gender") ) ) then
						if (kuroScript.class.stored[class].OnTransferred) then
							local success, fault = kuroScript.class.stored[class]:OnTransferred( target, kuroScript.class.stored[targetClass], arguments[3] );
							
							-- Check if a statement is true.
							if (success != false) then
								kuroScript.player.NotifyAll(player:Name().." has transferred "..name.." to the "..class.." class.");
								
								-- Set some information.
								target:SetCharacterData("class", class, true); kuroScript.player.SaveCharacter(target);
								
								-- Set some information.
								timer.Simple(3, function()
									if ( ValidEntity(target) ) then
										target:RunCommand("retry");
									end;
								end);
							else
								kuroScript.player.Notify(player, fault or target:Name().." could not be transferred to the "..class.." class!");
							end;
						else
							kuroScript.player.Notify(player, target:Name().." cannot be transferred to the "..class.." class!");
						end;
					else
						kuroScript.player.Notify(player, target:Name().." is not the correct gender for the "..class.." class!");
					end;
				else
					kuroScript.player.Notify(player, target:Name().." is already the "..class.." class!");
				end;
			else
				kuroScript.player.Notify(player, target:Name().." is not on the "..class.." whitelist!");
			end;
		else
			kuroScript.player.Notify(player, class.." is not a valid class!");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "transfer");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add a player to a whitelist.";
COMMAND.text = "<player> <class>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		local class = table.concat(arguments, " ", 2);
		
		-- Check if a statement is true.
		if ( kuroScript.class.stored[class] ) then
			if (kuroScript.class.stored[class].whitelist) then
				if ( !kuroScript.player.IsWhitelisted(target, class) ) then
					kuroScript.player.SetWhitelisted(target, class, true);
					kuroScript.player.SaveCharacter(target);
					
					-- Notify the player.
					kuroScript.player.NotifyAll(player:Name().." has added "..target:Name().." to the "..class.." whitelist.");
				else
					kuroScript.player.Notify(player, target:Name().." is already on the "..class.." whitelist!");
				end;
			else
				kuroScript.player.Notify(player, class.." does not have a whitelist!");
			end;
		else
			kuroScript.player.Notify(player, class.." is not a valid class!");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "whitelist");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Remove a player from a whitelist.";
COMMAND.text = "<player> <class>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		local class = table.concat(arguments, " ", 2);
		
		-- Check if a statement is true.
		if ( kuroScript.class.stored[class] ) then
			if (kuroScript.class.stored[class].whitelist) then
				if ( kuroScript.player.IsWhitelisted(target, class) ) then
					kuroScript.player.SetWhitelisted(target, class, false);
					kuroScript.player.SaveCharacter(target);
					
					-- Notify the player.
					kuroScript.player.NotifyAll(player:Name().." has removed "..target:Name().." from the "..class.." whitelist.");
				else
					kuroScript.player.Notify(player, target:Name().." is not on the "..class.." whitelist!");
				end;
			else
				kuroScript.player.Notify(player, class.." does not have a whitelist!");
			end;
		else
			kuroScript.player.Notify(player, class.." is not a valid class!");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unwhitelist");

-- Set some information.
COMMAND = {};
COMMAND.tip = "List the kuroScript config variables.";
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player:PrintMessage(2, "////////// [kuroScript - Config Variables] //////////");
	
	-- Set some information.
	local requiresRestart = {};
	local shared = {};
	local server = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.config.stored) do
		if (type(v.value) != "table") then
			if (v.restart and !v.static) then
				if (v.private) then
					requiresRestart[#requiresRestart + 1] = { k, string.rep( "*", string.len( tostring(v.value) ) ) };
				else
					requiresRestart[#requiresRestart + 1] = { k, tostring(v.value) };
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.config.stored) do
		if (type(v.value) != "table") then
			if (v.shared and !v.restart and !v.static) then
				if (v.private) then
					shared[#shared + 1] = { k, string.rep( "*", string.len( tostring(v.value) ) ) };
				else
					shared[#shared + 1] = { k, tostring(v.value) };
				end;
			end;
		end;
	end;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.config.stored) do
		if (type(v.value) != "table") then
			if (!v.shared and !v.restart and !v.static) then
				if (v.private) then
					server[#server + 1] = { k, string.rep( "*", string.len( tostring(v.value) ) ) };
				else
					server[#server + 1] = { k, tostring(v.value) };
				end;
			end;
		end;
	end;
	
	-- Sort the tables.
	table.sort(requiresRestart, function(a, b) return a[1] < b[1]; end);
	table.sort(shared, function(a, b) return a[1] < b[1]; end);
	table.sort(server, function(a, b) return a[1] < b[1]; end);
	
	-- Loop through each value in a table.
	for k, v in ipairs(requiresRestart) do player:PrintMessage(2, "(Requires Restart) "..v[1].." = \""..v[2].."\"."); end;
	for k, v in ipairs(shared) do player:PrintMessage(2, "(Shared) "..v[1].." = \""..v[2].."\"."); end;
	for k, v in ipairs(server) do player:PrintMessage(2, "(Server) "..v[1].." = \""..v[2].."\"."); end;
	
	-- Notify the player.
	player:PrintMessage(2, "////////// [kuroScript - Config Variables] //////////");
	
	-- Notify the player.
	kuroScript.player.Notify(player, "The config variables have been printed to the console.");
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "listconfig");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set a kuroScript config variable.";
COMMAND.text = "<key> [value|!default] [map]";
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local key = arguments[1];
	local value = arguments[2] or "";
	local configObject = kuroScript.config.Get(key);
	
	-- Check if a statement is true.
	if ( configObject:IsValid() ) then
		local appendix = "";
		local map = arguments[3];
		
		-- Check if a statement is true.
		if (map) then
			map = string.lower(map); appendix = map.."'s ";
		end;
		
		-- Check if a statement is true.
		if ( !configObject:Query("static") ) then
			value = configObject:Set(value, map);
			
			-- Check if a statement is true.
			if (value != nil) then
				value = tostring(value);
				
				-- Check if a statement is true.
				if ( configObject:Query("private") ) then
					if ( configObject:Query("restart") ) then
						kuroScript.player.NotifyAll(player:Name().." set "..appendix..key.." to '"..string.rep( "*", string.len(value) ).."' for the next restart.");
					else
						kuroScript.player.NotifyAll(player:Name().." set "..appendix..key.." to '"..string.rep( "*", string.len(value) ).."'.");
					end;
				elseif ( configObject:Query("restart") ) then
					kuroScript.player.NotifyAll(player:Name().." set "..appendix..key.." to '"..value.."' for the next restart.");
				else
					kuroScript.player.NotifyAll(player:Name().." set "..appendix..key.." to '"..value.."'.");
				end;
			else
				kuroScript.player.Notify(player, key.." was unable to be set!");
			end;
		else
			kuroScript.player.Notify(player, key.." is a static config key!");
		end;
	else
		kuroScript.player.Notify(player, key.." is not a valid config key!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "setconfig");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set your character's details.";
COMMAND.text = "<text|none>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( arguments[1] ) then
		local text = table.concat(arguments, " ");
		
		-- Check if a statement is true.
		if (string.len(text) < 8) then
			kuroScript.player.Notify(player, "You did not specify enough text!");
			
			-- Return to break the function.
			return;
		end;
		
		-- Set some information.
		player:SetCharacterData( "details", kuroScript.frame:ModifyDetails(text) );
	else
		umsg.Start("ks_Details", player);
		umsg.End();
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "details");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Give an item to a character.";
COMMAND.text = "<character> <item>";
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] );
	
	-- Check if a statement is true.
	if (target) then
		local item = kuroScript.item.Get( arguments[2] );
		
		-- Check if a statement is true.
		if (item) then
			local success, fault = kuroScript.inventory.Update(target, item.uniqueID, 1, true);
			
			-- Check if a statement is true.
			if (!success) then
				kuroScript.player.Notify(player, target:Name().." does not have enough space for this item!");
			else
				if (string.sub(item.name, -1) == "s") then
					kuroScript.player.Notify(player, "You have given "..target:Name().." some "..item.name..".", 0);
				else
					kuroScript.player.Notify(player, "You have given "..target:Name().." a "..item.name..".", 0);
				end;
				
				-- Check if a statement is true.
				if (player != target) then
					if (string.sub(item.name, -1) == "s") then
						kuroScript.player.Notify(target, player:Name().." has given you some "..item.name..".", 0);
					else
						kuroScript.player.Notify(target, player:Name().." has given you a "..item.name..".", 0);
					end;
				end;
				
				-- Notify the player.
				kuroScript.player.Notify(player, "Hey you little bitch, I've got my eye on you!");
			end;
		else
			kuroScript.player.Notify(player, "This is not a valid item!");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "giveitem");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Give "..string.lower(NAME_CURRENCY_LOWER).." to the character you're looking at.";
COMMAND.text = "<"..string.lower(NAME_CURRENCY_LOWER)..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( target and target:IsPlayer() ) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			local currency = tonumber( arguments[1] );
			
			-- Check if a statement is true.
			if (currency and currency > 0) then
				currency = math.floor(currency);
				
				-- Check if a statement is true.
				if ( kuroScript.player.CanAfford(player, currency) ) then
					local playerName = player:Name();
					local targetName = target:Name();
					
					-- Check if a statement is true.
					if ( !kuroScript.player.KnowsPlayer(player, target) ) then
						targetName = kuroScript.config.Get("anonymous_name"):Get();
					end;
					
					-- Check if a statement is true.
					if ( !kuroScript.player.KnowsPlayer(target, player) ) then
						playerName = kuroScript.config.Get("anonymous_name"):Get();
					end;
					
					-- Give the currency to the target and take it from the player.
					kuroScript.player.GiveCurrency(player, -currency, targetName);
					kuroScript.player.GiveCurrency(target, currency, playerName);
				else
					local amount = currency - player:QueryCharacter("currency");
					
					-- Notify the player.
					kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
				end;
			else
				kuroScript.player.Notify(player, "This is not a valid amount!");
			end;
		else
			kuroScript.player.Notify(player, "This character is too far away!");
		end;
	else
		kuroScript.player.Notify(player, "You must look at a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register( COMMAND, "give"..string.lower( string.gsub(NAME_CURRENCY, "%s", "") ) );

-- Set some information.
COMMAND = {};
COMMAND.tip = "Send a private message to a player.";
COMMAND.text = "<player> <text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		kuroScript.chatBox.Add( {player, target}, player, "pm", table.concat(arguments, " ", 2) );
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "pm");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Drop "..string.lower(NAME_CURRENCY_LOWER).." at your target position.";
COMMAND.text = "<"..string.lower(NAME_CURRENCY_LOWER)..">";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local currency = tonumber( arguments[1] );
	
	-- Check if a statement is true.
	if (currency and currency > 0) then
		currency = math.floor(currency);
		
		-- Check if a statement is true.
		if (currency >= 10) then
			if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
				if ( kuroScript.player.CanAfford(player, currency) ) then
					kuroScript.player.GiveCurrency(player, -currency, "Currency");
					
					-- Set some information.
					local entity = kuroScript.entity.CreateCurrency(player, currency, trace.HitPos);
					
					-- Check if a statement is true.
					if ( ValidEntity(entity) ) then
						kuroScript.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
					end;
				else
					local amount = currency - player:QueryCharacter("currency");
					
					-- Notify the player.
					kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
				end;
			else
				kuroScript.player.Notify(player, "You cannot drop "..string.lower(NAME_CURRENCY_LOWER).." that far away!");
			end;
		else
			kuroScript.player.Notify(player, "You must drop a minimum of "..FORMAT_CURRENCY(10, nil, true).."!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid amount!");
	end;
end;

-- Register the command.
kuroScript.command.Register( COMMAND, "drop"..string.lower( string.gsub(NAME_CURRENCY, "%s", "") ) );

-- Set some information.
COMMAND = {};
COMMAND.tip = "Yell to characters near you.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (text == "") then
		kuroScript.player.Notify(player, "You did not specify enough text!");
		
		-- Return to break the function.
		return;
	end;
	
	-- Add a message in the player's radius.
	kuroScript.chatBox.AddInRadius(player, "yell", text, player:GetPos(), kuroScript.config.Get("talk_radius"):Get() * 2);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "y");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add a server event.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Notify the player.
	kuroScript.chatBox.Add(nil, player, "event", text);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "event");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Describe a local event.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (string.len(text) < 8) then
		kuroScript.player.Notify(player, "You did not specify enough text!");
		
		-- Return to break the function.
		return;
	end;
	
	-- Add a message in the player's radius.
	kuroScript.chatBox.AddInRadius(player, "it", text, player:GetPos(), kuroScript.config.Get("talk_radius"):Get() * 2);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "it");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Speak in third person.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (text == "") then
		kuroScript.player.Notify(player, "You did not specify enough text!");
		
		-- Return to break the function.
		return;
	end;
	
	-- Add a message in the player's radius.
	kuroScript.chatBox.AddInRadius(player, "me", string.gsub(text, "^.", string.lower), player:GetPos(), kuroScript.config.Get("talk_radius"):Get() * 2);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "me");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Whisper to characters near you.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local talkRadius = kuroScript.config.Get("talk_radius"):Get() / 3;
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (text == "") then
		kuroScript.player.Notify(player, "You did not specify enough text!");
		
		-- Return to break the function.
		return;
	end;
	
	-- Check if a statement is true.
	if (talkRadius > 80) then talkRadius = 80; end;
	
	-- Add a message in the player's radius.
	kuroScript.chatBox.AddInRadius(player, "whisper", text, player:GetPos(), talkRadius);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "w");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Change your vocation.";
COMMAND.text = "<vocation>";
COMMAND.flags = CMD_HEAVY;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local vocation = kuroScript.vocation.Get( arguments[1] );
	
	-- Check if a statement is true.
	if (vocation) then
		if ( vocation.class == player:QueryCharacter("class") ) then
			local limit = vocation.limit;
			
			-- Check if a statement is true.
			if ( hook.Call("PlayerCanBypassVocationLimit", player, vocation.index) ) then
				limit = MaxPlayers();
			end;
			
			-- Check if a statement is true.
			if (g_Team.NumPlayers(vocation.index) >= limit) then
				kuroScript.player.Notify(player, "There are too many characters with this vocation!");
			else
				local previousTeam = player:Team();
				
				-- Check if a statement is true.
				if (player:Team() != vocation.index) then
					if ( hook.Call("PlayerCanChangeVocation", kuroScript.frame, player, vocation.index) ) then
						local success, fault = kuroScript.vocation.Set(player, vocation.index);
						
						-- Check if a statement is true.
						if (!success) then kuroScript.player.Notify(player, fault); end;
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "You can only choose vocations tied to your class!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid vocation!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "vocation");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Perform a storage action.";
COMMAND.text = "<giveitem|takeitem|givecurrency|takecurrency|close> <item|currency|none>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = arguments[2];
	local storageTable = player:GetStorageTable();
	
	-- Check if a statement is true.
	if (storageTable) then
		local target = kuroScript.entity.GetPlayer(storageTable.entity) or storageTable.entity;
		
		-- Check if a statement is true.
		if (ValidEntity(target) or arguments[1] == "close") then
			if (arguments[1] == "giveitem") then
				local itemTable = kuroScript.item.Get(item);
				
				-- Check if a statement is true.
				if (itemTable) then
					item = itemTable.uniqueID;
					
					-- Check if a statement is true.
					if ( kuroScript.player.CanGiveToStorage(player, item) ) then
						local newItem = !itemTable.CanGiveStorage or itemTable:CanGiveStorage(player, storageTable);
						
						-- Check if a statement is true.
						if (newItem != false) then
							local result = !storageTable.CanGive or storageTable.CanGive(player, storageTable, item);
							local newItemTable = kuroScript.item.Get(newItem);
							
							-- Check if a statement is true.
							if ( type(newItem) != "string" or !newItemTable ) then
								newItemTable = itemTable; newItem = item;
							else
								newItem = newItemTable.uniqueID;
							end;
							
							-- Check if a statement is true.
							if (result != false) then
								if ( !target:IsPlayer() ) then
									if ( kuroScript.inventory.HasItem(player, item) ) then
										if ( kuroScript.inventory.Update(player, item, -1, nil, true) ) then
											local weight = newItemTable.storageWeight or newItemTable.weight;
											
											-- Check if a statement is true.
											if (kuroScript.player.GetStorageWeight(player) + math.max(weight, 0) <= storageTable.weight) then
												kuroScript.player.UpdateStorageItem(player, newItem, 1);
												
												-- Check if a statement is true.
												if (storageTable.OnGive) then
													if ( storageTable.OnGive(player, storageTable, newItemTable) ) then
														kuroScript.player.CloseStorage(player);
													end;
												end;
												
												-- Check if a statement is true.
												if (newItemTable.OnStorageGive) then
													if ( newItemTable:OnStorageGive(player, storageTable) ) then
														kuroScript.player.CloseStorage(player);
													end;
												end;
											else
												kuroScript.inventory.Update(player, item, 1, true, true);
											end;
										end;
									end;
								elseif ( kuroScript.inventory.HasItem(player, item) ) then
									local success = kuroScript.inventory.Update(player, item, -1, nil, true);
									
									-- Check if a statement is true.
									if (success) then
										local success = kuroScript.inventory.Update(target, newItem, 1, nil, true);
										
										-- Check if a statement is true.
										if (!success) then
											kuroScript.inventory.Update(player, item, 1, true, true);
										else
											if (storageTable.OnGive) then
												if ( storageTable.OnGive(player, storageTable, newItemTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
											
											-- Check if a statement is true.
											if (newItemTable.OnStorageGive) then
												if ( newItemTable:OnStorageGive(player, storageTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
										end;
										
										-- Update the player's storage weight.
										kuroScript.player.UpdateStorageWeight( player, kuroScript.inventory.GetMaximumWeight(target) );
									end;
								end;
							end;
						end;
					end;
				end;
			elseif (arguments[1] == "takeitem") then
				local itemTable = kuroScript.item.Get(item);
				
				-- Check if a statement is true.
				if (itemTable) then
					item = itemTable.uniqueID;
					
					-- Check if a statement is true.
					if ( kuroScript.player.CanTakeFromStorage(player, item) ) then
						local newItem = !itemTable.CanTakeStorage or itemTable:CanTakeStorage(player, storageTable);
						
						-- Check if a statement is true.
						if (newItem != false) then
							local result = !storageTable.CanTake or storageTable.CanTake(player, storageTable, item);
							local newItemTable = kuroScript.item.Get(newItem);
							
							-- Check if a statement is true.
							if ( type(newItem) != "string" or !newItemTable ) then
								newItemTable = itemTable; newItem = item;
							else
								newItem = newItemTable.uniqueID;
							end;
							
							-- Check if a statement is true.
							if (result != false) then
								if ( !target:IsPlayer() ) then
									if ( storageTable.inventory[item] ) then
										if ( kuroScript.inventory.Update(player, newItem, 1, nil, true) ) then
											kuroScript.player.UpdateStorageItem(player, item, -1);
											
											-- Check if a statement is true.
											if (storageTable.inventory[item] == 0) then
												storageTable.inventory[item] = nil;
											end
											
											-- Check if a statement is true.
											if (storageTable.OnTake) then
												if ( storageTable.OnTake(player, storageTable, newItemTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
											
											-- Check if a statement is true.
											if (newItemTable.OnStorageTake) then
												if ( newItemTable:OnStorageTake(player, storageTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
										end
									end
								elseif ( kuroScript.inventory.HasItem(target, item) ) then
									local success = kuroScript.inventory.Update(target, item, -1, nil, true);
									
									-- Check if a statement is true.
									if (success) then
										local success = kuroScript.inventory.Update(player, newItem, 1, nil, true);
										
										-- Check if a statement is true.
										if (!success) then
											kuroScript.inventory.Update(target, item, 1, true, true);
										else
											if (storageTable.OnTake) then
												if ( storageTable.OnTake(player, storageTable, newItemTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
											
											-- Check if a statement is true.
											if (newItemTable.OnStorageTake) then
												if ( newItemTable:OnStorageTake(player, storageTable) ) then
													kuroScript.player.CloseStorage(player);
												end;
											end;
										end;
										
										-- Update the player's storage weight.
										kuroScript.player.UpdateStorageWeight( player, kuroScript.inventory.GetMaximumWeight(target) );
									end;
								end;
							end;
						end;
					end;
				end;
			elseif (arguments[1] == "givecurrency") then
				local currency = tonumber( arguments[2] );
				
				-- Check if a statement is true.
				if (currency and currency > 0) then
					if ( kuroScript.player.CanAfford(player, currency) ) then
						if ( !storageTable.CanGiveCurrency or (storageTable.CanGiveCurrency(player, storageTable, currency) != false) ) then
							if ( !target:IsPlayer() ) then
								if (kuroScript.player.GetStorageWeight(player) + (kuroScript.config.Get("currency_weight"):Get() * currency) <= storageTable.weight) then
									kuroScript.player.GiveCurrency(player, -currency, nil, true);
									kuroScript.player.UpdateStorageCurrency(player, storageTable.currency + currency);
								end;
							else
								kuroScript.player.GiveCurrency(player, -currency, nil, true);
								kuroScript.player.GiveCurrency(target, currency, nil, true);
								kuroScript.player.UpdateStorageCurrency( player, target:QueryCharacter("currency") );
							end;
							
							-- Check if a statement is true.
							if (storageTable.OnGiveCurrency) then
								if ( storageTable.OnGiveCurrency(player, storageTable, currency) ) then
									kuroScript.player.CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			elseif (arguments[1] == "takecurrency") then
				local currency = tonumber( arguments[2] );
				
				-- Check if a statement is true.
				if (currency and currency > 0) then
					if (currency <= storageTable.currency) then
						if ( !storageTable.CanTakeCurrency or (storageTable.CanTakeCurrency(player, storageTable, currency) != false) ) then
							if ( !target:IsPlayer() ) then
								kuroScript.player.GiveCurrency(player, currency, nil, true);
								kuroScript.player.UpdateStorageCurrency(player, storageTable.currency - currency);
							else
								kuroScript.player.GiveCurrency(player, currency, nil, true);
								kuroScript.player.GiveCurrency(target, -currency, nil, true);
								kuroScript.player.UpdateStorageCurrency( player, target:QueryCharacter("currency") );
							end;
							
							-- Check if a statement is true.
							if (storageTable.OnTakeCurrency) then
								if ( storageTable.OnTakeCurrency(player, storageTable, currency) ) then
									kuroScript.player.CloseStorage(player);
								end;
							end;
						end;
					end;
				end;
			elseif (arguments[1] == "close") then
				kuroScript.player.CloseStorage(player, true);
			end;
		end;
	else
		kuroScript.player.Notify(player, "You do not have storage open!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "storage");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Perform an inventory action on an item.";
COMMAND.text = "<item> <destroy|custom|drop|use>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = arguments[1];
	local amount = kuroScript.inventory.HasItem(player, item);
	local itemTable = kuroScript.item.Get(item);
	
	-- Check if a statement is true.
	if (itemTable) then
		item = itemTable.uniqueID;
		
		-- Set some information.
		arguments[2] = string.lower( arguments[2] );
		
		-- Check if a statement is true.
		if (amount and amount > 0) then
			if (itemTable.customFunctions) then
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in ipairs(itemTable.customFunctions) do
					if ( string.lower(v) == arguments[2] ) then
						if (itemTable.OnCustomFunction) then
							itemTable:OnCustomFunction(player, v);
							
							-- Return to break the function.
							return;
						end;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if (arguments[2] == "destroy") then
				if ( hook.Call("PlayerCanDestroyItem", kuroScript.frame, player, itemTable) ) then
					kuroScript.item.Destroy(player, item);
				end;
			elseif (arguments[2] == "drop") then
				local position = player:GetEyeTraceNoCursor().HitPos;
				
				-- Check if a statement is true.
				if (player:GetShootPos():Distance(position) <= 192) then
					if ( hook.Call("PlayerCanDropItem", kuroScript.frame, player, itemTable, position) ) then
						kuroScript.item.Drop(player, item);
					end;
				else
					kuroScript.player.Notify(player, "You cannot drop the item that far away!");
				end;
			elseif (arguments[2] == "use") then
				if ( !player:IsAdmin() and player._NextUseItem and player._NextUseItem > CurTime() ) then
					kuroScript.player.Notify(player, "You cannot use this item for another "..math.ceil( player._NextUseItem - CurTime() ).." second(s)!");
					
					-- Return to break the function.
					return;
				else
					player._NextUseItem = CurTime() + 2;
				end;
				
				-- Check if a statement is true.
				if (player:InVehicle() and itemTable.useInVehicle == false) then
					kuroScript.player.Notify(player, "You cannot use this item in a vehicle!");
					
					-- Return to break the function.
					return;
				end;
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerCanUseItem", kuroScript.frame, player, itemTable) ) then
					local weight = itemTable.equippedSize or itemTable.weight;
					
					-- Check if a statement is true.
					if (itemTable.weaponClass) then
						if ( kuroScript.config.Get("max_equip_weight"):Get() ) then
							if (kuroScript.config.Get("max_equip_weight"):Get() > 0) then
								if ( kuroScript.player.GetEquippedWeight(player) + weight > kuroScript.config.Get("max_equip_weight"):Get() ) then
									kuroScript.player.Notify(player, "You can only carry a total weapon weight of "..kuroScript.config.Get("max_equip_weight"):Get().." slot(s)!");
									
									-- Return to break the function.
									return;
								end;
							end;
						end;
						
						-- Check if a statement is true.
						if (itemTable.canUseAmmoless != true and !itemTable.meleeWeapon) then
							local success = nil;
							local k, v;
							
							-- Check if a statement is true.
							if (itemTable.primaryAmmoClass) then
								if (kuroScript.player.GetPrimaryAmmo(player, itemTable.weaponClass) == 0
								and player:GetAmmoCount(itemTable.primaryAmmoClass) == 0) then
									for k, v in pairs(kuroScript.item.stored) do
										if (!v.isBaseItem and v.ammoClass == itemTable.primaryAmmoClass) then
											if ( kuroScript.inventory.HasItem(player, k) ) then
												success = kuroScript.item.Use(player, k); break;
											end;
										end;
									end;
								else
									success = true;
								end;
							end;
							
							-- Check if a statement is true.
							if (!success) then
								if (itemTable.secondaryAmmoClass) then
									if (kuroScript.player.GetSecondaryAmmo(player, itemTable.weaponClass) == 0
									and player:GetAmmoCount(itemTable.secondaryAmmoClass) == 0) then
										for k, v in pairs(kuroScript.item.stored) do
											if (!v.isBaseItem and v.ammoClass == itemTable.secondaryAmmoClass) then
												if ( kuroScript.inventory.HasItem(player, k) ) then
													success = kuroScript.item.Use(player, k); break;
												end;
											end;
										end;
									else
										success = true;
									end;
								end;
							end;
							
							-- Check if a statement is true.
							if (!success) then
								kuroScript.player.Notify(player, "You do not have any ammo for this weapon!");
								
								-- Return to break the function.
								return;
							end;
						end;
						
						-- Set some information.
						player._NextHolsterWeapon = CurTime() + kuroScript.config.Get("holster_wait_time"):Get();
					end;
					
					-- Check if a statement is true.
					if ( itemTable.assembleTime and !player:GetItemEntity() ) then
						local assemble = itemTable.assembleTime;
						local waitTime = kuroScript.config.Get("holster_wait_time"):Get() + 2;
						local position = player:GetPos();
						
						-- Set some information.
						local info = {
							itemTable = itemTable,
							assemble = assemble != nil,
							waitTime = waitTime
						};
						
						-- Check if a statement is true.
						if (type(assemble) == "number") then
							info.waitTime = assemble;
						end;
						
						-- Call a gamemode hook.
						hook.Call("PlayerAdjustAssembleWeaponInfo", kuroScript.frame, player, info);
						
						-- Check if a statement is true.
						if (info.assemble and info.waitTime > 0) then
							kuroScript.player.SetAction(player, "assemble", info.waitTime);
							
							-- Set some information.
							kuroScript.player.ConditionTimer(player, info.waitTime, function()
								return player:GetPos() == position and player:Alive() and !player:IsRagdolled();
							end, function(success)
								if (success) then
									kuroScript.item.Use(player, item);
								end;
							end);
						else
							kuroScript.item.Use(player, item);
						end;
					else
						return kuroScript.item.Use(player, item);
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "You do not own a "..string.lower(itemTable.name).."!");
			
			-- Update the player's inventory.
			kuroScript.inventory.Update(player, item, 0);
		end;
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "inventory");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Holster your current weapon.";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() and player._NextHolsterWeapon and player._NextHolsterWeapon > CurTime() ) then
		kuroScript.player.Notify(player, "You cannot holster this weapon for another "..math.ceil( player._NextHolsterWeapon - CurTime() ).." second(s)!");
		
		-- Return false to break the function.
		return false;
	else
		player._NextHolsterWeapon = CurTime() + kuroScript.config.Get("holster_wait_time"):Get();
	end;
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local class = weapon:GetClass();
		local itemTable = kuroScript.item.GetWeapon(weapon);
		
		-- Check if a statement is true.
		if (itemTable) then
			if ( hook.Call("PlayerCanHolsterWeapon", kuroScript.frame, player, itemTable) ) then
				local success, fault = kuroScript.inventory.CanHaveItemUpdated(player, itemTable.uniqueID, 1);
				
				-- Check if a statement is true.
				if (!success) then
					kuroScript.player.Notify(player, fault);
				else
					local disassemble = itemTable.disassembleTime;
					local waitTime = kuroScript.config.Get("holster_wait_time"):Get();
					local position = player:GetPos();
					
					-- Set some information.
					local info = {
						disassemble = disassemble != nil,
						itemTable = itemTable,
						waitTime = waitTime
					};
					
					-- Check if a statement is true.
					if (disassemble) then
						if (type(disassemble) == "number") then
							info.waitTime = disassemble;
						else
							info.waitTime = kuroScript.config.Get("holster_wait_time"):Get() + 2;
						end;
					end;
					
					-- Call a gamemode hook.
					hook.Call("PlayerAdjustHolsterWeaponInfo", kuroScript.frame, player, info);
					
					-- Check if a statement is true.
					if (info.disassemble) then
						kuroScript.player.SetAction(player, "disassemble", info.waitTime);
					else
						kuroScript.player.SetAction(player, "holster", info.waitTime);
					end;
					
					-- Set some information.
					kuroScript.player.ConditionTimer(player, info.waitTime, function()
						return (!info.disassemble or player:GetPos() == position) and kuroScript.player.GetWeaponClass(player) == class;
					end, function(success)
						if (success) then
							local success, fault = kuroScript.inventory.Update(player, itemTable.uniqueID, 1);
							
							-- Check if a statement is true.
							if (!success) then
								kuroScript.player.Notify(player, fault);
							else
								player:StripWeapon(class); player:SelectWeapon("ks_hands");
								
								-- Call a gamemode hook.
								hook.Call("PlayerHolsterWeapon", kuroScript.frame, player, itemTable);
							end;
						end;
					end);
				end;
			end;
		else
			kuroScript.player.Notify(player, "This is not a valid weapon!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid weapon!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "holster");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Drop your current weapon at your target position.";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local weapon = player:GetActiveWeapon();
	
	-- Check if a statement is true.
	if ( ValidEntity(weapon) ) then
		local class = weapon:GetClass();
		local itemTable = kuroScript.item.GetWeapon(weapon);
		
		-- Check if a statement is true.
		if (itemTable) then
			if ( hook.Call("PlayerCanDropWeapon", kuroScript.frame, player, nil, itemTable) ) then
				local trace = player:GetEyeTraceNoCursor();
				
				-- Check if a statement is true.
				if (player:GetShootPos():Distance(trace.HitPos) <= 192) then
					local entity = kuroScript.entity.CreateItem(player, itemTable.uniqueID, trace.HitPos);
					
					-- Check if a statement is true.
					if ( ValidEntity(entity) ) then
						kuroScript.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						
						-- Strip the weapon from the player.
						player:StripWeapon(class);
						player:SelectWeapon("ks_hands");
						
						-- Call a gamemode hook.
						hook.Call("PlayerDropWeapon", kuroScript.frame, player, itemTable);
					end;
				else
					kuroScript.player.Notify(player, "You cannot drop your weapon that far away!");
				end;
			end;
		else
			kuroScript.player.Notify(player, "This is not a valid weapon!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid weapon!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "drop");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Order an item shipment.";
COMMAND.text = "<item>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local item = kuroScript.item.Get( arguments[1] );
	
	-- Check if a statement is true.
	if (item) then
		item = table.Copy(item);
		
		-- Check if a statement is true.
		if (item.business) then
			if ( !kuroScript.frame:HasObjectAccess(player, item) ) then
				kuroScript.player.Notify(player, "You not have access to order this item!");
				
				-- Return false to break the function.
				return false;
			elseif ( !player:IsAdmin() and player._NextOrderItem and player._NextOrderItem > CurTime() ) then
				kuroScript.player.Notify(player, "You cannot order this item for another "..math.ceil( player._NextOrderItem - CurTime() ).." second(s)!");
				
				-- Return false to break the function.
				return false;
			else
				hook.Call("PlayerAdjustOrderItemTable", kuroScript.frame, player, item);
				
				-- Check if a statement is true.
				if ( hook.Call("PlayerCanOrderShipment", kuroScript.frame, player, item) ) then
					if ( kuroScript.player.CanAfford(player, item.cost * item.batch) ) then
						if (item.CanOrder) then
							if (item:CanOrder(player, v) == false) then
								return;
							end;
						end;
						
						-- Check if a statement is true.
						if (item.batch > 1) then
							kuroScript.player.GiveCurrency(player, -(item.cost * item.batch), item.batch.." "..item.plural);
							
							-- Print a debug message.
							kuroScript.frame:PrintDebug(player:Name().." ordered "..item.batch.." "..item.plural..".");
						else
							kuroScript.player.GiveCurrency(player, -(item.cost * item.batch), item.batch.." "..item.name);
							
							-- Print a debug message.
							kuroScript.frame:PrintDebug(player:Name().." ordered "..item.batch.." "..item.name..".");
						end;
						
						-- Set some information.
						local trace = player:GetEyeTraceNoCursor();
						local entity;
						
						-- Check if a statement is true.
						if (item.OnCreateShipmentEntity) then
							entity = item:OnCreateShipmentEntity(player, item.batch, trace.HitPos);
						end;
						
						-- Check if a statement is true.
						if ( !ValidEntity(entity) ) then
							if (item.batch > 1) then
								entity = kuroScript.entity.CreateShipment(player, item.uniqueID, item.batch, trace.HitPos);
							else
								entity = kuroScript.entity.CreateItem(player, item.uniqueID, trace.HitPos);
							end;
						end;
						
						-- Check if a statement is true.
						if ( ValidEntity(entity) ) then
							kuroScript.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
						end;
						
						-- Check if a statement is true.
						if (item.OnOrder) then
							item:OnOrder(player, entity);
						end;
						
						-- Call a gamemode hook.
						hook.Call("PlayerOrderShipment", kuroScript.frame, player, item, entity);
						
						-- Set some information.
						player._NextOrderItem = CurTime() + (5 * item.batch);
					else
						local amount = (item.cost * item.batch) - player:QueryCharacter("currency");
						
						-- Notify the player.
						kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
					end;
				end;
			end;
		else
			kuroScript.player.Notify(player, "This item is not available for order!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid item!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "order");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Get up from the floor.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:GetRagdollState() == RAGDOLL_FALLENOVER and player:GetSharedVar("ks_FallenOver") ) then
		if ( hook.Call("PlayerCanGetUp", kuroScript.frame, player) ) then
			player:SetSharedVar("ks_FallenOver", false);
			
			-- Set the player's unragdoll time.
			kuroScript.player.SetUnragdollTime(player, 5);
		end;
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "getup");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Fall over at your current position.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( !player:IsRagdolled() ) then
		kuroScript.player.SetRagdollState(player, RAGDOLL_FALLENOVER);
		
		-- Set some information.
		player:SetSharedVar("ks_FallenOver", true);
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "fallover");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Send a radio message.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Say a radio message.
	kuroScript.player.SayRadio(player, text, true);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "radio");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Give your name to a character.";
COMMAND.text = "<text|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.player.GiveName( player, "ic", table.concat(arguments, " ") );
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "givename");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Whisper your name to a character.";
COMMAND.text = "<text|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.player.GiveName( player, "whisper", table.concat(arguments, " ") );
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "whispername");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Yell your name to a character.";
COMMAND.text = "<text|none>";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.player.GiveName( player, "yell", table.concat(arguments, " ") );
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "yellname");

-- Check if a statement is true.
if (SERVER) then
	concommand.Add("ks_status", function(player, command, arguments)
		if ( ValidEntity(player) ) then
			if ( player:IsAdmin() ) then
				player:PrintMessage(2, "# User ID | Name | Steam Name | Steam ID | IP Address");
				
				-- Set some information.
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in ipairs( g_Player.GetAll() ) do
					if ( v:HasInitialized() ) then
						local status = hook.Call("PlayerCanSeeStatus", kuroScript.frame, player, v);
						
						-- Check if a statement is true.
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
			
			-- Set some information.
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() ) then
					print( "# "..v:UserID().." | "..v:Name().." | "..v:SteamName().." | "..v:SteamID().." | "..v:IPAddress() );
				end;
			end;
		end;
	end);

	-- Add a console command.
	concommand.Add("ks_deathcode", function(player, command, arguments)
		if (player._DeathCode) then
			if (arguments and tonumber( arguments[1] ) == player._DeathCode) then
				player._DeathCodeAuthenticated = true;
			end;
		end;
	end);
end;