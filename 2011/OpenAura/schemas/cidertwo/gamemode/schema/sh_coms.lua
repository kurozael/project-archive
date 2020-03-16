--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

COMMAND = openAura.command:New();
COMMAND.tip = "Search a character if they are tied.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = openAura.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
			if (player:GetSharedVar("tied") == 0) then
				if (target:GetSharedVar("tied") != 0) then
					if (target:GetSharedVar("tied") == 2) then
						local team = player:Team();
						
						if (team != CLASS_POLICE and team != CLASS_DISPENSER and team != CLASS_RESPONSE
						and team != CLASS_SECRETARY and team != CLASS_PRESIDENT) then
							openAura.player:Notify(player, "You cannot search characters tied by a government class!");
							
							return;
						end;
					end;
					
					if (target:GetVelocity():Length() == 0) then
						if (!player.searching) then
							target.beingSearched = true;
							player.searching = target;
							
							openAura.player:OpenStorage( player, {
								name = openAura.player:FormatRecognisedText(player, "%s", target),
								weight = openAura.inventory:GetMaximumWeight(target),
								entity = target,
								distance = 192,
								cash = openAura.player:GetCash(target),
								inventory = openAura.player:GetInventory(target),
								OnClose = function(player, storageTable, entity)
									player.searching = nil;
									
									if ( IsValid(entity) ) then
										entity.beingSearched = nil;
									end;
								end,
								OnTake = function(player, storageTable, itemTable)
									local target = openAura.entity:GetPlayer(storageTable.entity);
									
									if (target) then
										if (target:GetCharacterData("clothes") == itemTable.index) then
											if ( !target:HasItem(itemTable.index) ) then
												target:SetCharacterData("clothes", nil);
												
												itemTable:OnChangeClothes(target, false);
											end;
										elseif ( target:GetSharedVar("skullMask") ) then
											if ( !target:HasItem(itemTable.index) ) then
												itemTable:OnPlayerUnequipped(target);
											end;
										end;
									end;
								end,
								OnGive = function(player, storageTable, itemTable)
									if (player:GetCharacterData("clothes") == itemTable.index) then
										if ( !player:HasItem(itemTable.index) ) then
											player:SetCharacterData("clothes", nil);
											
											itemTable:OnChangeClothes(player, false);
										end;
									elseif ( player:GetSharedVar("skullMask") ) then
										if ( !player:HasItem(itemTable.index) ) then
											itemTable:OnPlayerUnequipped(player);
										end;
									end;
								end,
								CanTake = function(target, storageTable, item)
									local itemTable = openAura.item:Get(item);
									local team = player:Team();
									
									if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
									or team == CLASS_SECRETARY or team == CLASS_PRESIDENT) then
										if ( !itemTable.classes or !table.HasValue(itemTable.classes, CLASS_BLACKMARKET) ) then
											openAura.player:Notify(player, "You can only take illegal items as a government class!");
											
											return false;
										else
											return true;
										end;
									else
										return true;
									end;
								end,
								CanTakeCash = function(target, storageTable, cash)
									local team = player:Team();
									
									if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
									or team == CLASS_SECRETARY or team == CLASS_PRESIDENT) then
										openAura.player:Notify(player, "You can only take illegal items as a government class!");
										
										return false;
									else
										return true;
									end;
								end
							} );
						else
							openAura.player:Notify(player, "You are already searching a character!");
						end;
					else
						openAura.player:Notify(player, "You cannot search a moving character!");
					end;
				else
					openAura.player:Notify(player, "This character is not tied!");
				end;
			else
				openAura.player:Notify(player, "You don't have permission to do this right now!");
			end;
		else
			openAura.player:Notify(player, "This character is too far away!");
		end;
	else
		openAura.player:Notify(player, "You must look at a character!");
	end;
end;

openAura.command:Register(COMMAND, "CharSearch");

