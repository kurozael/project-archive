--[[
Name: "sh_comm.lua".
Product: "HL2 RP".
--]]

local COMMAND = {};
 
-- Set some information.
COMMAND.tip = "Dispatch a message to all characters.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if (kuroScript.game:IsPlayerCombineRank( player, {"SCANNER", "DvL", "SeC"} ) or player:QueryCharacter("class") == CLASS_OTA) then
			local text = table.concat(arguments, " ");
			
			-- Check if a statement is true.
			if (text == "") then
				kuroScript.player.Notify(player, "You did not specify enough text!");
				
				-- Return to break the function.
				return;
			end;
			
			-- Say a dispatch message.
			kuroScript.game:SayDispatch(player, text);
		else
			kuroScript.player.Notify(player, "You are not ranked high enough to use this command!");
		end;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "dispatch");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Remove a player from a server whitelist.";
COMMAND.text = "<player> <identity>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	local identity = string.lower( arguments[2] );
	
	-- Check if a statement is true.
	if (target) then
		if ( target:GetData("serverwhitelist") ) then
			if ( !target:GetData("serverwhitelist")[identity] ) then
				kuroScript.player.Notify(player, target:Name().." is not on the '"..identity.."' server whitelist!");
				
				-- Return to break the function.
				return;
			else
				target:GetData("serverwhitelist")[identity] = nil;
			end;
		end;
		
		-- Save the player's character.
		kuroScript.player.SaveCharacter(target);
		
		-- Notify the player.
		kuroScript.player.NotifyAll(player:Name().." has removed "..target:Name().." from the '"..identity.."' server whitelist.");
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unserverwhitelist");

-- Set some information.
COMMAND = {};
COMMAND.tip = "As a scanner, follow the closest character to you.";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game.scanners[player] ) then
		local scanner = kuroScript.game.scanners[player][1];
		
		-- Check if a statement is true.
		if ( ValidEntity(scanner) ) then
			local closest;
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in ipairs( g_Player.GetAll() ) do
				if ( v:HasInitialized() and !kuroScript.game.scanners[v] ) then
					if ( kuroScript.player.CanSeeEntity(player, v, 0.9, true) ) then
						local distance = v:GetPos():Distance( scanner:GetPos() );
						
						-- Check if a statement is true.
						if ( !closest or distance < closest[2] ) then
							closest = {v, distance};
						end;
					end;
				end;
			end;
			
			-- Check if a statement is true.
			if (closest) then
				scanner._FollowTarget = closest[1];
				
				-- Fire an entity input.
				scanner:Input("SetFollowTarget", closest[1], closest[1], "!activator");
				
				-- Notify the player.
				kuroScript.player.Notify(player, "You are now following "..closest[1]:Name().."!");
			else
				kuroScript.player.Notify(player, "There are no characters near you!");
			end;
		end;
	else
		kuroScript.player.Notify(player, "You are not a scanner!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "follow");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add a player to a server whitelist.";
COMMAND.text = "<player> <identity>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	local identity = string.lower( arguments[2] );
	
	-- Check if a statement is true.
	if (target) then
		if ( target:GetData("serverwhitelist")[identity] ) then
			kuroScript.player.Notify(player, target:Name().." is already on the '"..identity.."' server whitelist!");
			
			-- Return to break the function.
			return;
		else
			target:GetData("serverwhitelist")[identity] = true;
		end;
		
		-- Save the player's character.
		kuroScript.player.SaveCharacter(target);
		
		-- Notify the player.
		kuroScript.player.NotifyAll(player:Name().." has added "..target:Name().." to the '"..identity.."' server whitelist.");
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "serverwhitelist");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Broadcast a message to all characters.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:QueryCharacter("class") == CLASS_CAD) then
		local text = table.concat(arguments, " ");
		
		-- Check if a statement is true.
		if (text == "") then
			kuroScript.player.Notify(player, "You did not specify enough text!");
			
			-- Return to break the function.
			return;
		end;
		
		-- Say a broadcast message.
		kuroScript.game:SayBroadcast(player, text);
	else
		kuroScript.player.Notify(player, "You are not a City Administrator!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "broadcast");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add a time-dispatch.";
COMMAND.text = "<time> <text|none>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if (kuroScript.game:IsPlayerCombineRank( player, {"SCANNER", "DvL", "SeC"} ) or player:QueryCharacter("class") == CLASS_OTA) then
			local timeInfo = arguments[1];
			
			-- Check if a statement is true.
			if ( string.find(timeInfo, "^%d%d:%d%d$") ) then
				local text = table.concat(arguments, " ", 2);
				
				-- Check if a statement is true.
				if (text == "") then
					kuroScript.player.Notify(player, "You did not specify enough text!");
					
					-- Return to break the function.
					return;
				end;
				
				-- Check if a statement is true.
				if (text == "none") then
					kuroScript.game.timeDispatches[timeInfo] = nil;
					
					-- Notify the player.
					kuroScript.player.Notify(player, "You have removed a time-dispatch.");
				else
					kuroScript.game.timeDispatches[timeInfo] = text;
					
					-- Notify the player.
					kuroScript.player.Notify(player, "You have added a time-dispatch.");
				end;
			else
				kuroScript.player.Notify(player, "This is not a valid time");
			end;
		else
			kuroScript.player.Notify(player, "You are not ranked high enough to use this command!");
		end;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "timedispatch");

