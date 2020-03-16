--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

nexus.command = {};
nexus.command.stored = {};
nexus.command.hidden = {};

CMD_KNOCKEDOUT = 2;
CMD_FALLENOVER = 4;
CMD_DEATHCODE = 8;
CMD_RAGDOLLED = 16;
CMD_VEHICLE = 32;
CMD_DEAD = 64;

CMD_DEFAULT = CMD_DEAD | CMD_KNOCKEDOUT;
CMD_HEAVY = CMD_DEAD | CMD_RAGDOLLED;
CMD_ALL = CMD_DEAD | CMD_VEHICLE | CMD_RAGDOLLED;

-- A function to set whether a command is hidden.
function nexus.command.SetHidden(name, hidden)
	local uniqueID = string.lower( string.gsub(name, "%s", "") );
	
	if ( !hidden and nexus.command.hidden[uniqueID] ) then
		nexus.command.stored[uniqueID] = nexus.command.hidden[uniqueID];
		nexus.command.hidden[uniqueID] = nil;
	elseif ( hidden and nexus.command.stored[uniqueID] ) then
		nexus.command.hidden[uniqueID] = nexus.command.stored[uniqueID];
		nexus.command.stored[uniqueID] = nil;
	end;
	
	if (SERVER) then
		umsg.Start("nx_HideCommand");
			umsg.Long( NEXUS:GetShortCRC(uniqueID) );
			umsg.Bool(hidden);
		umsg.End();
	elseif ( hidden and nexus.command.hidden[uniqueID] ) then
		nexus.command.RemoveHelp( nexus.command.hidden[uniqueID] );
	elseif ( !hidden and nexus.command.stored[uniqueID] ) then
		nexus.command.AddHelp( nexus.command.stored[uniqueID] );
	end;
end;

-- A function to register a new command.
function nexus.command.Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);
	
	if ( !nexus.command.stored[uniqueID] ) then
		nexus.command.stored[uniqueID] = data;
		nexus.command.stored[uniqueID].name = realName;
		nexus.command.stored[uniqueID].text = data.text or "<none>";
		nexus.command.stored[uniqueID].flags = data.flags or 0;
		nexus.command.stored[uniqueID].access = data.access or "b";
		nexus.command.stored[uniqueID].arguments = data.arguments or 0;
		
		if (CLIENT) then
			nexus.command.AddHelp( nexus.command.stored[uniqueID] );
		end;
	end;
	
	return nexus.command.stored[uniqueID];
end;

-- A function to get a command.
function nexus.command.Get(name)
	return nexus.command.stored[ string.lower( string.gsub(name, "%s", "") ) ];
end;

if (SERVER) then
	function nexus.command.ConsoleCommand(player, command, arguments)
		if ( player:HasInitialized() ) then
			if ( arguments and arguments[1] ) then
				local realCommand = string.lower( arguments[1] );
				local commandTable = nexus.command.stored[realCommand];
				local commandPrefix = nexus.config.Get("command_prefix"):Get();
				
				if (commandTable) then
					table.remove(arguments, 1);
					
					for k, v in pairs(arguments) do
						arguments[k] = string.Replace(arguments[k], " ' ", "'");
						arguments[k] = string.Replace(arguments[k], " : ", ":");
					end;
					
					if ( nexus.mount.Call("PlayerCanUseCommand", player, commandTable, arguments) ) then
						if (#arguments >= commandTable.arguments) then
							if ( nexus.player.HasFlags(player, commandTable.access) ) then
								local flags = commandTable.flags;
								
								if ( nexus.player.GetDeathCode(player, true) ) then
									if (flags & CMD_DEATHCODE == 0) then
										nexus.player.TakeDeathCode(player);
									end;
								end;
								
								if ( (flags & CMD_DEAD > 0) and !player:Alive() ) then
									if (!player.deathCodeAuthenticated) then
										nexus.player.Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif ( (flags & CMD_VEHICLE > 0) and player:InVehicle() ) then
									if (!player.deathCodeAuthenticated) then
										nexus.player.Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_RAGDOLLED > 0 and player:IsRagdolled() ) then
									if (!player.deathCodeAuthenticated) then
										nexus.player.Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_FALLENOVER > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
									if (!player.deathCodeAuthenticated) then
										nexus.player.Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_KNOCKEDOUT > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
									if (!player.deathCodeAuthenticated) then
										nexus.player.Notify(player, "You don't have permission to do this right now!");
									end; return;
								end;
								
								if (commandTable.name != "CharGiveItem") then
									if (table.concat(arguments, " ") != "") then
										NEXUS:PrintDebug(player:Name().." has used '"..commandPrefix..commandTable.name.." "..table.concat(arguments, " ").."'.");
									else
										NEXUS:PrintDebug(player:Name().." has used '"..commandPrefix..commandTable.name.."'.");
									end;
								end;
								
								if (commandTable.OnRun) then
									local success, value = pcall(commandTable.OnRun, commandTable, player, arguments);
									
									if (!success) then
										ErrorNoHalt("nexus - "..commandTable.name.." | "..value..".\n");
									elseif ( nexus.player.GetDeathCode(player, true) ) then
										nexus.player.UseDeathCode(player, commandTable.name, arguments);
									end;
									
									if (success) then
										return value;
									end;
								end;
							else
								nexus.player.Notify(player, "You do not have access to this command, "..player:Name()..".");
							end;
						else
							nexus.player.Notify(player, commandTable.name.." "..commandTable.text.."!");
						end;
					end;
				elseif ( !nexus.player.GetDeathCode(player, true) ) then
					nexus.player.Notify(player, "This is not a valid command!");
				end;
			elseif ( !nexus.player.GetDeathCode(player, true) ) then
				nexus.player.Notify(player, "This is not a valid command!");
			end;
			
			if ( nexus.player.GetDeathCode(player) ) then
				nexus.player.TakeDeathCode(player);
			end;
		else
			nexus.player.Notify(player, "You cannot use commands yet!");
		end;
	end;

	concommand.Add("nx", nexus.command.ConsoleCommand);

	hook.Add("PlayerInitialSpawn", "nexus.command.PlayerInitialSpawn", function(player)
		local hiddenCommands = {};
		
		for k, v in pairs(nexus.command.hidden) do
			hiddenCommands[#hiddenCommands + 1] = NEXUS:GetShortCRC(k);
		end;
		
		NEXUS:StartDataStream(player, "HiddenCommands", hiddenCommands);
	end);
else
	function nexus.command.AddHelp(commandTable)
		local text = string.gsub(string.gsub(commandTable.text, ">", "&gt;"), "<", "&lt;");
		
		if (!commandTable.helpID) then
			commandTable.helpID = nexus.directory.AddCode("Commands", [[
				<b>
					<font size="3">
						$command_prefix$]]..commandTable.name..[[ <font size="2"><i>]]..text..[[</i></font>
					</font>
				</b>
				<br>
				<font size="1">
					<i>]]..commandTable.tip..[[</i>
				</font>
			]], nil, commandTable.name);
		end;
	end;

	-- A function to remove a command's help.
	function nexus.command.RemoveHelp(commandTable)
		if (commandTable.helpID) then
			nexus.directory.RemoveCode("Commands", commandTable.helpID);
			commandTable.helpID = nil;
		end;
	end;
end;