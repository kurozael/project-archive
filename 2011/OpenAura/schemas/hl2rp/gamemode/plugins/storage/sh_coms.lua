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
COMMAND.text = "<number Density: 1-5> [string Category]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local scale = tonumber( arguments[1] );
	
	if (scale) then
		scale = math.Clamp(math.Round(scale), 1, 5);
		
		if ( IsValid(trace.Entity) ) then
			if ( openAura.entity:IsPhysicsEntity(trace.Entity) ) then
				local model = string.lower( trace.Entity:GetModel() );
				
				if ( PLUGIN.containers[model] ) then
					if (!trace.Entity.inventory) then
						PLUGIN.storage[trace.Entity] = trace.Entity;
						
						trace.Entity.inventory = {};
					end;
					
					local containerWeight = PLUGIN.containers[model][1] / (6 - scale);
					local weight = 0;
					
					for k, v in pairs(trace.Entity.inventory) do
						local itemTable = openAura.item:Get(k);
						
						if (itemTable and itemTable.weight) then
							weight = weight + itemTable.weight;
						end;
					end;
					
					while (weight < containerWeight) do
						local item = PLUGIN:GetRandomItem( arguments[2] );
						local uniqueID;
						
						if (item) then
							uniqueID = item[1];
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
	else
		openAura.player:Notify(player, "This is not a valid scale!");
	end;
end;

openAura.command:Register(COMMAND, "ContFill");