-- Set some information.
COMMAND = {};
COMMAND.tip = "View or edit the staff data.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:IsUserGroup("operator") or player:IsAdmin() ) then
		datastream.StreamToClients( {player}, "ks_EditStaffData", kuroScript.game.staffData );
		
		-- Set some information.
		player._EditStaffDataAuthorised = true;
	else
		kuroScript.player.Notify(player, "You are not a staff member!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "staffdata");

-- Set some information.
COMMAND = {};
COMMAND.tip = "View or edit Civil Protection objectives.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		datastream.StreamToClients( {player}, "ks_EditObjectives", kuroScript.game.combineObjectives );
		
		-- Set some information.
		player._EditObjectivesAuthorised = true;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "objectives");

-- Set some information.
COMMAND = {};
COMMAND.tip = "View or edit data about a character.";
COMMAND.text = "<character>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		local target = kuroScript.player.Get( arguments[1] );
		
		-- Check if a statement is true.
		if (target) then
			if (player != target) then
				datastream.StreamToClients( {player}, "ks_EditData", { target, target:GetCharacterData("combinedata") } );
				
				-- Set some information.
				player._EditDataAuthorised = target;
			else
				kuroScript.player.Notify(player, "You cannot view or edit your own details!");
			end;
		else
			kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "data");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add an auto-dispatch.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if (kuroScript.game:IsPlayerCombineRank( player, {"SCANNER", "DvL", "SeC"} ) or player:QueryCharacter("class") == CLASS_OTA) then
			local text = table.concat(arguments, " ");
			
			-- Check if a statement is true.
			if (text == "") then
				kuroScript.player.Notify(player, "You did not specify enough text!");
				
				-- Return to break the function.
				return;
			end;
			
			-- Add an auto-dispatch.
			kuroScript.game.autoDispatches[#kuroScript.game.autoDispatches + 1] = text;
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added an auto-dispatch.");
		else
			kuroScript.player.Notify(player, "You are not ranked high enough to use this command!");
		end;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "autodispatch");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Request assistance from the Combine and City Administrators.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local isCityAdmin = (player:QueryCharacter("class") == CLASS_CAD);
	local isCombine = kuroScript.game:PlayerIsCombine(player);
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (text == "") then
		kuroScript.player.Notify(player, "You did not specify enough text!");
		
		-- Return to break the function.
		return;
	end;
	
	-- Check if a statement is true.
	if (kuroScript.inventory.HasItem(player, "request_device") or isCombine or isCityAdmin) then
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if (!player._NextRequestTime or isCityAdmin or isCombine or curTime >= player._NextRequestTime) then
			kuroScript.game:SayRequest(player, text);
			
			-- Check if a statement is true.
			if (!isCityAdmin and !isCombine) then
				player._NextRequestTime = curTime + 30;
			end;
		else
			kuroScript.player.Notify(player, "You cannot send a request for another "..math.ceil(player._NextRequestTime - curTime).." second(s)!");
		end;
	else
		kuroScript.player.Notify(player, "You do not own a request device!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "request");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set a character's custom class.";
COMMAND.text = "<character> <class|none>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		if (arguments[2] != "none") then
			target:SetCharacterData( "customclass", arguments[2] );
			
			-- Notify each player.
			kuroScript.player.NotifyAll(player:Name().." set "..target:Name().."'s custom class to "..arguments[2]..".");
		else
			target:SetCharacterData("customclass", nil);
			
			-- Notify each player.
			kuroScript.player.NotifyAll(player:Name().." removed "..target:Name().."'s custom class.");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "setcustomclass");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Permanently kill a character.";
