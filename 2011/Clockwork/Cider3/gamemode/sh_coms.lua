--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

COMMAND = Clockwork.command:New();
COMMAND.tip = "Search a character if they are tied.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
			if (player:GetSharedVar("IsTied") == 0) then
				if (target:GetSharedVar("IsTied") != 0) then
					if (target:GetSharedVar("IsTied") == 2) then
						local team = player:Team();
						
						if (team != CLASS_POLICE and team != CLASS_DISPENSER and team != CLASS_RESPONSE
						and team != CLASS_SECRETARY and team != CLASS_PRESIDENT) then
							Clockwork.player:Notify(player, "You cannot search characters tied by a government class!");
							
							return;
						end;
					end;
					
					if (target:GetVelocity():Length() == 0) then
						if (!player.cwIsSearchingChar) then
							target.cwIsBeingSearched = true;
							player.cwIsSearchingChar = target;
							
							Clockwork.storage:Open(player, {
								name = Clockwork.player:FormatRecognisedText(player, "%s", target),
								weight = target:GetMaxWeight(),
								entity = target,
								distance = 192,
								cash = target:GetCash(),
								inventory = target:GetInventory(),
								OnClose = function(player, storageTable, entity)
									player.cwIsSearchingChar = nil;
									
									if (IsValid(entity)) then
										entity.cwIsBeingSearched = nil;
									end;
								end,
								OnTakeItem = function(player, storageTable, itemTable)
									local target = Clockwork.entity:GetPlayer(storageTable.entity);
									
									if (target and IsValid(target)) then
										if (target:GetSharedVar("SkullMask") == itemTable("itemID")) then
											itemTable:OnPlayerUnequipped(target);
										end;
									end;
								end,
								OnGiveItem = function(player, storageTable, itemTable)
									if (player:GetSharedVar("SkullMask") == itemTable("itemID")) then
										itemTable:OnPlayerUnequipped(player);
									end;
								end,
								CanTakeItem = function(target, storageTable, itemTable)
									local classTable = itemTable("classes");
									local team = player:Team();
									
									if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
									or team == CLASS_SECRETARY or team == CLASS_PRESIDENT) then
										if (!classTable or !table.HasValue(classTable, CLASS_BLACKMARKET)) then
											Clockwork.player:Notify(player, "You can only take illegal items as a government class!");
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
										Clockwork.player:Notify(player, "You can only take illegal items as a government class!");
										
										return false;
									else
										return true;
									end;
								end
							});
						else
							Clockwork.player:Notify(player, "You are already searching a character!");
						end;
					else
						Clockwork.player:Notify(player, "You cannot search a moving character!");
					end;
				else
					Clockwork.player:Notify(player, "This character is not tied!");
				end;
			else
				Clockwork.player:Notify(player, "You cannot do this action at the moment!");
			end;
		else
			Clockwork.player:Notify(player, "This character is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a character!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharSearch");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetSharedVar("IsTied") == 0) then
		local bIsHealed = false;
		local entity = player:GetEyeTraceNoCursor().Entity;
		local target = Clockwork.entity:GetPlayer(entity);
		
		if (target) then
			if (entity:GetPos():Distance(player:GetShootPos()) <= 192) then
				local itemTable = player:FindItemByID(arguments[1]);
				
				if (!itemTable) then
					Clockwork.player:Notify("You do not own this item!");
					return;
				end;
				
				if (arguments[1] == "health_vial") then
					target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "health_kit") then
					target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 2), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "bandage") then
					target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				else
					Clockwork.player:Notify(player, "This is not a valid item!");
				end;
				
				if (bIsHealed) then
					Clockwork.plugin:Call("PlayerHealed", target, player, itemTable);
					
					if (Clockwork.player:GetAction(target) == "die") then
						Clockwork.player:SetRagdollState(target, RAGDOLL_NONE);
					end;
					
					player:FakePickup(target);
				end;
			else
				Clockwork.player:Notify(player, "This character is too far away!");
			end;
		else
			Clockwork.player:Notify(player, "You must look at a character!");
		end;
	else
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharHeal");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Demote a character from their position.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local isAdmin = (player:IsUserGroup("operator") or player:IsAdmin());
	
	if (player:Team() == CLASS_PRESIDENT or isAdmin) then
		local target = Clockwork.player:FindByID(arguments[1]);
		
		if (target) then
			local team = target:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE
			or team == CLASS_SECRETARY or isAdmin) then
				local name = _team.GetName(team);
				
				Clockwork.player:Notify(player, "You have demoted "..target:Name().." from "..name..".");
				Clockwork.player:Notify(target, player:Name().." has demoted you from "..name..".");
				
				Clockwork.class:Set(target, CLASS_CIVILIAN, true, true);
			else
				Clockwork.player:Notify(player, target:Name().." cannot be demoted from this position!");
			end;
		else
			Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
		end;
	else
		Clockwork.player:Notify(player, "You are not the president, or an administrator!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharDemote");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Blacklist a player from a class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	local class = Clockwork.class:FindByID(arguments[2])
	
	if (target) then
		local blacklisted = target:GetData("Blacklisted");
		
		if (class) then
			if (table.HasValue(blacklisted, class.index)) then
				Clockwork.player:Notify(player, target:Name().." is already on the "..class.." blacklist!");
			else
				Clockwork.player:NotifyAll(player:Name().." has added "..target:Name().." to the "..class.name.." blacklist.");
				Clockwork:StartDataStream({target}, "SetBlacklisted", {class.index, true});
				
				table.insert(blacklisted, class.index);
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid class!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

