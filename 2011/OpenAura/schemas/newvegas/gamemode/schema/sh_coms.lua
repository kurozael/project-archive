--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

COMMAND = openAura.command:New();
COMMAND.tip = "Set your radio frequency, or a stationary radio's frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local radio;
	
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
COMMAND.tip = "Set a character's custom class.";
COMMAND.text = "<string Name> <string Class>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = openAura.player:Get( arguments[1] )
	
	if (target) then
		target:SetCharacterData( "customclass", arguments[2] );
		
		openAura.player:NotifyAll(player:Name().." set "..target:Name().."'s custom class to "..arguments[2]..".");
	else
		openAura.player:Notify(player, arguments[1].." is not a valid character!");
	end;
end;

openAura.command:Register(COMMAND, "CharSetCustomClass");

COMMAND = openAura.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local itemTable = openAura.item:Get( arguments[1] );
	local entity = player:GetEyeTraceNoCursor().Entity;
	local healed;
	
	local target = openAura.entity:GetPlayer(entity);
	
	if (target) then
		if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if (itemTable and arguments[1] == "stimpack") then
				if ( player:HasItem("stimpack") ) then
					target:SetHealth( math.Clamp( target:Health() + openAura.schema:GetHealAmount(player, 3), 0, target:GetMaxHealth() ) );
					target:EmitSound("items/medshot4.wav");
					
					player:UpdateInventory("stimpack", -1, true);
					
					healed = true;
				else
					openAura.player:Notify(player, "You do not own a health vial!");
				end;
			elseif (itemTable and arguments[1] == "antibiotics") then
				if ( player:HasItem("antibiotics") ) then
					target:SetHealth( math.Clamp( target:Health() + openAura.schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth() ) );
					target:EmitSound("items/medshot4.wav");
					
					player:UpdateInventory("antibiotics", -1, true);
					
					healed = true;
				else
					openAura.player:Notify(player, "You do not own a health vial!");
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
end;

openAura.command:Register(COMMAND, "CharHeal");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove trash spawns at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32);
	local trashSpawns = 0;
	
	for k, v in pairs(openAura.schema.trashSpawns) do
		if (v:Distance(position) <= 256) then
			trashSpawns = trashSpawns + 1;
			
			openAura.schema.trashSpawns[k] = nil;
		end;
	end
	
	if (trashSpawns > 0) then
		if (trashSpawns == 1) then
			openAura.player:Notify(player, "You have removed "..trashSpawns.." trash spawn.");
		else
			openAura.player:Notify(player, "You have removed "..trashSpawns.." trash spawns.");
		end;
	else
		openAura.player:Notify(player, "There were no trash spawns near this position.");
	end;
	
	openAura.schema:SaveTrashSpawns();
end;

openAura.command:Register(COMMAND, "TrashSpawnRemove");

COMMAND = openAura.command:New();
COMMAND.tip = "Add a trash spawn at your target position.";
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos + Vector(0, 0, 32);
	
	openAura.schema.trashSpawns[#openAura.schema.trashSpawns + 1] = position;
	openAura.schema:SaveTrashSpawns();
	
	openAura.player:Notify(player, "You have added a trash spawn.");
end;

openAura.command:Register(COMMAND, "TrashSpawnAdd");

COMMAND = openAura.command:New();
COMMAND.tip = "Set the physical description of an object.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(target) ) then
		if (target:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if ( openAura.entity:IsPhysicsEntity(target) ) then
				if ( player:QueryCharacter("key") == target:GetOwnerKey() ) then
					player.objectPhysDesc = target;
					
					umsg.Start("aura_ObjectPhysDesc", player);
						umsg.Entity(target);
					umsg.End();
				else
					openAura.player:Notify(player, "You are not the owner of this entity!");
				end;
			else
				openAura.player:Notify(player, "This entity is not a physics entity!");
			end;
		else
			openAura.player:Notify(player, "This entity is too far away!");
		end;
	else
		openAura.player:Notify(player, "You must look at a valid entity!");
	end;
end;

openAura.command:Register(COMMAND, "ObjectPhysDesc");

COMMAND = openAura.command:New();
COMMAND.tip = "Use a zip tie from your inventory.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	openAura.player:RunOpenAuraCommand(player, "InvAction", "zip_tie", "use");
end;

openAura.command:Register(COMMAND, "InvZipTie");