COMMAND.text = "<character>";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		if ( target:Alive() ) then
			target._ForcePermaKill = true; target:Kill();
		elseif ( !target:GetCharacterData("permakilled") ) then
			kuroScript.game:PermaKillPlayer(target);
		else
			kuroScript.player.Notify(player, "This character is already permanently killed!");
			
			-- Return to break the function.
			return;
		end;
		
		-- Notify each player.
		kuroScript.player.NotifyAll(player:Name().." permanently killed the character '"..target:Name().."'.");
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "permakill");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set how long PK mode should be on for.";
COMMAND.text = "<minutes|cancel>";
COMMAND.access = "o";
COMMAND.arguments = 0;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local minutes = tonumber( arguments[1] );
	
	-- Check if a statement is true.
	if (minutes and minutes > 0) then
		kuroScript.frame:SetSharedVar("ks_PKMode", 1);
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Perma-Kill Mode", minutes * 60, 1, function()
			kuroScript.frame:SetSharedVar("ks_PKMode", 0);
			
			-- Notify each player.
			kuroScript.player.NotifyAll("Perma-kill mode has been cancelled, you are safe now.");
		end);
		
		-- Notify each player.
		kuroScript.player.NotifyAll(player:Name().." has enabled perma-kill mode for "..minutes.." minute(s), try not to be killed.");
	else
		kuroScript.frame:SetSharedVar("ks_PKMode", 0);
		
		-- Destroy some information.
		kuroScript.frame:DestroyTimer("Perma-Kill Mode");
		
		-- Notify each player.
		kuroScript.player.NotifyAll(player:Name().." has cancelled perma-kill mode, you are safe now.");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "pkmode");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set a player's icon.";