Clockwork.command:Register(COMMAND, "PlyBlacklist");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Unlacklist a player from a class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	local class = Clockwork.class:FindByID(arguments[2])
	
	if (target) then
		local blacklisted = target:GetData("Blacklisted");
		
		if (class) then
			if (!table.HasValue(blacklisted, class.index)) then
				Clockwork.player:Notify(player, target:Name().." is not on the "..class.." blacklist!");
			else
				Clockwork.player:NotifyAll(player:Name().." has removed "..target:Name().." from the "..class.name.." blacklist.");
				Clockwork:StartDataStream({target}, "SetBlacklisted", {class.index, false});
				
				for k, v in ipairs(blacklisted) do
					if (v == class.index) then
						table.remove(blacklisted, k);
						
						break;
					end;
				end;
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid class!");
		end;
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid player!");
	end;
end;

Clockwork.command:Register(COMMAND, "PlyUnblacklist");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set your radio frequency, or a stationary radio's frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local radioEntity = nil;
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity) and trace.Entity:GetClass() == "cw_radio") then
		if (trace.HitPos:Distance(player:GetShootPos()) > 192) then
			Clockwork.player:Notify(player, "This stationary radio is too far away!");
			return;
		else
			radioEntity = trace.Entity;
		end;
	end;
	
	local frequency = arguments[1];
	
	if (string.find(frequency, "^%d%d%d%.%d$")) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		start = tonumber(start); finish = tonumber(finish); decimal = tonumber(decimal);
		
		if ( !player:HasItemByID("handheld_radio") ) then
			Clockwork.player:Notify(player, "You do not own a radio item!");
			return;
		end;
		
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			if (radioEntity) then
				radioEntity:SetFrequency(frequency);
				Clockwork.player:Notify(player, "You have set this stationary radio's frequency to "..frequency..".");
			else
				player:SetCharacterData("Frequency", frequency);
				Clockwork.player:Notify(player, "You have set your radio frequency to "..frequency..".");
			end;
		else
			Clockwork.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		Clockwork.player:Notify(player, "The radio frequency must look like xxx.x!");
	end;
end;