COMMAND = openAura.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetSharedVar("tied") == 0) then
		local itemTable = openAura.item:Get( arguments[1] );
		local entity = player:GetEyeTraceNoCursor().Entity;
		local healed = nil;
		local target = openAura.entity:GetPlayer(entity);
		
		if (target) then
			if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
				if (itemTable and arguments[1] == "health_vial") then
					if ( player:HasItem("health_vial") ) then
						target:SetHealth( math.Clamp( target:Health() + openAura.schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth() ) );
						target:EmitSound("items/medshot4.wav");
						
						player:UpdateInventory("health_vial", -1, true);
						
						healed = true;
					else
						openAura.player:Notify(player, "You do not own a health vial!");
					end;
				elseif (itemTable and arguments[1] == "health_kit") then
					if ( player:HasItem("health_kit") ) then
						target:SetHealth( math.Clamp( target:Health() + openAura.schema:GetHealAmount(player, 2), 0, target:GetMaxHealth() ) );
						target:EmitSound("items/medshot4.wav");
						
						player:UpdateInventory("health_kit", -1, true);
						
						healed = true;
					else
						openAura.player:Notify(player, "You do not own a health kit!");
					end;
				elseif (itemTable and arguments[1] == "bandage") then
					if ( player:HasItem("bandage") ) then
						target:SetHealth( math.Clamp( target:Health() + openAura.schema:GetHealAmount(player), 0, target:GetMaxHealth() ) );
						target:EmitSound("items/medshot4.wav");
						
						player:UpdateInventory("bandage", -1, true);
						
						healed = true;
					else
						openAura.player:Notify(player, "You do not own a bandage!");
					end;
				else
					openAura.player:Notify(player, "This is not a valid item!");
				end;
				
				if (healed) then
					openAura.plugin:Call("PlayerHealed", target, player, itemTable);
					
					if (openAura.player:GetAction(target) == "die") then
						openAura.player:SetRagdollState(target, RAGDOLL_NONE);
					end;
					
					player:FakePickup(target);
				end;
			else
				openAura.player:Notify(player, "This character is too far away!");
			end;
		else
			openAura.player:Notify(player, "You must look at a character!");
		end;
	else
		openAura.player:Notify(player, "You don't have permission to do this right now!");
	end;
end;

openAura.command:Register(COMMAND, "CharHeal");

COMMAND = openAura.command:New();
COMMAND.tip = "Demote a character from their position.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local isAdmin = ( player:IsUserGroup("operator") or player:IsAdmin() );
	
	if (player:Team() == CLASS_PRESIDENT or isAdmin) then
		local target = openAura.player:Get( arguments[1] );
		
		if (target) then
			local team = target:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
			or team == CLASS_SECRETARY or isAdmin) then
				local name = _team.GetName(team);
				
				openAura.player:Notify(player, "You have demoted "..target:Name().." from "..name..".");
				openAura.player:Notify(target, player:Name().." has demoted you from "..name..".");
				
				openAura.class:Set(target, CLASS_CIVILIAN, true, true);
			else
				openAura.player:Notify(player, target:Name().." cannot be demoted from this position!");
			end;
		else
			openAura.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		openAura.player:Notify(player, "You are not the president, or an administrator!");
	end;
end;

openAura.command:Register(COMMAND, "CharDemote");

COMMAND = openAura.command:New();
COMMAND.tip = "Blacklist a player from a class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = openAura.player:Get( arguments[1] )
	local class = openAura.class:Get( arguments[2] )
	
	if (target) then
		local blacklist = target:GetData("blacklist");
		
		if (class) then
			if ( table.HasValue(blacklist, class.index) ) then
				openAura.player:Notify(player, target:Name().." is already on the "..class.." blacklist!");
			else
				openAura.player:NotifyAll(player:Name().." has added "..target:Name().." to the "..class.name.." blacklist.");
				
				openAura:StartDataStream( {target}, "SetBlacklisted", {class.index, true} );
				
				table.insert(blacklist, class.index);
			end;
		else
			openAura.player:Notify(player, "This is not a valid class!");
		end;
	else
		openAura.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

openAura.command:Register(COMMAND, "PlyBlacklist");

COMMAND = openAura.command:New();
COMMAND.tip = "Unlacklist a player from a class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = openAura.player:Get( arguments[1] )
	local class = openAura.class:Get( arguments[2] )
	
	if (target) then
		local blacklist = target:GetData("blacklist");
		
		if (class) then
			if ( !table.HasValue(blacklist, class.index) ) then
				openAura.player:Notify(player, target:Name().." is not on the "..class.." blacklist!");
			else
				openAura.player:NotifyAll(player:Name().." has removed "..target:Name().." from the "..class.name.." blacklist.");
				
				openAura:StartDataStream( {target}, "SetBlacklisted", {class.index, false} );
				
				for k, v in ipairs(blacklist) do
					if (v == class.index) then
						table.remove(blacklist, k);
						
						break;
					end;
				end;
			end;
		else
			openAura.player:Notify(player, "This is not a valid class!");
		end;
	else
		openAura.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

openAura.command:Register(COMMAND, "PlyUnblacklist");