COMMAND.text = "<player> <icon|none>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.player.Get( arguments[1] )
	
	-- Check if a statement is true.
	if (target) then
		if (arguments[2] != "none") then
			player:SetCharacterData( "icon", arguments[2] );
			
			-- Notify the player.
			kuroScript.player.NotifyAll(player:Name().." set "..target:Name().."'s icon to '"..arguments[2].."'.");
		else
			player:SetCharacterData("icon", nil);
			
			-- Notify the player.
			kuroScript.player.NotifyAll(player:Name().." removed "..target:Name().."'s icon.");
		end;
	else
		kuroScript.player.Notify(player, arguments[1].." is not a valid player!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "seticon");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set your radio frequency, or a stationary radio's frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local radio;
	
	-- Check if a statement is true.
	if (ValidEntity(trace.Entity) and trace.Entity:GetClass() == "ks_radio") then
		if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
			radio = trace.Entity;
		else
			kuroScript.player.Notify(player, "This stationary radio is too far away!");
			
			-- Return to break the function.
			return;
		end;
	end;
	
	-- Set some information.
	local frequency = arguments[1];
	
	-- Check if a statement is true.
	if ( string.find(frequency, "^%d%d%d%.%d$") ) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		
		-- Convert each string to a number.
		start = tonumber(start);
		finish = tonumber(finish);
		decimal = tonumber(decimal);
		
		-- Check if a statement is true.
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			if (radio) then
				trace.Entity:SetFrequency(frequency);
				
				-- Notify the player.
				kuroScript.player.Notify(player, "You have set this stationary radio's frequency to "..frequency..".");
			else
				player:SetCharacterData("frequency", frequency);
				
				-- Notify the player.
				kuroScript.player.Notify(player, "You have set your radio frequency to "..frequency..".");
			end;
		else
			kuroScript.player.Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		kuroScript.player.Notify(player, "The radio frequency must look like XXX.X!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "frequency");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Send a radio message or speak into a stationary radio.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE | CMD_FALLENOVER;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local radio;
	local text = table.concat(arguments, " ");
	
	-- Check if a statement is true.
	if (ValidEntity(trace.Entity) and trace.Entity:GetClass() == "ks_radio") then
		if (trace.HitPos:Distance( player:GetShootPos() ) <= kuroScript.config.Get("talk_radius"):Get() * 2) then
			radio = trace.Entity;
			
			-- Check if a statement is true.
			if ( radio:IsOff() ) then
				kuroScript.player.Notify(player, "This stationary radio is turned off!");
				
				-- Return to break the function.
				return;
			end;
		else
			kuroScript.player.Notify(player, "This stationary radio is too far away!");
			
			-- Return to break the function.
			return;
		end;
	end;
	
	-- Check if a statement is true.
	if (radio) then
		local frequency = radio:GetSharedVar("ks_Frequency");
		
		-- Check if a statement is true.
		if (frequency and frequency != "") then
			local talkRadius = kuroScript.config.Get("talk_radius"):Get() * 2;
			local listeners = { radio = {}, stationary = {} };
			local k2, v2;
			local k, v;
			
			-- Loop through each value in a table.
			for k, v in pairs( ents.FindByClass("ks_radio") ) do
				if (!v:IsOff() and v:GetSharedVar("ks_Frequency") == frequency) then
					for k2, v2 in ipairs( g_Player.GetAll() ) do
						if ( v2:HasInitialized() and v2:Alive() and !v2:IsRagdolled(RAGDOLL_FALLENOVER) ) then
							if (v2:GetCharacterData("frequency") == frequency and kuroScript.inventory.HasItem(v2, "handheld_radio") and v2:GetSharedVar("ks_Tied") == 0) then
								listeners.radio[v2] = v2;
							elseif (v2:GetPos():Distance( v:GetPos() ) <= talkRadius) then
								listeners.stationary[v2] = v2;
							end;
						end;
					end;
				end;
			end;
			
			-- Add a chat box message.
			local info = kuroScript.chatBox.Add( listeners.radio, player, "radio", text, {freq = frequency} );
			
			-- Check if a statement is true.
			if ( info and ValidEntity(info.speaker) ) then
				kuroScript.chatBox.Add( listeners.stationary, info.speaker, "radio_stationary", info.text, {freq = frequency} );
			end;
		else
			kuroScript.player.Notify(player, "This stationary radio has not had a frequency set!");
		end;
	else
		kuroScript.player.SayRadio(player, text, true);
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "radio");
kuroScript.command.Register(COMMAND, "r");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Purchase a permit.";
COMMAND.text = "<perpetuities|generalgoods|business|custom>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.config.Get("permits"):Get() ) then
		if (player:QueryCharacter("class") == CLASS_CIT) then
			if ( kuroScript.player.HasAccess(player, "x") ) then
				local permits = {};
				local permit = string.lower( arguments[1] );
				local k2, v2;
				local k, v;
				
				-- Loop through each value in a table.
				for k, v in pairs(kuroScript.item.stored) do
					if ( v.cost and v.access and !kuroScript.frame:HasObjectAccess(player, v) ) then
						if ( string.find(v.access, "1") ) then
							permits.perpetuities = (permits.perpetuities or 0) + (v.cost * v.batch);
						elseif ( string.find(v.access, "2") ) then
							permits.generalGoods = (permits.generalGoods or 0) + (v.cost * v.batch);
						else
							for k2, v2 in pairs(kuroScript.game.customPermits) do
								if ( string.find(v.access, v2.flag) ) then
									permits[v2.key] = (permits[v2.key] or 0) + (v.cost * v.batch);
									
									-- Break the loop.
									break;
								end;
							end;
						end;
					end;
				end;
				
				-- Check if a statement is true.
				if (table.Count(permits) > 0) then
					for k, v in pairs(permits) do
						if (string.lower(k) == permit) then
							local cost = v * 2;
							
							-- Check if a statement is true.
							if ( kuroScript.player.CanAfford(player, cost) ) then
								if (permit == "perpetuities") then
									kuroScript.player.GiveCurrency(player, -cost, "Perpetuities Permit");
									kuroScript.player.GiveAccess(player, "1");
								elseif (permit == "generalgoods") then
									kuroScript.player.GiveCurrency(player, -cost, "General Goods Permit");
									kuroScript.player.GiveAccess(player, "2");
								else
									local permitTable = kuroScript.game.customPermits[permit];
									
									-- Check if a statement is true.
									if (permitTable) then
										kuroScript.player.GiveCurrency(player, -cost, permitTable.name.." Permit");
										kuroScript.player.GiveAccess(player, permitTable.flag);
									end;
								end;
								
								-- Set some information.
								timer.Simple(0.25, function()
									if ( ValidEntity(player) ) then
										datastream.StreamToClients( {player}, "ks_RebuildBusiness", true );
									end;
								end);
							else
								local amount = cost - player:QueryCharacter("currency");
								
								-- Notify the player.
								kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
							end;
							
							-- Return to break the function.
							return;
						end;
					end;
					
					-- Check if a statement is true.
					if ( permit == "perpetuities" or permit == "generalgoods" or kuroScript.game.customPermits[permit] ) then
						kuroScript.player.Notify(player, "You already have this permit!");
					else
						kuroScript.player.Notify(player, "This is not a valid permit!");
					end;
				else
					kuroScript.player.Notify(player, "You already have this permit!");
				end;
			elseif (string.lower( arguments[1] ) == "business") then
				local cost = kuroScript.config.Get("business_cost"):Get();
				
				-- Check if a statement is true.
				if ( kuroScript.player.CanAfford(player, cost) ) then
					kuroScript.player.GiveCurrency(player, -cost, "Business");
					kuroScript.player.GiveAccess(player, "x");
					
					-- Set some information.
					timer.Simple(0.25, function()
						if ( ValidEntity(player) ) then
							datastream.StreamToClients( {player}, "ks_RebuildBusiness", true );
						end;
					end);
				else
					local amount = cost - player:QueryCharacter("currency");
					
					-- Notify the player.
					kuroScript.player.Notify(player, "You need another "..FORMAT_CURRENCY(amount, nil, true).."!");
				end;
			else
				kuroScript.player.Notify(player, "This is not a valid permit!");
			end;
		else
			kuroScript.player.Notify(player, "You are not a citizen!");
		end;
	else
		kuroScript.player.Notify(player, "The permit system has not been enabled!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "permit");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Take a character's permit(s) away.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		if ( !kuroScript.game:IsPlayerCombineRank(player, "RCT") ) then
			local target = player:GetEyeTraceNoCursor().Entity;
			local k, v;
			
			-- Check if a statement is true.
			if ( target and target:IsPlayer() ) then
				if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
					if (target:QueryCharacter("class") == CLASS_CIT) then
						for k, v in pairs(kuroScript.game.customPermits) do
							kuroScript.player.TakeAccess(target, v);
						end;
						
						-- Notify the player.
						kuroScript.player.Notify(player, "You have taken this character's permit(s)!");
					else
						kuroScript.player.Notify(player, "This character is not a citizen!");
					end;
				else
					kuroScript.player.Notify(player, "This character is too far away!");
				end;
			else
				kuroScript.player.Notify(player, "You must look at a character!");
			end;
		else
			kuroScript.player.Notify(player, "You are not ranked high enough for this!");
		end;
	else
		kuroScript.player.Notify(player, "You are not the Combine!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "takepermits");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Heal a character.";
COMMAND.text = "<health_vial|health_kit|power_node|bandage>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetSharedVar("ks_Tied") == 0) then
		local itemTable = kuroScript.item.Get( arguments[1] );
		local entity = player:GetEyeTraceNoCursor().Entity;
		local healed;
		
		-- Check if a statement is true.
		local target = kuroScript.entity.GetPlayer(entity);
		
		-- Check if a statement is true.
		if (target) then
			if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if ( !kuroScript.game.scanners[target] ) then
					if (itemTable and arguments[1] == "health_vial") then
						if ( kuroScript.inventory.HasItem(player, "health_vial") ) then
							target:SetHealth( math.Clamp( target:Health() + kuroScript.game:GetHealAmount(player, 1.5), 0, target:GetMaxHealth() ) );
							target:EmitSound("items/medshot4.wav");
							
							-- Update the player's inventory.
							kuroScript.inventory.Update(player, "health_vial", -1, true);
							
							-- Set some information.
							healed = true;
						else
							kuroScript.player.Notify(player, "You do not own a health vial!");
						end;
					elseif (itemTable and arguments[1] == "health_kit") then
						if ( kuroScript.inventory.HasItem(player, "health_kit") ) then
							target:SetHealth( math.Clamp( target:Health() + kuroScript.game:GetHealAmount(player, 2), 0, target:GetMaxHealth() ) );
							target:EmitSound("items/medshot4.wav");
							
							-- Update the player's inventory.
							kuroScript.inventory.Update(player, "health_kit", -1, true);
							
							-- Set some information.
							healed = true;
						else
							kuroScript.player.Notify(player, "You do not own a health kit!");
						end;
					elseif (itemTable and arguments[1] == "bandage") then
						if ( kuroScript.inventory.HasItem(player, "bandage") ) then
							target:SetHealth( math.Clamp( target:Health() + kuroScript.game:GetHealAmount(player), 0, target:GetMaxHealth() ) );
							target:EmitSound("items/medshot4.wav");
							
							-- Update the player's inventory.
							kuroScript.inventory.Update(player, "bandage", -1, true);
							
							-- Set some information.
							healed = true;
						else
							kuroScript.player.Notify(player, "You do not own a bandage!");
						end;
					else
						kuroScript.player.Notify(player, "This is not a valid item!");
					end;
					
					-- Check if a statement is true.
					if (healed) then
						kuroScript.mount.Call("PlayerHealed", target, player, itemTable);
					end;
				elseif (itemTable and arguments[1] == "power_node") then
					if ( kuroScript.inventory.HasItem(player, "power_node") ) then
						target:SetHealth( target:GetMaxHealth() );
						target:EmitSound("npc/scanner/scanner_electric1.wav");
						
						-- Update the player's inventory.
						kuroScript.inventory.Update(player, "power_node", -1, true);
						
						-- Make the player a scanner.
						kuroScript.game:MakePlayerScanner(target, true);
					else
						kuroScript.player.Notify(player, "You do not own a bandage!");
					end;
				else
					kuroScript.player.Notify(player, "This is not a valid item!");
				end;
			else
				kuroScript.player.Notify(player, "This character is too far away!");
			end;
		else
			kuroScript.player.Notify(player, "You must look at a character!");
		end;
	else
		kuroScript.player.Notify(player, "You cannot do that in this state!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "heal");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Search a tied character.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = kuroScript.entity.GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	-- Check if a statement is true.
	if (target) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			if (player:GetSharedVar("ks_Tied") == 0) then
				if (target:GetSharedVar("ks_Tied") != 0) then
					if (player._Searching) then
						kuroScript.player.Notify(player, "You are already searching a character!");
					else
						target._BeingSearched = true; player._Searching = target;
						
						-- Open storage for the player.
						kuroScript.player.OpenStorage( player, {
							name = kuroScript.player.FormatKnownText(player, "%s", target).."'s Inventory",
							weight = kuroScript.inventory.GetMaximumWeight(target),
							entity = target,
							distance = 192,
							currency = target:QueryCharacter("currency"),
							inventory = target:QueryCharacter("inventory"),
							OnClose = function(player, storage, entity)
								player._Searching = nil;
								
								-- Check if a statement is true.
								if ( ValidEntity(entity) ) then
									entity._BeingSearched = nil;
								end;
							end,
							OnTake = function(player, storage, itemTable)
								local target = kuroScript.entity.GetPlayer(storage.entity);
								
								-- Check if a statement is true.
								if (target) then
									if (target:GetCharacterData("clothes") == itemTable.uniqueID) then
										if ( !kuroScript.inventory.HasItem(target, itemTable.uniqueID) ) then
											target:SetCharacterData("clothes", nil); itemTable:OnChangeClothes(target, false);
										end;
									end;
								end;
							end,
							OnGive = function(player, storage, itemTable)
								if (player:GetCharacterData("clothes") == itemTable.uniqueID) then
									if ( !kuroScript.inventory.HasItem(player, itemTable.uniqueID) ) then
										player:SetCharacterData("clothes", nil); itemTable:OnChangeClothes(player, false);
									end;
								end;
							end
						} );
					end;
				else
					kuroScript.player.Notify(player, "This character is not tied!");
				end;
			else
				kuroScript.player.Notify(player, "You cannot do that in this state!");
			end;
		else
			kuroScript.player.Notify(player, "This character is too far away!");
		end;
	else
		kuroScript.player.Notify(player, "You must look at a character!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "search");

-- Set some information.
COMMAND = {};
COMMAND.tip = "A function to add a decal.";
COMMAND.text = "<texture>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local texture = string.lower( arguments[1] );
	local trace = player:GetEyeTraceNoCursor();
	local k, v;
	
	-- Create a decal.
	kuroScript.frame:CreateDecal(texture, trace.HitPos);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "decal");

-- Set some information.
COMMAND = {};
COMMAND.tip = "A function to name an NPC.";
COMMAND.text = "<name> <title>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local target = trace.Entity;
	
	-- Check if a statement is true.
	if ( target and target:IsNPC() ) then
		if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
			target:SetNetworkedString( "ks_Name", arguments[1] );
			target:SetNetworkedString( "ks_Title", arguments[2] );
		else
			kuroScript.player.Notify(player, "This NPC is too far away!");
		end;
	else
		kuroScript.player.Notify(player, "You must look at an NPC!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "namenpc");

-- Set some information.
COMMAND.tip = "Add a ration dispenser.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local entity = ents.Create("ks_rationdispenser");
	
	-- Set some information.
	entity:SetPos(trace.HitPos);
	entity:Spawn();
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		entity:SetAngles( Angle(0, player:EyeAngles().yaw + 180, 0) );
		
		-- Notify the player.
		kuroScript.player.Notify(player, "You have added a ration dispenser.");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "dispenser");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Hide an item from your inventory.";
COMMAND.text = "<item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:GetCharacterData("hiddenitem") ) then
		kuroScript.player.Notify(player, "You are already hiding an item!");
	elseif (player:GetSharedVar("ks_Tied") != 0) then
		kuroScript.player.Notify(player, "You cannot do that in this state!");
	else
		local item = kuroScript.item.Get( arguments[1] );
		
		-- Check if a statement is true.
		if (item) then
			if (item.weight <= 2) then
				if (item.allowStorage != false and item.allowGive != false) then
					if ( kuroScript.inventory.HasItem(player, item.uniqueID) ) then
						player:SetCharacterData("hiddenitem", item.uniqueID);
						
						-- Check if a statement is true.
						if (string.sub(item.name, -1) == "s") then
							kuroScript.player.Notify(player, "You have hidden some "..item.name..".");
						else
							kuroScript.player.Notify(player, "You have hidden a "..item.name..".");
						end;
						
						-- Update the player's inventory.
						kuroScript.inventory.Update(player, item.uniqueID, -1);
					else
						kuroScript.player.Notify(player, "You do not own this item!");
					end;
				else
					kuroScript.player.Notify(player, "This item cannot be hidden!");
				end;
			else
				kuroScript.player.Notify(player, "This item is too heavy to hide!");
			end;
		else
			kuroScript.player.Notify(player, "This is not a valid item!");
		end;
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "hide");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Unhide an item from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:GetCharacterData("hiddenitem") ) then
		local success, fault = kuroScript.inventory.Update(player, player:GetCharacterData("hiddenitem"), 1);
		
		-- Check if a statement is true.
		if (success) then
			kuroScript.player.Notify(player, "You are no longer hiding the item.");
			
			-- Set some information.
			player:SetCharacterData("hiddenitem", nil)
		else
			kuroScript.player.Notify(player, fault);
		end;
	else
		kuroScript.player.Notify(player, "You are not hiding an item!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unhide");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.player.RunKuroScriptCommand(player, "inventory", "zip_tie", "use");
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "ziptie");