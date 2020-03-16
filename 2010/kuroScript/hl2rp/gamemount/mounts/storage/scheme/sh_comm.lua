--[[
Name: "sh_comm.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;
local COMMAND = {};

-- Set some information.
COMMAND.tip = "Set a container's password.";
COMMAND.text = "<name|none>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if ( ValidEntity(trace.Entity) ) then
		if ( kuroScript.entity.IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			
			-- Loop through each value in a table.
			if ( MOUNT.containers[model] ) then
				if (!trace.Entity._Inventory) then
					MOUNT.storage[trace.Entity] = trace.Entity;
					
					-- Set some information.
					trace.Entity._Inventory = {};
				end;
				
				-- Set some information.
				trace.Entity._Password = table.concat(arguments, " ");
				
				-- Check if a statement is true.
				if (trace.Entity._Password == "none") then
					trace.Entity._Password = nil;
					
					-- Notify the player.
					kuroScript.player.Notify(player, "This container's password has been removed.");
				else
					kuroScript.player.Notify(player, "This container's password has been set to '"..trace.Entity._Password.."'.");
				end;
				
				-- Return to break the function.
				return;
			end;
			
			-- Notify the player.
			kuroScript.player.Notify(player, "This is not a valid container!");
		else
			kuroScript.player.Notify(player, "This is not a valid container!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid container!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "passwordcontainer");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set a container's name.";
COMMAND.text = "<name|none>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if ( ValidEntity(trace.Entity) ) then
		if ( kuroScript.entity.IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			local name = table.concat(arguments, " ");
			
			-- Loop through each value in a table.
			if ( MOUNT.containers[model] ) then
				if (!trace.Entity._Inventory) then
					MOUNT.storage[trace.Entity] = trace.Entity;
					
					-- Set some information.
					trace.Entity._Inventory = {};
				end;
				
				-- Check if a statement is true.
				if (name == "none") then
					trace.Entity:SetNetworkedString("ks_StorageName", "");
				else
					trace.Entity:SetNetworkedString("ks_StorageName", name);
				end;
				
				-- Return to break the function.
				return;
			end;
			
			-- Notify the player.
			kuroScript.player.Notify(player, "This is not a valid container!");
		else
			kuroScript.player.Notify(player, "This is not a valid container!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid container!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "namecontainer");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Fill a container with random items.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if ( ValidEntity(trace.Entity) ) then
		if ( kuroScript.entity.IsPhysicsEntity(trace.Entity) ) then
			local model = string.lower( trace.Entity:GetModel() );
			local k, v;
			
			-- Loop through each value in a table.
			if ( MOUNT.containers[model] ) then
				if (!trace.Entity._Inventory) then
					MOUNT.storage[trace.Entity] = trace.Entity;
					
					-- Set some information.
					trace.Entity._Inventory = {};
				end;
				
				-- Set some information.
				local containerWeight = MOUNT.containers[model][1];
				local weight = 0;
				
				-- Loop through each value in a table.
				for k, v in pairs(trace.Entity._Inventory) do
					local itemTable = kuroScript.item.Get(k);
					
					-- Check if a statement is true.
					if (itemTable and itemTable.weight) then
						weight = weight + itemTable.weight;
					end;
				end;
				
				-- Loop while a statement is true.
				while (weight < containerWeight) do
					local item = MOUNT:GetRandomItem();
					
					-- Check if a statement is true.
					if (item) then
						local uniqueID = item[1];
						
						-- Set some information.
						weight = weight + item[2];
						
						-- Set some information.
						trace.Entity._Inventory[uniqueID] = trace.Entity._Inventory[uniqueID] or 0;
						trace.Entity._Inventory[uniqueID] = trace.Entity._Inventory[uniqueID] + 1;
					end;
				end;
				
				-- Notify the player.
				kuroScript.player.Notify(player, "This container has been filled with random items.");
				
				-- Return to break the function.
				return;
			end;
			
			-- Notify the player.
			kuroScript.player.Notify(player, "This is not a valid container!");
		else
			kuroScript.player.Notify(player, "This is not a valid container!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid container!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "fillcontainer");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove a locker.";
COMMAND.text = "<add|remove>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if (arguments[1] == "add") then
		local data = {
			position = trace.HitPos + Vector(0, 0, 36)
		};
		
		-- Set some information.
		data.angles = player:EyeAngles();
		data.angles.pitch = 0;
		data.angles.roll = 0;
		data.angles.yaw = data.angles.yaw + 180;
		
		-- Set some information.
		data.entity = ents.Create("ks_locker");
		data.entity:SetAngles(data.angles);
		data.entity:SetPos(data.position);
		data.entity:Spawn();
		
		-- Disable the entity's motion.
		data.entity:GetPhysicsObject():EnableMotion(false);
		
		-- Set some information.
		MOUNT.lockers[#MOUNT.lockers + 1] = data; MOUNT:SaveLockers();
		
		-- Notify the player.
		kuroScript.player.Notify(player, "You have added a locker.");
	else
		local removed = 0;
		
		-- Loop through each value in a table.
		for k, v in pairs(MOUNT.lockers) do
			if (v.position:Distance(trace.HitPos) <= 256) then
				if ( ValidEntity(v.entity) ) then
					v.entity:Remove();
				end;
				
				-- Set some information.
				MOUNT.lockers[k] = nil;
				
				-- Set some information.
				removed = removed + 1;
			end;
		end;
		
		-- Check if a statement is true.
		if (removed > 0) then
			if (removed == 1) then
				kuroScript.player.Notify(player, "You have removed "..removed.." locker.");
			else
				kuroScript.player.Notify(player, "You have removed "..removed.." lockers.");
			end;
		else
			kuroScript.player.Notify(player, "There were no lockers near this position.");
		end;
		
		-- Save the lockers.
		MOUNT:SaveLockers();
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "locker");