COMMAND = openAura.command:New();
COMMAND.tip = "Set your radio frequency, or a stationary radio's frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local radio = nil;
	
	if (IsValid(trace.Entity) and trace.Entity:GetClass() == "aura_radio") then
		if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
			radio = trace.Entity;
		else
			openAura.player:Notify(player, "This stationary radio is too far away!");
			
			return;
		end;
	end;
	
	local frequency = arguments[1];
	
	if ( string.find(frequency, "^%d%d%d%.%d$") ) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		
		start = tonumber(start);
		finish = tonumber(finish);
		decimal = tonumber(decimal);
		
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			if (radio) then
				trace.Entity:SetFrequency(frequency);
				
				openAura.player:Notify(player, "You have set this stationary radio's frequency to "..frequency..".");
			else
				player:SetCharacterData("frequency", frequency);
				
				openAura.player:Notify(player, "You have set your radio frequency to "..frequency..".");
			end;
		else
			openAura.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		openAura.player:Notify(player, "The radio frequency must look like xxx.x!");
	end;
end;

openAura.command:Register(COMMAND, "SetFreq");

COMMAND = openAura.command:New();
COMMAND.tip = "Set your caller ID, or cell phone number.";
COMMAND.text = "<string ID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
	local schemaFolder = openAura:GetSchemaFolder();
	local callerID = tmysql.escape( string.gsub(arguments[1], "%s%p", "") );
	
	if (callerID == "911" or callerID == "912") then
		openAura.player:Notify(player, "You cannot set your cell phone number to this!");
		
		return;
	end;
	
	tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Data LIKE \"%\\\"callerid\\\":\\\""..callerID.."\\\"\"%", function(result)
		if ( IsValid(player) ) then
			if (result and type(result) == "table" and #result > 0) then
				openAura.player:Notify(player, "The cell phone number '"..callerID.."' already exists!");
			else
				player:SetCharacterData("callerid", callerID);
				
				openAura.player:Notify(player, "You set your cell phone number to '"..callerID.."'.");
			end;
		end;
	end, 1);
end;

openAura.command:Register(COMMAND, "SetCallerID");

