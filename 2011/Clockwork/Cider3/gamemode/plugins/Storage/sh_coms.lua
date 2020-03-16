--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = Clockwork.command:New();
COMMAND.tip = "Take a container's password.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			
			if (PLUGIN.containers[model]) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity.cwPassword = nil;
				
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
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			
			if (PLUGIN.containers[model]) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity.cwPassword = table.concat(arguments, " ");
				
				Clockwork.player:Notify(player, "This container's password has been set to '"..trace.Entity.cwPassword.."'.");
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
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			trace.Entity.cwMessage = arguments[1];
			
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
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			local name = table.concat(arguments, " ");
			
			if (PLUGIN.containers[model]) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity:SetNetworkedString("Name", "");
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
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			local name = table.concat(arguments, " ");
			
			if (PLUGIN.containers[model]) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity:SetNetworkedString("Name", name);
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
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity)) then
		if (Clockwork.entity:IsPhysicsEntity(trace.Entity)) then
			local model = string.lower(trace.Entity:GetModel());
			-- local k, v;
			
			if (PLUGIN.containers[model]) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				local containerWeight = PLUGIN.containers[model][1];
				local weight = Clockwork.inventory:CalculateWeight(trace.Entity.inventory);
				
				while (weight < containerWeight) do
					local randomItem = PLUGIN:GetRandomItem();
					
					if (randomItem) then
						Clockwork.inventory:AddInstance(
							trace.Entity.inventory, Clockwork.item:CreateInstance(randomItem[1])
						);
						
						weight = weight + randomItem[2];
					end;
				end;
				
				Clockwork.player:Notify(player, "This container has been filled with random items.");
				
				return;
			end;
			
			Clockwork.player:Notify(player, "This is not a valid container!");
		else
			Clockwork.player:Notify(player, "This is not a valid container!");
		end;
	else
		Clockwork.player:Notify(player, "This is not a valid container!");
	end;
end;

