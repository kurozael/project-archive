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
	
	if (!target) then
		Clockwork.player:Notify(player, "You must look at a character!");
		return;
	end;
	
	if (target:GetShootPos():Distance(player:GetShootPos()) > 192) then
		Clockwork.player:Notify(player, "This character is too far away!");
		return;
	end;
	
	if (!player:GetSharedVar("IsTied")) then
		if (target:GetSharedVar("IsTied")) then
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
end;

Clockwork.command:Register(COMMAND, "CharSearch");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (!player:GetSharedVar("IsTied")) then
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
					target:SetHealth(math.Clamp(target:Health() + Clockwork.schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "health_kit") then
					target:SetHealth(math.Clamp(target:Health() + Clockwork.schema:GetHealAmount(player, 2), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "bandage") then
					target:SetHealth(math.Clamp(target:Health() + Clockwork.schema:GetHealAmount(player), 0, target:GetMaxHealth()));
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
COMMAND.tip = "Set your radio frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local frequency = arguments[1];
	
	if (string.find(frequency, "^%d%d%d%.%d$")) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		start = tonumber(start); finish = tonumber(finish); decimal = tonumber(decimal);
		
		if ( !player:HasItemByID("handheld_radio") ) then
			Clockwork.player:Notify(player, "You do not own a radio item!");
			return;
		end;
		
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			player:SetCharacterData("Frequency", frequency);
			Clockwork.player:Notify(player, "You have set your radio frequency to "..frequency..".");
		else
			Clockwork.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		Clockwork.player:Notify(player, "The radio frequency must look like xxx.x!");
	end;
end;

Clockwork.command:Register(COMMAND, "SetFreq");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Untie the character that you're looking at.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local untieTime = Clockwork.schema:GetDexterityTime(player);
	local eyeTrace = player:GetEyeTraceNoCursor();
	local target = eyeTrace.Entity;
	local entity = target;
	
	if (IsValid(target)) then
		target = Clockwork.entity:GetPlayer(target);
		
		if (target and !player:GetSharedVar("IsTied")) then
			if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
				if (target:GetSharedVar("IsTied") and target:Alive()) then
					Clockwork.player:SetAction(player, "untie", untieTime);
					
					target:SetSharedVar("BeingUntied", true);
					
					Clockwork.player:EntityConditionTimer(player, target, entity, untieTime, 192, function()
						return player:Alive() and target:Alive() and !player:IsRagdolled() and !player:GetSharedVar("IsTied");
					end, function(success)
						if (success) then
							Clockwork.schema:TiePlayer(target, false);
							
							player:ProgressAttribute(ATB_DEXTERITY, 15, true);
						end;
						
						if (IsValid(target)) then
							target:SetSharedVar("BeingUntied", false);
						end;
						
						Clockwork.player:SetAction(player, "untie", false);
					end);
				else
					Clockwork.player:Notify(player, "This character is either not tied, or not alive!");
				end;
			else
				Clockwork.player:Notify(player, "This character is too far away!");
			end;
		else
			Clockwork.player:Notify(player, "You cannot do this action at the moment!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a character!");
	end;
end;

Clockwork.command:Register(COMMAND, "PlyUntie");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
end;

Clockwork.command:Register(COMMAND, "InvZipTie");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Take a container's password.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;

					traceLine.Entity.cwInventory = {};
				end;
				
				traceLine.Entity.cwPassword = nil;
				
				Clockwork.player:Notify(player, "This container's password has been removed.");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContTakePassword");

COMMAND.tip = "Set a container's password.";
COMMAND.text = "<string Pass>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;
					traceLine.Entity.cwInventory = {};
				end;
				
				traceLine.Entity.cwPassword = table.concat(arguments, " ");
				Clockwork.player:Notify(player, "This container's password has been set to '"..traceLine.Entity.cwPassword.."'.");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContSetPassword");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set a container's message.";
COMMAND.text = "<string Message>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			traceLine.Entity.cwMessage = arguments[1];
			Clockwork.player:Notify(player, "You have set this container's message.");
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContSetMessage");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Take a container's name.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			local name = table.concat(arguments, " ");
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;
					traceLine.Entity.cwInventory = {};
				end;
				
				traceLine.Entity:SetNetworkedString("Name", "");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContTakeName");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set a container's name.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			local name = table.concat(arguments, " ");
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;
					traceLine.Entity.cwInventory = {};
				end;
				
				traceLine.Entity:SetNetworkedString("Name", name);
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContSetName");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Fill a container with random items.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;
					traceLine.Entity.cwInventory = {};
				end;
				
				local containerWeight = Clockwork.schema.containers[model][1];
				local weight = Clockwork.inventory:CalculateWeight(traceLine.Entity.cwInventory);
				
				while (weight < containerWeight) do
					local randomItemInfo = Clockwork.schema:GetRandomItemInfo();
					
					if (randomItemInfo) then
						Clockwork.inventory:AddInstance(
							traceLine.Entity.cwInventory, Clockwork.item:CreateInstance(randomItemInfo[1])
						);
						
						weight = weight + randomItemInfo[2];
					end;
				end;
				
				Clockwork.player:Notify(player, "This container has been filled with random items.");
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContFill");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Remove safeboxs at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	local removed = 0;
	
	for k, v in pairs(Clockwork.schema.safeboxList) do
		if (v.position:Distance(traceLine.HitPos) <= 256) then
			if (IsValid(v.entity)) then
				v.entity:Remove();
			end;
			
			Clockwork.schema.safeboxList[k] = nil;
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			Clockwork.player:Notify(player, "You have removed "..removed.." safebox.");
		else
			Clockwork.player:Notify(player, "You have removed "..removed.." safeboxs.");
		end;
	else
		Clockwork.player:Notify(player, "There were no safeboxs near this position.");
	end;
	
	Clockwork.schema:SaveSafeboxList();
end;

Clockwork.command:Register(COMMAND, "SafeboxRemove");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Add a safebox at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	local data = {
		position = traceLine.HitPos + Vector(0, 0, 16)
	};
	
	data.angles = player:EyeAngles();
	data.angles.pitch = 0;
	data.angles.roll = 0;
	data.angles.yaw = data.angles.yaw + 180;
	
	data.entity = ents.Create("cw_safebox");
	data.entity:SetAngles(data.angles);
	data.entity:SetPos(data.position);
	data.entity:Spawn();
	
	data.entity:GetPhysicsObject():EnableMotion(false);
	
	Clockwork.schema.safeboxList[#Clockwork.schema.safeboxList + 1] = data;
	Clockwork.schema:SaveSafeboxList();
	
	Clockwork.player:Notify(player, "You have added a safebox.");
end;

Clockwork.command:Register(COMMAND, "SafeboxAdd");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Start a new group which you can invite players to.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player.cwGroupName = arguments[1];
	
	umsg.Start("cwStartGroup", player);
	umsg.End();
end;

Clockwork.command:Register(COMMAND, "GroupStart");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Kick a character from your group.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	local target = Clockwork.player:FindByID( arguments[1] );
	
	if (!myGroupInfo.name) then
		Clockwork.player:Notify(player, "You do not belong to a group at the moment!");
		return;
	end;
	
	if (!myGroupInfo.isLeader) then
		Clockwork.player:Notify(player, "You are not a leader of the group you belong to!");
		return;
	end;
	
	if (IsValid(target)) then
		local theirGroupInfo = target:GetCharacterData("GroupInfo");
		
		if (theirGroupInfo.name != myGroupInfo.name) then
			Clockwork.player:Notify(player, "This character is not a member of your group!");
			return;
		end;
		
		if (theirGroupInfo.isOwner or (theirGroupInfo.isLeader and !myGroupInfo.isOwner)) then
			Clockwork.player:Notify(player, "You do not have permission to kick this character!");
			return;
		end;
		
		theirGroupInfo.name = nil;
		theirGroupInfo.isOwner = nil;
		theirGroupInfo.isLeader = nil;
		
		Clockwork.player:Notify(target, "You have been kicked from the "..myGroupInfo.name.." group!");
		Clockwork.player:Notify(player, "You have kicked "..target:Name().." from your group.");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

Clockwork.command:Register(COMMAND, "GroupKick");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Invite a new character to your group.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	local target = Clockwork.player:FindByID( arguments[1] );
	
	if (!myGroupInfo.name) then
		Clockwork.player:Notify(player, "You do not belong to a group at the moment!");
		return;
	end;
	
	if (!myGroupInfo.isLeader) then
		Clockwork.player:Notify(player, "You are not a leader of the group you belong to!");
		return;
	end;
	
	if (player.cwNextInviteGroup and CurTime() < player.cwNextInviteGroup) then
		Clockwork.player:Notify(player, "You must wait five seconds to send another invite!");
		return;
	end;
	
	if (IsValid(target)) then
		local theirGroupInfo = target:GetCharacterData("GroupInfo");
		
		if (theirGroupInfo.name == myGroupInfo.name) then
			Clockwork.player:Notify(player, "This character is already a member of your group!");
			return;
		end;
		
		if (theirGroupInfo.name) then
			Clockwork.player:Notify(player, "This character is already a member of a group!");
			return;
		end;
		
		target.cwGroupInvite = myGroupInfo.name;
		player.cwNextInviteGroup = CurTime() + 5;
		
		umsg.Start("cwGroupInvite", target);
			umsg.String(myGroupInfo.name);
		umsg.End();
		
		Clockwork.player:Notify(player, "You have invited this character to your group.");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

Clockwork.command:Register(COMMAND, "GroupInvite");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Make a character a leader of your group.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local myGroupInfo = player:GetCharacterData("GroupInfo");
	local target = Clockwork.player:FindByID( arguments[1] );
	
	if (!myGroupInfo.name) then
		Clockwork.player:Notify(player, "You do not belong to a group at the moment!");
		return;
	end;
	
	if (!myGroupInfo.isOwner) then
		Clockwork.player:Notify(player, "You are not the owner of the group you belong to!");
		return;
	end;
	
	if (IsValid(target)) then
		local theirGroupInfo = target:GetCharacterData("GroupInfo");
		
		if (theirGroupInfo.name != myGroupInfo.name) then
			Clockwork.player:Notify(player, "This character is not a member of your group!");
			return;
		end;
		
		theirGroupInfo.isLeader = true;
		
		Clockwork.player:Notify(target, "You have been mader a leader of the "..myGroupInfo.name.." group!");
		Clockwork.player:Notify(player, "You have made "..target:Name().." a leader of your group.");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

Clockwork.command:Register(COMMAND, "GroupMakeLeader");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Make a copy of a unique item.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity) and traceLine.Entity:GetClass() == "cw_item") then
		local itemTable = traceLine.Entity:GetItemTable();
		
		if (itemTable:GetData("Name") != "") then
			local copyInstance = Clockwork.item:CreateCopy(itemTable);
			
			if (copyInstance) then
				local copyEntity = Clockwork.entity:CreateItem(
					nil, copyInstance, traceLine.HitPos + Vector(0, 0, 32)
				);
				
				if (IsValid(copyEntity)) then
					Clockwork.entity:CopyOwner(traceLine.Entity, copyEntity);
					player.cwItemCreateTime = CurTime() + 30;
				end;
			end;
		else
			Clockwork.player:Notify(player, "You cannot copy items that aren't customized!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid item entity!");
	end;
end;

Clockwork.command:Register(COMMAND, "UniqueItemCopy");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Save a unique item type to file for later use.";
COMMAND.text = "<string UniqueID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity) and traceLine.Entity:GetClass() == "cw_item") then
		local itemTable = traceLine.Entity:GetItemTable();
		
		if (itemTable:GetData("Name") != "") then
			if (itemTable:IsBasedFrom("custom_script")) then
				local itemType = {
					uniqueID = itemTable("uniqueID"),
					data = {Name = itemTable:GetData("Name")}
				};
				
				Clockwork:SaveSchemaData("itemtypes/"..arguments[1], itemType);
			else
				local itemType = {
					uniqueID = itemTable("uniqueID"),
					data = itemTable("data")
				};
				
				Clockwork:SaveSchemaData("itemtypes/"..arguments[1], itemType);
			end;
			
			Clockwork.player:Notify(player, "You have saved this item type as '"..arguments[1].."'.");
		else
			Clockwork.player:Notify(player, "You cannot save items that aren't customized!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid item entity!");
	end;
end;

Clockwork.command:Register(COMMAND, "UniqueItemSave");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Load a unique item type from file as an item entity.";
COMMAND.text = "<string UniqueID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	local itemType = Clockwork:RestoreSchemaData("itemtypes/"..arguments[1], false);
	
	if (itemType) then
		local itemInstance = Clockwork.item:CreateInstance(
			itemType.uniqueID, nil, itemType.data
		);
		local bIsScriptItem = itemInstance:IsBasedFrom("custom_script");
		
		if (itemInstance and (!bIsScriptItem or itemInstance:OnLoaded())) then
			local itemEntity = Clockwork.entity:CreateItem(
				nil, itemInstance, traceLine.HitPos + Vector(0, 0, 32)
			);
			
			if (IsValid(itemEntity)) then
				player.cwItemCreateTime = CurTime() + 30;
			end;
			
			--[[
				Something wrong here... let's write to the file again
				just to validate that everything is okay.
			--]]
			
			if (bIsScriptItem and table.Count(itemType.data) > 1) then
				itemType = {
					uniqueID = itemInstance("uniqueID"),
					data = {Name = itemInstance:GetData("Name")}
				};
				
				Clockwork:SaveSchemaData("itemtypes/"..arguments[1], itemType);
			end;
		else
			Clockwork.player:Notify(player, "The item type '"..arguments[1].."' is no longer supported!");
		end;
	else
		Clockwork.player:Notify(player, "There is no item type '"..arguments[1].."' saved on file!");
	end;
end;

Clockwork.command:Register(COMMAND, "UniqueItemLoad");

COMMAND = Clockwork.command:New();
COMMAND.tip = "List all saved unique item types to the console.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	player:PrintMessage(2, "######## [Clockwork] Item Types ########");
		local bOneItemType = false;
		
		for k, v in pairs(file.Find(Clockwork:GetSchemaDataPath().."/itemtypes/*.cw")) do
			player:PrintMessage(2, v);
			bOneItemType = true;
		end;
		
		if (!bOneItemType) then
			player:PrintMessage(2, "There are no item types saved to file!");
		end;
	player:PrintMessage(2, "######## [Clockwork] Item Types ########");
	
	Clockwork.player:Notify(player, "The item types have been printed to the console.");
end;

Clockwork.command:Register(COMMAND, "UniqueItemList");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Fill a container with a unique item type.";
COMMAND.text = "<string UniqueID> [number Amount]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local traceLine = player:GetEyeTraceNoCursor();
	
	if (IsValid(traceLine.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(traceLine.Entity)) then
			local model = string.lower(traceLine.Entity:GetModel());
			
			if (Clockwork.schema.containers[model]) then
				if (!traceLine.Entity.cwInventory) then
					Clockwork.schema.storage[traceLine.Entity] = traceLine.Entity;
					traceLine.Entity.cwInventory = {};
				end;
				
				local itemType = Clockwork:RestoreSchemaData("itemtypes/"..arguments[1], false);
				local amount = tonumber(arguments[2]);
				
				if (!amount or amount == 0) then
					Clockwork.player:Notify(player, "That is not a valid amount!");
					return;
				end;
				
				if (itemType) then
					local itemInstance = Clockwork.item:CreateInstance(
						itemType.uniqueID, nil, itemType.data
					);
					local bIsScriptItem = itemInstance:IsBasedFrom("custom_script");
					
					if (itemInstance and (!bIsScriptItem or itemInstance:OnLoaded())) then
						for i = 1, amount do
							if (i == 1) then
								Clockwork.inventory:AddInstance(
									traceLine.Entity.cwInventory, itemInstance
								);
							else
								Clockwork.inventory:AddInstance(
									traceLine.Entity.cwInventory,
									Clockwork.item:CreateCopy(itemInstance)
								);
							end;
						end;
						
						--[[
							Something wrong here... let's write to the file again
							just to validate that everything is okay.
						--]]
						
						if (bIsScriptItem and table.Count(itemType.data) > 1) then
							itemType = {
								uniqueID = itemInstance("uniqueID"),
								data = {Name = itemInstance:GetData("Name")}
							};
							
							Clockwork:SaveSchemaData("itemtypes/"..arguments[1], itemType);
						end;
						
						Clockwork.player:Notify(player, "This container has been filled with the unique item.");
					else
						Clockwork.player:Notify(player, "The item type '"..arguments[1].."' is no longer supported!");
					end;
				else
					Clockwork.player:Notify(player, "There is no item type '"..arguments[1].."' saved on file!");
				end;
			else
				Clockwork.player:Notify(player, "This is not a valid container!");
			end;
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "UniqueItemFill");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the table of unique items that NPCs can drop in this session.";
COMMAND.text = "<string UniqueID> [string UniqueID] ...";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.schema.uniqueItemsNPC = string.Explode(" ", arguments[1]);
	Clockwork.player:Notify(player, "You have set the unique items dropped by NPCs to "..table.concat(Clockwork.schema.uniqueItemsNPC, ", ")..".");
end;

Clockwork.command:Register(COMMAND, "UniqueItemNPC");