--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadLockers(); self:LoadStorage();
	
	-- Set some information.
	self.highestCost = 0;
	self.randomItems = {};
	
	-- Set some information.
	local k2, v2;
	local k, v;
	local i;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.item.stored) do
		if (v.business and !v.rare and !v.isBaseItem) then
			if (v.cost and v.cost > self.highestCost) then
				self.highestCost = v.cost;
			end;
			
			-- Set some information.
			self.randomItems[#self.randomItems + 1] = {
				v.uniqueID,
				v.weight,
				v.cost
			};
		end;
	end;
end;

-- Called when data should be saved.
function MOUNT:SaveData() self:SaveStorage(); end;

-- Called when a player attempts to breach an entity.
function MOUNT:PlayerCanBreachEntity(player, entity)
	if (entity._Inventory and entity._Password) then
		return true;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function MOUNT:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("ks_StorageName") != "") then
		return false;
	end;
end;

-- Called when a player presses F2.
function MOUNT:ShowTeam(player, password)
	local entity = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		if (entity:GetPos():Distance( player:GetShootPos() ) <= 192) then
			if ( hook.Call("PlayerUse", kuroScript.frame, player, entity) ) then
				if (entity:GetClass() == "ks_locker") then
					if ( kuroScript.inventory.HasItem(player, "locker_key") ) then
						if ( kuroScript.game:PlayerIsCombine(player) ) then
							local k, v;
							
							-- Loop through each value in a table.
							for k, v in ipairs( g_Player.GetAll() ) do
								if (v:HasInitialized() and v:GetSharedVar("ks_Tied") == 2) then
									umsg.Start("ks_PlayersLocker", player);
									umsg.End();
									
									-- Return true to break the function.
									return true;
								end;
							end;
						end;
						
						-- Open a container for the player.
						self:OpenContainer(player, entity);
						
						-- Return true to break the function.
						return true;
					end;
				elseif ( kuroScript.entity.IsPhysicsEntity(entity) ) then
					local model = string.lower( entity:GetModel() );
					
					-- Loop through each value in a table.
					if ( self.containers[model] ) then
						local containerWeight = self.containers[model][1];
						
						-- Check if a statement is true.
						if (!entity._Password or password == entity._Password or entity._Breached) then
							self:OpenContainer(player, entity, containerWeight);
						elseif (password) then
							kuroScript.player.Notify(player, "You have entered an incorrect password!");
						else
							umsg.Start("ks_ContainerPassword", player);
							umsg.End();
						end;
						
						-- Return true to break the function.
						return true;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when an entity has been breached.
function MOUNT:EntityBreached(entity, activator)
	if (entity._Inventory and entity._Password) then
		entity._Breached = true;
		
		-- Set some information.
		kuroScript.frame:CreateTimer("Reset Breached: "..entity:EntIndex(), 120, 1, function()
			if ( ValidEntity(entity) ) then entity._Breached = nil; end;
		end);
	end;
end;

-- Called when an entity is removed.
function MOUNT:EntityRemoved(entity)
	local k, v;
	local i;
	
	-- Check if a statement is true.
	if (!entity:IsPlayer() and entity._Inventory) then
		for k, v in pairs(entity._Inventory) do
			if (v > 0) then
				for i = 1, v do
					local item = kuroScript.entity.CreateItem( nil, k, entity:GetPos() + Vector( 0, 0, math.random(1, 48) ), entity:GetAngles() );
					
					-- Copy the entity's owner.
					kuroScript.entity.CopyOwner(entity, item);
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (entity._Currency and entity._Currency > 0) then
			kuroScript.entity.CreateCurrency( nil, entity._Currency, entity:GetPos() + Vector( 0, 0, math.random(1, 48) ) );
		end;
		
		-- Set some information.
		entity._Inventory = nil;
		entity._Currency = nil;
	end;
end;
-- Called when a player's prop cost info should be adjusted.
function MOUNT:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower( entity:GetModel() );
	
	-- Check if a statement is true.
	if ( self.containers[model] ) then
		info.name = self.containers[model][2];
	end;
end;

-- Called to check if a player does have an item.
function MOUNT:PlayerDoesHaveItem(player, itemTable)
	local locker = player:GetCharacterData("locker");
	
	-- Check if a statement is true.
	if ( locker and locker[itemTable.uniqueID] ) then
		return locker[itemTable.uniqueID];
	end;
end;

-- Called when a player's character data should be restored.
function MOUNT:PlayerRestoreCharacterData(player, data)
	local k, v;
	
	-- Set some information.
	data["locker"] = data["locker"] or {};
	data["lockercur"] = data["lockercur"] or 0;
	
	-- Loop through each value in a table.
	for k, v in pairs( data["locker"] ) do
		local itemTable = kuroScript.item.Get(k);
		
		-- Check if a statement is true.
		if (!itemTable) then
			hook.Call("PlayerHasUnknownInventoryItem", kuroScript.frame, player, data["locker"], k, v);
			
			-- Set some information.
			data["locker"][k] = nil;
		end;
	end;
end;