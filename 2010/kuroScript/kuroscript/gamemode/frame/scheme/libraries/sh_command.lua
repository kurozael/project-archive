--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

kuroScript.command = {};
kuroScript.command.stored = {};
kuroScript.command.hidden = {};

-- Set some information.
CMD_KNOCKEDOUT = 2;
CMD_FALLENOVER = 4;
CMD_DEATHCODE = 8;
CMD_RAGDOLLED = 16;
CMD_VEHICLE = 32;
CMD_DEAD = 64;

-- Set some information.
CMD_DEFAULT = CMD_DEAD | CMD_KNOCKEDOUT;
CMD_HEAVY = CMD_DEAD | CMD_RAGDOLLED;
CMD_ALL = CMD_DEAD | CMD_VEHICLE | CMD_RAGDOLLED;

-- A function to set whether a command is hidden.
function kuroScript.command.SetHidden(name, hidden)
	if ( !hidden and kuroScript.command.hidden[name] ) then
		kuroScript.command.stored[name] = kuroScript.command.hidden[name];
		kuroScript.command.hidden[name] = nil;
	elseif ( hidden and kuroScript.command.stored[name] ) then
		kuroScript.command.hidden[name] = kuroScript.command.stored[name];
		kuroScript.command.stored[name] = nil;
	end;
	
	-- Check if a statement is true.
	if (SERVER) then
		umsg.Start("ks_HideCommand");
			umsg.Long( kuroScript.frame:GetShortCRC(name) );
			umsg.Bool(hidden);
		umsg.End();
	elseif ( hidden and kuroScript.command.hidden[name] ) then
		kuroScript.command.RemoveHelp( kuroScript.command.hidden[name] );
	elseif ( !hidden and kuroScript.command.stored[name] ) then
		kuroScript.command.AddHelp( kuroScript.command.stored[name] );
	end;
end;

-- A function to register a new command.
function kuroScript.command.Register(data, name)
	if ( !kuroScript.command.stored[name] ) then
		name = string.lower( string.gsub(name, "%s", "") );
		
		-- Check if a statement is true.
		if (!data.category) then
			if ( data.access and string.find(data.access, "s") ) then
				data.category = "Super Admin Commands";
			elseif ( data.access and string.find(data.access, "a") ) then
				data.category = "Admin Commands";
			elseif ( data.access and string.find(data.access, "o") ) then
				data.category = "Operator Commands";
			else
				data.category = "Basic Commands";
			end;
		end;
		
		-- Set some information.
		kuroScript.command.stored[name] = data;
		kuroScript.command.stored[name].name = name;
		kuroScript.command.stored[name].text = data.text or "<none>";
		kuroScript.command.stored[name].flags = data.flags or 0;
		kuroScript.command.stored[name].access = data.access or "b";
		kuroScript.command.stored[name].arguments = data.arguments or 0;
		
		-- Check if a statement is true.
		if (CLIENT) then
			kuroScript.command.AddHelp( kuroScript.command.stored[name] );
		end;
	end;
	
	-- Return the command.
	return kuroScript.command.stored[name];
end;