COMMAND = openAura.command:New();
COMMAND.tip = "Set the name of a broadcaster.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(target) ) then
		if (target:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if (target:GetClass() == "aura_broadcaster") then
				target:SetNetworkedString( "name", arguments[1] );
			else
				openAura.player:Notify(player, "This entity is not a broadcaster!");
			end;
		else
			openAura.player:Notify(player, "This entity is too far away!");
		end;
	else
		openAura.player:Notify(player, "You must look at a valid entity!");
	end;
end;

openAura.command:Register(COMMAND, "SetBroadcasterName");

COMMAND = openAura.command:New();
COMMAND.tip = "Set the active government agenda.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local team = player:Team();
	
	if (team == CLASS_PRESIDENT) then
		openAura:SetSharedVar( "agenda", arguments[1] ); 
	else
		openAura.player:Notify(player, "You are not the president!");
	end;
end;

openAura.command:Register(COMMAND, "SetAgenda");

COMMAND = openAura.command:New();
COMMAND.tip = "Create a new alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	umsg.Start("aura_CreateAlliance", player);
	umsg.End();
end;

openAura.command:Register(COMMAND, "AllyCreate");

COMMAND = openAura.command:New();
COMMAND.tip = "Invite a character to your alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("alliance");
	local target = openAura.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (alliance != "") then
			if ( player:GetCharacterData("leader") ) then
				if (target:GetVelocity():Length() == 0) then
					target.allianceAuthenticate = alliance;
					
					openAura:StartDataStream( {target}, "InviteAlliance", alliance );
					
					openAura.player:Notify(player, "You have invited this character to your alliance.");
					openAura.player:Notify(target, "A character has invited you to their alliance.");
				else
					openAura.player:Notify(target, "You cannot invite a character while they are moving!");
				end;
			else
				openAura.player:Notify(target, "You are not a leader of this alliance!");
			end;
		else
			openAura.player:Notify(target, "You are not in an alliance!");
		end;
	else
		openAura.player:Notify(player, "You must look at a character!");
	end;
end;

openAura.command:Register(COMMAND, "AllyInvite");

COMMAND = openAura.command:New();
COMMAND.tip = "Make a character a leader of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("alliance");
	local target = openAura.player:Get( table.concat(arguments, " ") );
	
	if (alliance != "") then
		if ( player:GetCharacterData("leader") ) then
			if (target) then
				local targetAlliance = target:GetCharacterData("alliance");
				
				if (targetAlliance == alliance) then
					target:SetCharacterData("leader", true);
					
					openAura.player:Notify(player, "You have made "..target:Name().." a leader of the '"..alliance.."' alliance.");
					openAura.player:Notify(target, player:Name().." has made you a leader of the '"..alliance.."' alliance.");
				else
					openAura.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				openAura.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			openAura.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		openAura.player:Notify(target, "You are not in an alliance!");
	end;
end;

openAura.command:Register(COMMAND, "AllyMakeLeader");

COMMAND = openAura.command:New();
COMMAND.tip = "Kick a character out of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("alliance");
	local target = openAura.player:Get( table.concat(arguments, " ") );
	
	if (alliance != "") then
		if ( player:GetCharacterData("leader") ) then
			if (target) then
				local targetAlliance = target:GetCharacterData("alliance");
				
				if (targetAlliance == alliance) then
					target:SetCharacterData("leader", nil);
					target:SetCharacterData("alliance", "");
					
					openAura.player:Notify(player, "You have kicked "..target:Name().." from the '"..alliance.."' alliance.");
					openAura.player:Notify(target, player:Name().." has kicked you from the '"..alliance.."' alliance.");
				else
					openAura.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				openAura.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			openAura.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		openAura.player:Notify(player, "You are not in an alliance!");
	end;
end;

openAura.command:Register(COMMAND, "AllyKick");

COMMAND = openAura.command:New();
COMMAND.tip = "Leave your alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("alliance");
	
	if (alliance != "") then
		player:SetCharacterData("alliance", "");
		
		openAura.player:Notify(player, "You have left the '"..alliance.."' alliance.");
	else
		openAura.player:Notify(target, "You are not in an alliance!");
	end;
end;

openAura.command:Register(COMMAND, "AllyLeave");

COMMAND = openAura.command:New();
COMMAND.tip = "Disguise yourself as another character.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:HasItem("disguise_kit") ) then
		local curTime = CurTime();
		
		if (!player.nextUseDisguise or curTime >= player.nextUseDisguise) then
			local target = openAura.player:Get( arguments[1] );
			
			if (target) then
				if (player != target) then
					local success, fault = player:UpdateInventory("disguise_kit", -1);
					
					if (success) then
						openAura.player:Notify(player, "You are now disguised as "..target:Name().." for two minutes!");
						
						player.nextUseDisguise = curTime + 600;
						player:SetSharedVar("disguise", target);
						player.cancelDisguise = curTime + 120;
					end;
				else
					openAura.player:Notify(player, "You cannot disguise yourself as yourself!");
				end;
			else
				openAura.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			openAura.player:Notify(player, "You cannot use another disguise kit for "..math.Round( math.ceil(player.nextUseDisguise - curTime) ).." second(s)!");
		end;
	else
		openAura.player:Notify(player, "You do not own a disguise kit!");
	end;
end;

openAura.command:Register(COMMAND, "DisguiseSet");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove your character's active disguise.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( IsValid( player:GetSharedVar("disguise") ) ) then
		openAura.player:Notify(player, "You have taken off your disguise, your true identity is revealed!");
		
		player:SetSharedVar("disguise", NULL);
		player.cancelDisguise = nil;
	end;
end;

openAura.command:Register(COMMAND, "DisguiseRemove");

COMMAND = openAura.command:New();
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	openAura.player:RunOpenAuraCommand(player, "InvAction", "zip_tie", "use");
end;

openAura.command:Register(COMMAND, "InvZipTie");

COMMAND = openAura.command:New();
COMMAND.tip = "Send a message out to all police.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("callerid");
	
	if (playerCallerID and playerCallerID != "") then
		local curTime = CurTime();
		
		if (!player.nextSend911 or curTime >= player.nextSend911) then
			local eavesdroppers = {};
			local talkRadius = openAura.config:Get("talk_radius"):Get();
			local listeners = {};
			local position = player:GetShootPos();
			
			for k, v in ipairs( _player.GetAll() ) do
				if (v:Team() == CLASS_POLICE or player == v) then
					listeners[#listeners + 1] = v;
				elseif (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			end;
			
			player.nextSend911 = curTime + 30;
			
			if (#listeners > 0) then
				openAura.player:Notify("The line is busy, or there is nobody to take the call!");
				
				openAura.chatBox:Add( listeners, player, "911", arguments[1], {id = playerCallerID} );
				
				if (#eavesdroppers > 0) then
					openAura.chatBox:Add( eavesdroppers, player, "911_eavesdrop", arguments[1] );
				end;
			end;
		else
			openAura.player:Notify(player, "You can not call 911 for another "..math.Round( math.ceil(player.nextSend911 - curTime) ).." second(s)!");
		end;
	else
		openAura.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

openAura.command:Register(COMMAND, "911");

COMMAND = openAura.command:New();
COMMAND.tip = "Send a message out to all secretaries.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("callerid");
	
	if (playerCallerID and playerCallerID != "") then
		local curTime = CurTime();
		
		if (!player.nextSend912 or curTime >= player.nextSend912) then
			local eavesdroppers = {};
			local talkRadius = openAura.config:Get("talk_radius"):Get();
			local listeners = {};
			local position = player:GetShootPos();
			
			for k, v in ipairs( _player.GetAll() ) do
				if (v:Team() == CLASS_SECRETARY or player == v) then
					listeners[#listeners + 1] = v;
				elseif (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			end;
			
			player.nextSend912 = curTime + 30;
			
			if (#listeners > 0) then
				openAura.player:Notify("The line is busy, or there is nobody to take the call!");
				
				openAura.chatBox:Add( listeners, player, "912", arguments[1], {id = playerCallerID} );
				
				if (#eavesdroppers > 0) then
					openAura.chatBox:Add( eavesdroppers, player, "912_eavesdrop", arguments[1] );
				end;
			end;
		else
			openAura.player:Notify(player, "You can not call 912 for another "..math.Round( math.ceil(player.nextSend912 - curTime) ).." second(s)!");
		end;
	else
		openAura.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

openAura.command:Register(COMMAND, "912");

COMMAND = openAura.command:New();
COMMAND.tip = "Speak to other members of your class using a headset.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local eavesdroppers = {};
	local talkRadius = openAura.config:Get("talk_radius"):Get();
	local listeners = {};
	local position = player:GetShootPos();
	local class = openAura.class:Get( player:Team() );
	
	if (class and class.headsetGroup) then
		for k, v in ipairs( _player.GetAll() ) do
			local targetClass = openAura.class:Get( v:Team() );
			
			if (!targetClass or targetClass.headsetGroup != class.headsetGroup) then
				if (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			else
				listeners[#listeners + 1] = v;
			end;
		end;
		
		if (#eavesdroppers > 0) then
			openAura.chatBox:Add( eavesdroppers, player, "headset_eavesdrop", arguments[1] );
		end;
		
		if (#listeners > 0) then
			openAura.chatBox:Add( listeners, player, "headset", arguments[1] );
		end;
	else
		openAura.player:Notify(player, "Your class does not have a headset!");
	end;
end;

openAura.command:Register(COMMAND, "Headset");

COMMAND = openAura.command:New();
COMMAND.tip = "Send out an advert to all players.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( openAura.player:CanAfford(player, 10) ) then
		openAura.chatBox:Add( nil, player, "advert", arguments[1] );
		openAura.player:GiveCash(player, -10, "making an advert");
	else
		openAura.player:Notify(player, "You need another "..FORMAT_CASH(10 - openAura.player:GetCash(player), nil, true).."!");
	end;
end;

openAura.command:Register(COMMAND, "Advert");

COMMAND = openAura.command:New();
COMMAND.tip = "Broadcast a message as the president.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Team() == CLASS_PRESIDENT) then
		openAura.chatBox:Add( nil, player, "president", arguments[1] );
	else
		openAura.player:Notify(player, "You are not the president!");
	end;
end;

openAura.command:Register(COMMAND, "Broadcast");

COMMAND = openAura.command:New();
COMMAND.tip = "Call another character.";
COMMAND.text = "<string ID> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("callerid");
	
	if (playerCallerID and playerCallerID != "") then
		local eavesdroppers = {};
		local talkRadius = openAura.config:Get("talk_radius"):Get();
		local listeners = {};
		local position = player:GetShootPos();
		local callerID = string.gsub(arguments[1], "%s%p", "");
		local text = table.concat(arguments, " ", 2);
		
		if (playerCallerID != callerID) then
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() and v:Alive() ) then
					if (v:GetCharacterData("callerid") == callerID) then
						listeners[#listeners + 1] = v;
					elseif (v:GetShootPos():Distance(position) <= talkRadius) then
						if (player != v) then
							eavesdroppers[#eavesdroppers + 1] = v;
						end;
					end;
				end;
			end;
			
			if (#listeners > 0) then
				listeners[#listeners + 1] = player;
				
				openAura.chatBox:Add( listeners, player, "call", text, {id = playerCallerID} );
			
				if (#eavesdroppers > 0) then
					openAura.chatBox:Add(eavesdroppers, player, "call_eavesdrop", text);
				end;
			else
				openAura.player:Notify(player, "The number you dialled could not be found!");
			end;
		else
			openAura.player:Notify(player, "You cannot call your own number!");
		end;
	else
		openAura.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

openAura.command:Register(COMMAND, "Call");