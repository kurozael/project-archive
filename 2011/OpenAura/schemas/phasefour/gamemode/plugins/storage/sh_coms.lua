--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = openAura.command:New();
COMMAND.tip = "Take a container's password.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			
			if ( PLUGIN.containers[model] ) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity.password = nil;
				
				openAura.player:Notify(player, "This container's password has been removed.");
			else
				openAura.player:Notify(player, "This is not a valid container!");
			end;
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContTakePassword");

COMMAND.tip = "Set a container's password.";
COMMAND.text = "<string Pass>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			
			if ( PLUGIN.containers[model] ) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity.password = table.concat(arguments, " ");
				
				openAura.player:Notify(player, "This container's password has been set to '"..trace.Entity.password.."'.");
			else
				openAura.player:Notify(player, "This is not a valid container!");
			end;
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContSetPassword");

COMMAND = openAura.command:New();
COMMAND.tip = "Set a container's message.";
COMMAND.text = "<string Message>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			trace.Entity.message = arguments[1];
			
			openAura.player:Notify(player, "You have set this container's message.");
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContSetMessage");

COMMAND = openAura.command:New();
COMMAND.tip = "Take a container's name.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			local name = table.concat(arguments, " ");
			
			if ( PLUGIN.containers[model] ) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity:SetNetworkedString("name", "");
			else
				openAura.player:Notify(player, "This is not a valid container!");
			end;
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContTakeName");

COMMAND = openAura.command:New();
COMMAND.tip = "Set a container's name.";
COMMAND.text = "[string Name]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			local name = table.concat(arguments, " ");
			
			if ( PLUGIN.containers[model] ) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				trace.Entity:SetNetworkedString("name", name);
			else
				openAura.player:Notify(player, "This is not a valid container!");
			end;
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContSetName");

COMMAND = openAura.command:New();
COMMAND.tip = "Fill a container with random items.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	if ( IsValid(trace.Entity) ) then
		if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			
			if ( PLUGIN.containers[model] ) then
				if (!trace.Entity.inventory) then
					PLUGIN.storage[trace.Entity] = trace.Entity;
					
					trace.Entity.inventory = {};
				end;
				
				local containerWeight = PLUGIN.containers[model][1];
				local weight = 0;
				
				for k, v in pairs(trace.Entity.inventory) do
					local itemTable = openAura.item:Get(k);
					
					if (itemTable and itemTable.weight) then
						weight = weight + itemTable.weight;
					end;
				end;
				
				while (weight < containerWeight) do
					local item = PLUGIN:GetRandomItem();
					
					if (item) then
						local uniqueID = item[1];
						
						weight = weight + item[2];
						
						trace.Entity.inventory[uniqueID] = trace.Entity.inventory[uniqueID] or 0;
						trace.Entity.inventory[uniqueID] = trace.Entity.inventory[uniqueID] + 1;
					end;
				end;
				
				openAura.player:Notify(player, "This container has been filled with random items.");
				
				return;
			end;
			
			openAura.player:Notify(player, "This is not a valid container!");
		else
			openAura.player:Notify(player, "This is not a valid container!");
		end;
	else
		openAura.player:Notify(player, "This is not a valid container!");
	end;
end;

openAura.command:Register(COMMAND, "ContFill");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove safeboxs at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local removed = 0;
	
	for k, v in pairs(PLUGIN.personalStorage) do
		if (v.position:Distance(trace.HitPos) <= 256) then
			if ( IsValid(v.entity) ) then
				v.entity:Remove();
			end;
			
			PLUGIN.personalStorage[k] = nil;
			
			removed = removed + 1;
		end;
	end;
	
	if (removed > 0) then
		if (removed == 1) then
			openAura.player:Notify(player, "You have removed "..removed.." safebox.");
		else
			openAura.player:Notify(player, "You have removed "..removed.." safeboxs.");
		end;
	else
		openAura.player:Notify(player, "There were no safeboxs near this position.");
	end;
	
	PLUGIN:SavePersonalStorage();
end;

openAura.command:Register(COMMAND, "SafeboxRemove");

COMMAND = openAura.command:New();
COMMAND.tip = "Add a safebox at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local data = {
		position = trace.HitPos + Vector(0, 0, 16)
	};
	
	data.angles = player:EyeAngles();
	data.angles.pitch = 0;
	data.angles.roll = 0;
	data.angles.yaw = data.angles.yaw + 180;
	
	data.entity = ents.Create("aura_safebox");
	data.entity:SetAngles(data.angles);
	data.entity:SetPos(data.position);
	data.entity:Spawn();
	
	data.entity:GetPhysicsObject():EnableMotion(false);
	
	PLUGIN.personalStorage[#PLUGIN.personalStorage + 1] = data;
	PLUGIN:SavePersonalStorage();
	
	openAura.player:Notify(player, "You have added a safebox.");
end;

openAura.command:Register(COMMAND, "SafeboxAdd");