-- A function to get a command.
function kuroScript.command.Get(name)
	return kuroScript.command.stored[name];
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.command.ConsoleCommand(player, command, arguments)
		if ( player:HasInitialized() ) then
			if ( arguments and arguments[1] ) then
				command = arguments[1];
				
				-- Set some information.
				local commandTable = kuroScript.command.stored[command];
				
				-- Check if a statement is true.
				if (commandTable) then
					table.remove(arguments, 1);
					
					-- Loop through each value in a table.
					for k, v in pairs(arguments) do
						arguments[k] = string.Replace(arguments[k], " ' ", "'");
						arguments[k] = string.Replace(arguments[k], " : ", ":");
					end;
					
					-- Check if a statement is true.
					if ( hook.Call("PlayerCanUseCommand", kuroScript.frame, player, command, arguments) ) then
						if (#arguments >= commandTable.arguments) then
							if ( kuroScript.player.HasAccess(player, commandTable.access) ) then
								local flags = commandTable.flags;
								
								-- Check if a statement is true.
								if ( kuroScript.player.GetDeathCode(player, true) ) then
									if (flags & CMD_DEATHCODE == 0) then
										kuroScript.player.TakeDeathCode(player);
									end;
								end;
								
								-- Check if a statement is true.
								if ( (flags & CMD_DEAD > 0) and !player:Alive() ) then
									if (!player._DeathCodeAuthenticated) then
										kuroScript.player.Notify(player, "You cannot do that while dead!");
									end; return;
								elseif ( (flags & CMD_VEHICLE > 0) and player:InVehicle() ) then
									if (!player._DeathCodeAuthenticated) then
										kuroScript.player.Notify(player, "You cannot do that while in a vehicle!");
									end; return;
								elseif (flags & CMD_RAGDOLLED > 0 and player:IsRagdolled() ) then
									if (!player._DeathCodeAuthenticated) then
										kuroScript.player.Notify(player, "You cannot do that while ragdolled!");
									end; return;
								elseif (flags & CMD_FALLENOVER > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
									if (!player._DeathCodeAuthenticated) then
										kuroScript.player.Notify(player, "You cannot do that while fallen over!");
									end; return;
								elseif (flags & CMD_KNOCKEDOUT > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
									if (!player._DeathCodeAuthenticated) then
										kuroScript.player.Notify(player, "You cannot do that while knocked out!");
									end; return;
								end;
								
								-- Check if a statement is true.
								if (table.concat(arguments, " ") != "") then
									kuroScript.frame:PrintDebug(player:Name().." used the command '"..command.." "..table.concat(arguments, " ").."'.");
								else
									kuroScript.frame:PrintDebug(player:Name().." used the command '"..command.."'.");
								end;
								
								-- Check if a statement is true.
								if (commandTable.OnRun) then
									local success, value = pcall(commandTable.OnRun, commandTable, player, arguments);
									
									-- Check if a statement is true.
									if (!success) then
										ErrorNoHalt("kuroScript - "..command.." | "..value..".\n");
									elseif ( kuroScript.player.GetDeathCode(player, true) ) then
										kuroScript.player.UseDeathCode(player, command, arguments);
									end;
									
									-- Check if a statement is true.
									if (success) then
										return value;
									end;
								end;
							else
								kuroScript.player.Notify(player, "You do not have access to this command, "..player:Name()..".");
							end;
						else
							kuroScript.player.Notify(player, "Syntax - "..command.." "..commandTable.text.."!");
						end;
					end;
				elseif ( !kuroScript.player.GetDeathCode(player, true) ) then
					kuroScript.player.Notify(player, "This is not a valid command!");
				end;
			elseif ( !kuroScript.player.GetDeathCode(player, true) ) then
				kuroScript.player.Notify(player, "This is not a valid command!");
			end;
			
			-- Check if a statement is true.
			if ( kuroScript.player.GetDeathCode(player) ) then
				kuroScript.player.TakeDeathCode(player);
			end;
		else
			kuroScript.player.Notify(player, "You haven't initialized yet!");
		end;
	end;

	-- Add a console command.
	concommand.Add("ks", kuroScript.command.ConsoleCommand);

	-- Add a hook.
	hook.Add("PlayerInitialSpawn", "kuroScript.command.PlayerInitialSpawn", function(player)
		local hiddenCommands = {};
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.command.hidden) do
			hiddenCommands[#hiddenCommands + 1] = kuroScript.frame:GetShortCRC(k);
		end;
		
		-- Start a data stream.
		datastream.StreamToClients( {player}, "ks_HiddenCommands", hiddenCommands );
	end);
else
	function kuroScript.command.AddHelp(commandTable)
		kuroScript.directory.AddCategory(commandTable.category, "Commands");
		
		-- Set some information.
		commandTable.uniqueIDs = kuroScript.directory.AddInformation(commandTable.category, "$command_prefix$"..commandTable.name.." "..commandTable.text, commandTable.tip);
	end;

	-- A function to remove a command's help.
	function kuroScript.command.RemoveHelp(commandTable)
		if (commandTable.uniqueIDs) then
			kuroScript.directory.Remove(commandTable.category, commandTable.uniqueIDs);
		end;
	end;
end;