Clockwork.command:Register(COMMAND, "ContFill");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Remove lockers at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local removed = 0;
	
	for k, v in pairs(PLUGIN.personalStorage) do
		if (v.position:Distance(trace.HitPos) <= 256 and !v.isATM) then
			if (IsValid(v.entity)) then
				v.entity:Remove();
			end;
			
			PLUGIN.personalStorage[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			Clockwork.player:Notify(player, "You have removed "..removed.." locker.");
		else
			Clockwork.player:Notify(player, "You have removed "..removed.." lockers.");
		end;
	else
		Clockwork.player:Notify(player, "There were no lockers near this position.");
	end;
	
	PLUGIN:SavePersonalStorage();
end;

Clockwork.command:Register(COMMAND, "LockerRemove");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Add a locker at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local data = {
		position = trace.HitPos + Vector(0, 0, 36),
		isATM = false
	};
	
	data.angles = player:EyeAngles();
	data.angles.pitch = 0;
	data.angles.roll = 0;
	data.angles.yaw = data.angles.yaw + 180;
	
	data.entity = ents.Create("cw_locker");
	data.entity:SetAngles(data.angles);
	data.entity:SetPos(data.position);
	data.entity:Spawn();
	
	data.entity:GetPhysicsObject():EnableMotion(false);
	
	PLUGIN.personalStorage[#PLUGIN.personalStorage + 1] = data;
	PLUGIN:SavePersonalStorage();
	
	Clockwork.player:Notify(player, "You have added a locker.");
end;

Clockwork.command:Register(COMMAND, "LockerAdd");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Remove ATMs at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local removed = 0;
	
	for k, v in pairs(PLUGIN.personalStorage) do
		if (v.position:Distance(trace.HitPos) <= 256 and v.isATM) then
			if (IsValid(v.entity)) then
				v.entity:Remove();
			end;
			
			PLUGIN.personalStorage[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			Clockwork.player:Notify(player, "You have removed "..removed.." ATM.");
		else
			Clockwork.player:Notify(player, "You have removed "..removed.." ATMs.");
		end;
	else
		Clockwork.player:Notify(player, "There were no ATMs near this position.");
	end;
	
	PLUGIN:SavePersonalStorage();
end;

Clockwork.command:Register(COMMAND, "AtmRemove");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Add an ATM at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local data = {
		position = trace.HitPos + Vector(0, 0, 36),
		isATM = true
	};
	
	data.angles = player:EyeAngles();
	data.angles.pitch = 0;
	data.angles.roll = 0;
	data.angles.yaw = data.angles.yaw + 180;
	
	data.entity = ents.Create("cw_cashmachine");
	data.entity:SetAngles(data.angles);
	data.entity:SetPos(data.position);
	data.entity:Spawn();
	
	data.entity:SetColor(255, 255, 255, 0);
	data.entity:GetPhysicsObject():EnableMotion(false);
	
	PLUGIN.personalStorage[#PLUGIN.personalStorage + 1] = data;
	PLUGIN:SavePersonalStorage();
	
	Clockwork.player:Notify(player, "You have added an ATM.");
end;

Clockwork.command:Register(COMMAND, "AtmAdd");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Set your wire transfer identification number.";
COMMAND.text = "<string ID>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local wireID = tmysql.escape(string.gsub(arguments[1], "%s%p", ""));
	
	tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Data LIKE \"%\\\"WireID\\\":\\\""..wireID.."\\\"\"%", function(result)
		if (IsValid(player)) then
			if (result and type(result) == "table" and #result > 0) then
				Clockwork.player:Notify(player, "The wire transfer number '"..wireID.."' already exists!");
			else
				player:SetCharacterData("WireID", wireID);
				Clockwork.player:Notify(player, "You set your wire transfer number to '"..wireID.."'.");
			end;
		end;
	end, 1);
end;

Clockwork.command:Register(COMMAND, "SetWireID");

COMMAND = Clockwork.command:New();
COMMAND.tip = "Wire transfer money.";
COMMAND.text = "<string ID> <number Amount>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local playerWireID = player:GetCharacterData("WireID");
	local entities = ents.FindByClass("cw_cashmachine");
	local position = player:GetPos();
	local nearATM = nil;
	
	for k, v in ipairs(entities) do
		if (v:GetPos():Distance(position) <= 256) then
			nearATM = true;
			
			break;
		end;
	end;
	
	if (playerWireID and playerWireID != "") then
		if (nearATM) then
			local wireID = string.gsub(arguments[1], "%s%p", "");
			local amount = tonumber(arguments[2]);
			
			if (amount and amount > 0) then
				amount = math.floor(amount);
			
				if (playerWireID != wireID) then
					local playerCash = player:GetCharacterData("BankCash");
					local formatAmount = FORMAT_CASH(amount);
					local recipient;
					
					if (playerCash >= amount) then
						for k, v in ipairs(_player.GetAll()) do
							if (v:HasInitialized() and v:Alive()) then
								if (v:GetCharacterData("WireID") == wireID) then
									recipient = v;
									
									break;
								end;
							end;
						end;
						
						if (recipient) then
							player:SetCharacterData("BankCash", playerCash - amount);
							recipient:SetCharacterData("BankCash", recipient:GetCharacterData("BankCash") + amount);
							
							Clockwork.chatBox:Add(player, nil, "wire", "You have wire transfered "..formatAmount.." to "..wireID..".");
							Clockwork.chatBox:Add(recipient, nil, "wire", "You have been wire transfered "..formatAmount.." from "..playerWireID..".");
						else
							Clockwork.player:Notify(player, "The wire transfer number could not be found!");
						end;
					else
						Clockwork.player:Notify(player, "You need another "..FORMAT_CASH(amount - playerCash, nil, true).." in your bank!");
					end;
				else
					Clockwork.player:Notify(player, "You cannot wire transfer money to yourself!");
				end;
			else
				Clockwork.player:Notify(player, "This is not a valid amount!");
			end;
		else
			Clockwork.player:Notify(player, "You need to be near an ATM to wire transfer.");
		end;
	else
		Clockwork.player:Notify(player, "You have not set a wire transfer number!");
	end;
end;

Clockwork.command:Register(COMMAND, "Wire");