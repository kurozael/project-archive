--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.command = {};
CloudScript.command.stored = {};
CloudScript.command.hidden = {};

CMD_KNOCKEDOUT = 2;
CMD_FALLENOVER = 4;
CMD_DEATHCODE = 8;
CMD_RAGDOLLED = 16;
CMD_VEHICLE = 32;
CMD_DEAD = 64;

CMD_DEFAULT = CMD_DEAD | CMD_KNOCKEDOUT;
CMD_HEAVY = CMD_DEAD | CMD_RAGDOLLED;
CMD_ALL = CMD_DEAD | CMD_VEHICLE | CMD_RAGDOLLED;

-- A function to get a new command.
function CloudScript.command:New()
	return {};
end;

-- A function to set whether a command is hidden.
function CloudScript.command:SetHidden(name, hidden)
	local uniqueID = string.lower( string.gsub(name, "%s", "") );
	
	if ( !hidden and self.hidden[uniqueID] ) then
		self.stored[uniqueID] = self.hidden[uniqueID];
		self.hidden[uniqueID] = nil;
	elseif ( hidden and self.stored[uniqueID] ) then
		self.hidden[uniqueID] = self.stored[uniqueID];
		self.stored[uniqueID] = nil;
	end;
	
	if (SERVER) then
		umsg.Start("cloud_HideCommand");
			umsg.Long( CloudScript:GetShortCRC(uniqueID) );
			umsg.Bool(hidden);
		umsg.End();
	elseif ( hidden and self.hidden[uniqueID] ) then
		self:RemoveHelp( self.hidden[uniqueID] );
	elseif ( !hidden and self.stored[uniqueID] ) then
		self:AddHelp( self.stored[uniqueID] );
	end;
end;

-- A function to register a new command.
function CloudScript.command:Register(data, name)
	local realName = string.gsub(name, "%s", "");
	local uniqueID = string.lower(realName);
	
	if ( !self.stored[uniqueID] ) then
		self.stored[uniqueID] = data;
		self.stored[uniqueID].name = realName;
		self.stored[uniqueID].text = data.text or "<none>";
		self.stored[uniqueID].flags = data.flags or 0;
		self.stored[uniqueID].access = data.access or "b";
		self.stored[uniqueID].arguments = data.arguments or 0;
		
		if (CLIENT) then
			self:AddHelp( self.stored[uniqueID] );
		end;
	end;
	
	return self.stored[uniqueID];
end;

-- A function to get a command.
function CloudScript.command:Get(name)
	return self.stored[ string.lower( string.gsub(name, "%s", "") ) ];
end;

