--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

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
COMMAND.tip = "Set a character's custom class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1])
	
	if (target) then
		target:SetCharacterData("CustomClass", arguments[2]);
		
		Clockwork.player:NotifyAll(player:Name().." set "..target:Name().."'s custom class to "..arguments[2]..".");
	else
		Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharSetCustomClass");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
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
			
			if (arguments[1] == "stimpack") then
				target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 3), 0, target:GetMaxHealth()));
				target:EmitSound("items/medshot4.wav");
				player:TakeItem(itemTable);
				bIsHealed = true;
			elseif (arguments[1] == "antibiotics") then
				target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth()));
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
end;

Clockwork.command:Register(COMMAND, "CharHeal");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Remove trash spawns at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32);
	local trashSpawns = 0;
	
	for k, v in pairs(Schema.trashSpawns) do
		if (v:Distance(position) <= 256) then
			trashSpawns = trashSpawns + 1;
			
			Schema.trashSpawns[k] = nil;
		end;
	end
	
	if (trashSpawns > 0) then
		if (trashSpawns == 1) then
			Clockwork.player:Notify(player, "You have removed "..trashSpawns.." trash spawn.");
		else
			Clockwork.player:Notify(player, "You have removed "..trashSpawns.." trash spawns.");
		end;
	else
		Clockwork.player:Notify(player, "There were no trash spawns near this position.");
	end;
	
	Schema:SaveTrashSpawns();
end;

Clockwork.command:Register(COMMAND, "TrashSpawnRemove");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Add a trash spawn at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32);
	
	Schema.trashSpawns[#Schema.trashSpawns + 1] = position;
	Schema:SaveTrashSpawns();
	
	Clockwork.player:Notify(player, "You have added a trash spawn.");
end;

Clockwork.command:Register(COMMAND, "TrashSpawnAdd");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set the physical description of an object.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if (IsValid(target)) then
		if (target:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (Clockwork.entity:IsPhysicsEntity(target)) then
				if (player:GetCharacterKey() == target:GetOwnerKey()) then
					player.cwObjectPhysDesc = target;
					
					umsg.Start("cwObjectPhysDesc", player);
						umsg.Entity(target);
					umsg.End();
				else
					Clockwork.player:Notify(player, "You are not the owner of this entity!");
				end;
			else
				Clockwork.player:Notify(player, "This entity is not a physics entity!");
			end;
		else
			Clockwork.player:Notify(player, "This entity is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a valid entity!");
	end;
end;

Clockwork.command:Register(COMMAND, "ObjectPhysDesc");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	Clockwork.player:RunClockworkCommand(player, "InvAction", "use", "zip_tie");
end;

Clockwork.command:Register(COMMAND, "InvZipTie");