Clockwork.command:Register(COMMAND, "SetFreq");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set your caller ID, or cell phone number.";
COMMAND.text = "<string ID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local callerID = tmysql.escape(string.gsub(arguments[1], "%s%p", ""));
	
	if (callerID == "911" or callerID == "912") then
		Clockwork.player:Notify(player, "You cannot set your cell phone number to this!");
		
		return;
	end;
	
	tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Data LIKE \"%\\\"CallerID\\\":\\\""..callerID.."\\\"\"%", function(result)
		if (IsValid(player)) then
			if (result and type(result) == "table" and #result > 0) then
				Clockwork.player:Notify(player, "The cell phone number '"..callerID.."' already exists!");
			else
				player:SetCharacterData("CallerID", callerID);
				Clockwork.player:Notify(player, "You set your cell phone number to '"..callerID.."'.");
			end;
		end;
	end, 1);
end;

Clockwork.command:Register(COMMAND, "SetCallerID");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the name of a broadcaster.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (target:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (target:GetClass() == "cw_broadcaster") then
				target:SetNetworkedString("name", arguments[1]);
			else
				Clockwork.player:Notify(player, "This entity is not a broadcaster!");
			end;
		else
			Clockwork.player:Notify(player, "This entity is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

Clockwork.command:Register(COMMAND, "SetBroadcasterName");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the active government agenda.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local team = player:Team();
	
	if (team == CLASS_PRESIDENT) then
		Clockwork:SetSharedVar("Agenda", arguments[1]); 
	else
		Clockwork.player:Notify(player, "You are not the president!");
	end;
end;

Clockwork.command:Register(COMMAND, "SetAgenda");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Create a new alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	umsg.Start("cwCreateAlliance", player);
	umsg.End();
end;

Clockwork.command:Register(COMMAND, "AllyCreate");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Invite a character to your alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("Alliance");
	local target = Clockwork.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (alliance != "") then
			if (player:GetCharacterData("Leader")) then
				if (target:GetVelocity():Length() == 0) then
					target.cwAllianceAuth = alliance;
					
					Clockwork:StartDataStream({target}, "InviteAlliance", alliance);
					
					Clockwork.player:Notify(player, "You have invited this character to your alliance.");
					Clockwork.player:Notify(target, "A character has invited you to their alliance.");
				else
					Clockwork.player:Notify(target, "You cannot invite a character while they are moving!");
				end;
			else
				Clockwork.player:Notify(target, "You are not a leader of this alliance!");
			end;
		else
			Clockwork.player:Notify(target, "You are not in an alliance!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a character!");
	end;
end;

Clockwork.command:Register(COMMAND, "AllyInvite");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Make a character a leader of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("Alliance");
	local target = Clockwork.player:FindByID(table.concat(arguments, " "));
	
	if (alliance != "") then
		if (player:GetCharacterData("Leader")) then
			if (target) then
				local targetAlliance = target:GetCharacterData("Alliance");
				
				if (targetAlliance == alliance) then
					target:SetCharacterData("Leader", true);
					
					Clockwork.player:Notify(player, "You have made "..target:Name().." a leader of the '"..alliance.."' alliance.");
					Clockwork.player:Notify(target, player:Name().." has made you a leader of the '"..alliance.."' alliance.");
				else
					Clockwork.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			Clockwork.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		Clockwork.player:Notify(target, "You are not in an alliance!");
	end;
end;

Clockwork.command:Register(COMMAND, "AllyMakeLeader");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Kick a character out of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("Alliance");
	local target = Clockwork.player:FindByID(table.concat(arguments, " "));
	
	if (alliance != "") then
		if (player:GetCharacterData("Leader")) then
			if (target) then
				local targetAlliance = target:GetCharacterData("Alliance");
				
				if (targetAlliance == alliance) then
					target:SetCharacterData("Leader", nil);
					target:SetCharacterData("Alliance", "");
					
					Clockwork.player:Notify(player, "You have kicked "..target:Name().." from the '"..alliance.."' alliance.");
					Clockwork.player:Notify(target, player:Name().." has kicked you from the '"..alliance.."' alliance.");
				else
					Clockwork.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			Clockwork.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		Clockwork.player:Notify(player, "You are not in an alliance!");
	end;
end;

Clockwork.command:Register(COMMAND, "AllyKick");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Leave your alliance.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("Alliance");
	
	if (alliance != "") then
		player:SetCharacterData("Alliance", "");
		
		Clockwork.player:Notify(player, "You have left the '"..alliance.."' alliance.");
	else
		Clockwork.player:Notify(target, "You are not in an alliance!");
	end;
end;

Clockwork.command:Register(COMMAND, "AllyLeave");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Disguise yourself as another character.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:HasItemByID("disguise_kit")) then
		local curTime = CurTime();
		
		if (!player.cwNextUseDisguise or curTime >= player.cwNextUseDisguise) then
			local target = Clockwork.player:FindByID(arguments[1]);
			
			if (target) then
				if (player != target) then
					local success, fault = player:TakeItem("disguise_kit");
					
					if (success) then
						Clockwork.player:Notify(player, "You are now disguised as "..target:Name().." for two minutes!");
						
						player.cwNextUseDisguise = curTime + 600;
						player:SetSharedVar("Disguise", target);
						player.cwCancelDisguise = curTime + 120;
					end;
				else
					Clockwork.player:Notify(player, "You cannot disguise yourself as yourself!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			Clockwork.player:Notify(player, "You cannot use another disguise kit for "..math.Round(math.ceil(player.cwNextUseDisguise - curTime)).." second(s)!");
		end;
	else
		Clockwork.player:Notify(player, "You do not own a disguise kit!");
	end;
end;

Clockwork.command:Register(COMMAND, "DisguiseSet");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Remove your character's active disguise.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (IsValid(player:GetSharedVar("Disguise"))) then
		Clockwork.player:Notify(player, "You have taken off your disguise, your true identity is revealed!");
		
		player:SetSharedVar("Disguise", NULL);
		player.cwCancelDisguise = nil;
	end;
end;

Clockwork.command:Register(COMMAND, "DisguiseRemove");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
end;

Clockwork.command:Register(COMMAND, "InvZipTie");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Send a message out to all police.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("CallerID");
	
	if (playerCallerID and playerCallerID != "") then
		local curTime = CurTime();
		
		if (!player.cwNextSend911 or curTime >= player.cwNextSend911) then
			local eavesdroppers = {};
			local talkRadius = Clockwork.config:Get("talk_radius"):Get();
			local listeners = {};
			local position = player:GetShootPos();
			
			for k, v in ipairs(_player.GetAll()) do
				if (v:Team() == CLASS_POLICE or player == v) then
					listeners[#listeners + 1] = v;
				elseif (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			end;
			
			player.cwNextSend911 = curTime + 30;
			
			if (#listeners > 0) then
				Clockwork.player:Notify("The line is busy, or there is nobody to take the call!");
				
				Clockwork.chatBox:Add(listeners, player, "911", arguments[1], {id = playerCallerID});
				
				if (#eavesdroppers > 0) then
					Clockwork.chatBox:Add(eavesdroppers, player, "911_eavesdrop", arguments[1]);
				end;
			end;
		else
			Clockwork.player:Notify(player, "You can not call 911 for another "..math.Round(math.ceil(player.cwNextSend911 - curTime)).." second(s)!");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

Clockwork.command:Register(COMMAND, "911");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Send a message out to all secretaries.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("CallerID");
	
	if (playerCallerID and playerCallerID != "") then
		local curTime = CurTime();
		
		if (!player.cwNextSend912 or curTime >= player.cwNextSend912) then
			local eavesdroppers = {};
			local talkRadius = Clockwork.config:Get("talk_radius"):Get();
			local listeners = {};
			local position = player:GetShootPos();
			
			for k, v in ipairs(_player.GetAll()) do
				if (v:Team() == CLASS_SECRETARY or player == v) then
					listeners[#listeners + 1] = v;
				elseif (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			end;
			
			player.cwNextSend912 = curTime + 30;
			
			if (#listeners > 0) then
				Clockwork.player:Notify("The line is busy, or there is nobody to take the call!");
				
				Clockwork.chatBox:Add(listeners, player, "912", arguments[1], {id = playerCallerID});
				
				if (#eavesdroppers > 0) then
					Clockwork.chatBox:Add(eavesdroppers, player, "912_eavesdrop", arguments[1]);
				end;
			end;
		else
			Clockwork.player:Notify(player, "You can not call 912 for another "..math.Round(math.ceil(player.cwNextSend912 - curTime)).." second(s)!");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

Clockwork.command:Register(COMMAND, "912");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Speak to other members of your class using a headset.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local eavesdroppers = {};
	local talkRadius = Clockwork.config:Get("talk_radius"):Get();
	local listeners = {};
	local position = player:GetShootPos();
	local class = Clockwork.class:FindByID(player:Team());
	
	if (class and class.headsetGroup) then
		for k, v in ipairs(_player.GetAll()) do
			local targetClass = Clockwork.class:FindByID(v:Team());
			
			if (!targetClass or targetClass.headsetGroup != class.headsetGroup) then
				if (v:GetShootPos():Distance(position) <= talkRadius) then
					eavesdroppers[#eavesdroppers + 1] = v;
				end;
			else
				listeners[#listeners + 1] = v;
			end;
		end;
		
		if (#eavesdroppers > 0) then
			Clockwork.chatBox:Add(eavesdroppers, player, "headset_eavesdrop", arguments[1]);
		end;
		
		if (#listeners > 0) then
			Clockwork.chatBox:Add(listeners, player, "headset", arguments[1]);
		end;
	else
		Clockwork.player:Notify(player, "Your class does not have a headset!");
	end;
end;

Clockwork.command:Register(COMMAND, "Headset");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Send out an advert to all players.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Clockwork.player:CanAfford(player, 10)) then
		Clockwork.chatBox:Add(nil, player, "advert", arguments[1]);
		Clockwork.player:GiveCash(player, -10, "making an advert");
	else
		Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(10 - player:GetCash(), nil, true).."!");
	end;
end;

Clockwork.command:Register(COMMAND, "Advert");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Broadcast a message as the president.";
COMMAND.text = "<string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Team() == CLASS_PRESIDENT) then
		Clockwork.chatBox:Add(nil, player, "president", arguments[1]);
	else
		Clockwork.player:Notify(player, "You are not the president!");
	end;
end;

Clockwork.command:Register(COMMAND, "Broadcast");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Call another character.";
COMMAND.text = "<string ID> <string Text>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerCallerID = player:GetCharacterData("CallerID");
	
	if (playerCallerID and playerCallerID != "") then
		local eavesdroppers = {};
		local talkRadius = Clockwork.config:Get("talk_radius"):Get();
		local listeners = {};
		local position = player:GetShootPos();
		local callerID = string.gsub(arguments[1], "%s%p", "");
		local text = table.concat(arguments, " ", 2);
		
		if (playerCallerID != callerID) then
			for k, v in ipairs(_player.GetAll()) do
				if (v:HasInitialized() and v:Alive()) then
					if (v:GetCharacterData("CallerID") == callerID) then
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
				
				Clockwork.chatBox:Add(listeners, player, "call", text, {id = playerCallerID});
			
				if (#eavesdroppers > 0) then
					Clockwork.chatBox:Add(eavesdroppers, player, "call_eavesdrop", text);
				end;
			else
				Clockwork.player:Notify(player, "The number you dialled could not be found!");
			end;
		else
			Clockwork.player:Notify(player, "You cannot call your own number!");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a cell phone number!");
	end;
end;

Clockwork.command:Register(COMMAND, "Call");