if (SERVER) then
	function CloudScript.command:ConsoleCommand(player, command, arguments)
		if ( player:HasInitialized() ) then
			if ( arguments and arguments[1] ) then
				local realCommand = string.lower( arguments[1] );
				local commandTable = self.stored[realCommand];
				local commandPrefix = CloudScript.config:Get("command_prefix"):Get();
				
				if (commandTable) then
					table.remove(arguments, 1);
					
					for k, v in pairs(arguments) do
						arguments[k] = CloudScript:Replace(arguments[k], " ' ", "'");
						arguments[k] = CloudScript:Replace(arguments[k], " : ", ":");
					end;
					
					if ( CloudScript.plugin:Call("PlayerCanUseCommand", player, commandTable, arguments) ) then
						if (#arguments >= commandTable.arguments) then
							if ( CloudScript.player:HasFlags(player, commandTable.access) ) then
								local flags = commandTable.flags;
								
								if ( CloudScript.player:GetDeathCode(player, true) ) then
									if (flags & CMD_DEATHCODE == 0) then
										CloudScript.player:TakeDeathCode(player);
									end;
								end;
								
								if ( (flags & CMD_DEAD > 0) and !player:Alive() ) then
									if (!player.deathCodeAuthenticated) then
										CloudScript.player:Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif ( (flags & CMD_VEHICLE > 0) and player:InVehicle() ) then
									if (!player.deathCodeAuthenticated) then
										CloudScript.player:Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_RAGDOLLED > 0 and player:IsRagdolled() ) then
									if (!player.deathCodeAuthenticated) then
										CloudScript.player:Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_FALLENOVER > 0 and player:GetRagdollState() == RAGDOLL_FALLENOVER) then
									if (!player.deathCodeAuthenticated) then
										CloudScript.player:Notify(player, "You don't have permission to do this right now!");
									end; return;
								elseif (flags & CMD_KNOCKEDOUT > 0 and player:GetRagdollState() == RAGDOLL_KNOCKEDOUT) then
									if (!player.deathCodeAuthenticated) then
										CloudScript.player:Notify(player, "You don't have permission to do this right now!");
									end; return;
								end;
								
								if (commandTable.name != "CharGiveItem") then
									if (table.concat(arguments, " ") != "") then
										CloudScript:PrintLog(LOGTYPE_GENERIC, player:Name().." has used '"..commandPrefix..commandTable.name.." "..table.concat(arguments, " ").."'.");
									else
										CloudScript:PrintLog(LOGTYPE_GENERIC, player:Name().." has used '"..commandPrefix..commandTable.name.."'.");
									end;
								end;
								
								if (commandTable.OnRun) then
									local success, value = pcall(commandTable.OnRun, commandTable, player, arguments);
									
									if (!success) then
										ErrorNoHalt("CloudScript -> the "..commandTable.name.." command has failed to run.");
										ErrorNoHalt(value);
									elseif ( CloudScript.player:GetDeathCode(player, true) ) then
										CloudScript.player:UseDeathCode(player, commandTable.name, arguments);
									end;
									
									if (success) then
										return value;
									end;
								end;
							else
								CloudScript.player:Notify(player, "You do not have access to this command, "..player:Name()..".");
							end;
						else
							CloudScript.player:Notify(player, commandTable.name.." "..commandTable.text.."!");
						end;
					end;
				elseif ( !CloudScript.player:GetDeathCode(player, true) ) then
					CloudScript.player:Notify(player, "This is not a valid command!");
				end;
			elseif ( !CloudScript.player:GetDeathCode(player, true) ) then
				CloudScript.player:Notify(player, "This is not a valid command!");
			end;
			
			if ( CloudScript.player:GetDeathCode(player) ) then
				CloudScript.player:TakeDeathCode(player);
			end;
		else
			CloudScript.player:Notify(player, "You cannot use commands yet!");
		end;
	end;

	concommand.Add("cloud", function(player, command, arguments)
		CloudScript.command:ConsoleCommand(player, command, arguments);
	end);

	hook.Add("PlayerInitialSpawn", "CloudScript.command:PlayerInitialSpawn", function(player)
		local hiddenCommands = {};
		
		for k, v in pairs(CloudScript.command.hidden) do
			hiddenCommands[#hiddenCommands + 1] = CloudScript:GetShortCRC(k);
		end;
		
		CloudScript:StartDataStream(player, "HiddenCommands", hiddenCommands);
	end);
else
	function CloudScript.command:AddHelp(commandTable)
		local text = string.gsub(string.gsub(commandTable.text, ">", "&gt;"), "<", "&lt;");
		
		if (!commandTable.helpID) then
			commandTable.helpID = CloudScript.directory:AddCode("Commands", [[
				<div class="cloudInfoTitle">
					$command_prefix$]]..string.upper(commandTable.name)..[[
				</div>
				<div class="cloudInfoText">
					<div class="cloudInfoTip">
						<i>]]..text..[[</i>
					</div>
					]]..commandTable.tip..[[
				</div>
			]], true, commandTable.name);
		end;
	end;

	-- A function to remove a command's help.
	function CloudScript.command:RemoveHelp(commandTable)
		if (commandTable.helpID) then
			CloudScript.directory:RemoveCode("Commands", commandTable.helpID);
			commandTable.helpID = nil;
		end;
	end;
end;