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
			if ( !player:GetSharedVar("tied") ) then
				if ( target:GetSharedVar("tied") ) then
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
	if ( !player:GetSharedVar("tied") ) then
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
						openAura.trophies:Progress(player, TRO_PARAMEDIC);
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
COMMAND.tip = "Set your radio frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local frequency = arguments[1];
	
	if ( string.find(frequency, "^%d%d%d%.%d$") ) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		
		start = tonumber(start);
		finish = tonumber(finish);
		decimal = tonumber(decimal);
		
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			player:SetCharacterData("frequency", frequency);
			
			openAura.player:Notify(player, "You have set your radio frequency to "..frequency..".");
		else
			openAura.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		openAura.player:Notify(player, "The radio frequency must look like xxx.x!");
	end;
end;

openAura.command:Register(COMMAND, "SetFreq");

COMMAND = openAura.command:New();
COMMAND.tip = "Create a new guild.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	umsg.Start("aura_CreateGuild", player);
	umsg.End();
end;

openAura.command:Register(COMMAND, "GuildCreate");

COMMAND = openAura.command:New();
COMMAND.tip = "Invite a character to your guild.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local guild = player:GetGuild();
	local target = openAura.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (guild) then
			if ( player:IsLeader() ) then
				if (target:GetVelocity():Length() == 0) then
					target.guildAuthenticate = guild;
					target.guildInviter = player;
					
					openAura:StartDataStream( {target}, "InviteGuild", guild );
					
					openAura.player:Notify(player, "You have invited this character to your guild.");
					openAura.player:Notify(target, "A character has invited you to their guild.");
				else
					openAura.player:Notify(target, "You cannot invite a character while they are moving!");
				end;
			else
				openAura.player:Notify(target, "You are not a leader of this guild!");
			end;
		else
			openAura.player:Notify(target, "You are not in an guild!");
		end;
	else
		openAura.player:Notify(player, "You must look at a character!");
	end;
end;

openAura.command:Register(COMMAND, "GuildInvite");

COMMAND = openAura.command:New();
COMMAND.tip = "Make a character a leader of your guild.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local guild = player:GetGuild();
	local target = openAura.player:Get( table.concat(arguments, " ") );
	
	if (guild) then
		if ( player:IsLeader() ) then
			if (target) then
				local targetGuild = target:GetGuild();
				
				if (targetGuild == guild) then
					player:SetRank(RANK_MAJ);
					
					openAura.player:Notify(player, "You have made "..target:Name().." a leader of the '"..guild.."' guild.");
					openAura.player:Notify(target, player:Name().." has made you a leader of the '"..guild.."' guild.");
				else
					openAura.player:Notify(player, target:Name().." is not in your guild!");
				end;
			else
				openAura.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			openAura.player:Notify(player, "You are not a leader of this guild!");
		end;
	else
		openAura.player:Notify(target, "You are not in an guild!");
	end;
end;

openAura.command:Register(COMMAND, "GuildMakeLeader");

COMMAND = openAura.command:New();
COMMAND.tip = "Kick a character out of your guild.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local guild = player:GetGuild();
	local target = openAura.player:Get( table.concat(arguments, " ") );
	
	if (guild) then
		if ( player:IsLeader() ) then
			if (target) then
				local targetGuild = target:GetGuild();
				
				if (targetGuild == guild) then
					if ( !target:IsLeader() ) then
						target:SetRank(RANK_RCT);
						target:SetGuild("");
						
						openAura.player:Notify(player, "You have kicked "..target:Name().." from the '"..guild.."' guild.");
						openAura.player:Notify(target, player:Name().." has kicked you from the '"..guild.."' guild.");
					else
						openAura.player:Notify(player, "You cannot kick another leader out of the guild!");
					end;
				else
					openAura.player:Notify(player, target:Name().." is not in your guild!");
				end;
			else
				openAura.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			openAura.player:Notify(player, "You are not a leader of this guild!");
		end;
	else
		openAura.player:Notify(player, "You are not in an guild!");
	end;
end;

openAura.command:Register(COMMAND, "GuildKick");

COMMAND = openAura.command:New();
COMMAND.tip = "Leave your guild.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local guild = player:GetGuild();
	
	if (guild) then
		player:SetGuild("");
		player:SetRank(RANK_RCT);
		
		openAura.player:Notify(player, "You have left the '"..guild.."' guild.");
	else
		openAura.player:Notify(target, "You are not in an guild!");
	end;
end;

openAura.command:Register(COMMAND, "GuildLeave");

COMMAND = openAura.command:New();
COMMAND.tip = "Untie the character that you're looking at.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local untieTime = openAura.schema:GetDexterityTime(player);
	local eyeTrace = player:GetEyeTraceNoCursor();
	local target = eyeTrace.Entity;
	local entity = target;
	
	if ( openAura.augments:Has(player, AUG_HURRYMAN) ) then
		untieTime = untieTime * 0.5;
	end;
	
	if ( IsValid(target) ) then
		target = openAura.entity:GetPlayer(target);
		
		if ( target and !player:GetSharedVar("tied") ) then
			if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
				if ( target:GetSharedVar("tied") and target:Alive() ) then
					openAura.player:SetAction(player, "untie", untieTime);
					
					target:SetSharedVar("beingUntied", true);
					
					openAura.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
						return player:Alive() and target:Alive() and !player:IsRagdolled() and !player:GetSharedVar("tied");
					end, function(success)
						if (success) then
							openAura.schema:TiePlayer(target, false);
							
							player:ProgressAttribute(ATB_DEXTERITY, 15, true);
						end;
						
						if ( IsValid(target) ) then
							target:SetSharedVar("beingUntied", false);
						end;
						
						openAura.player:SetAction(player, "untie", false);
					end);
				else
					openAura.player:Notify(player, "This character is either not tied, or not alive!");
				end;
			else
				openAura.player:Notify(player, "This character is too far away!");
			end;
		else
			openAura.player:Notify(player, "You don't have permission to do this right now!");
		end;
	else
		openAura.player:Notify(player, "You must look at a character!");
	end;
end;

openAura.command:Register(COMMAND, "PlyUntie");

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
COMMAND.tip = "Add a bounty to a character.";
COMMAND.text = "<string Name> <number Bounty>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = openAura.player:Get( arguments[1] );
	local bounty = tonumber( arguments[2] );
	
	if (!bounty) then
		openAura.player:Notify(player, "This is not a valid bounty!");
		
		return;
	end;
	
	if (target) then
		local minimumBounty = 100;
		
		if ( target:IsGood() ) then
			minimumBounty = 200;
		end;
		
		if (bounty < minimumBounty) then
			if ( target:IsGood() ) then
				openAura.player:Notify(player, target:Name().." is good, and has a minimum bounty of "..FORMAT_CASH(minimumBounty, nil, true).."!");
			else
				openAura.player:Notify(player, target:Name().." is bad, and has a minimum bounty of "..FORMAT_CASH(minimumBounty, nil, true).."!");
			end;
			
			return;
		end;
		
		if ( openAura.player:CanAfford(player, bounty) ) then
			openAura.player:Notify(player, "You have placed a bounty of "..FORMAT_CASH(bounty, nil, true).." on "..target:Name()..".");
			openAura.player:GiveCash(player, -bounty, "placing a bounty");
			
			target:AddBounty(bounty);
			
			openAura.chatBox:Add( nil, target, "bounty", tostring( target:GetBounty() ) );
		else
			openAura.player:Notify(player, "You need another "..FORMAT_CASH(bounty - openAura.player:GetCash(player), nil, true).."!");
		end;
	end;
end;

openAura.command:Register(COMMAND, "Bounty");