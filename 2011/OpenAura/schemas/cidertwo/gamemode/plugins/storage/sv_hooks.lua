--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player is given wages cash.
function PLUGIN:PlayerGiveWagesCash(player, cash, wagesName)
	openAura.chatBox:Add(player, nil, "wire", "You have been wire transfered your "..string.lower(wagesName).." of "..FORMAT_CASH(cash)..".");
	
	player:SetCharacterData("lockercash", player:GetCharacterData("lockercash") + cash);
	
	return false;
end;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
	self:LoadPersonalStorage();
	self:LoadStorage();
	self.highestCost = 0;
	self.randomItems = {};
	
	for k, v in pairs(openAura.item.stored) do
		if (v.business and !v.isRareItem and !v.isBaseItem) then
			if (v.cost and v.cost > self.highestCost) then
				self.highestCost = v.cost;
			end;
			
			self.randomItems[#self.randomItems + 1] = {
				v.uniqueID,
				v.weight,
				v.cost
			};
		end;
	end;
end;

-- Called when data should be saved.
function PLUGIN:SaveData() self:SaveStorage(); end;

-- Called when a player attempts to breach an entity.
function PLUGIN:PlayerCanBreachEntity(player, entity)
	if (entity.inventory and entity.password) then
		return true;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function PLUGIN:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("aura_StorageName") != "") then
		return false;
	end;
end;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if ( (class == "aura_locker" or class == "aura_atm") and arguments == "aura_containerOpen" ) then
		self:OpenContainer(player, entity);
	elseif (arguments == "aura_containerOpen") then
		if ( openAura.entity:IsPhysicsEntity(entity) ) then
			local model = string.lower( entity:GetModel() );
			
			if ( self.containers[model] ) then
				local containerWeight = self.containers[model][1];
				
				if (!entity.password or entity.breached) then
					self:OpenContainer(player, entity, containerWeight);
				else
					umsg.Start("aura_ContainerPassword", player);
						umsg.Entity(entity);
					umsg.End();
				end;
			end;
		end;
	end;
end;

-- Called when an entity has been breached.
function PLUGIN:EntityBreached(entity, activator)
	if (entity.inventory and entity.password) then
		entity.breached = true;
		
		openAura:CreateTimer("reset_breach_"..entity:EntIndex(), 120, 1, function()
			if ( IsValid(entity) ) then entity.breached = nil; end;
		end);
	end;
end;

-- Called when an entity is removed.
function PLUGIN:EntityRemoved(entity)
	if (IsValid(entity) and !entity.areBelongings) then
		openAura.entity:DropItemsAndCash(entity.inventory, entity.cash, entity:GetPos(), entity);
		
		entity.inventory = nil;
		entity.cash = nil;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function PLUGIN:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower( entity:GetModel() );
	
	if ( self.containers[model] ) then
		info.name = self.containers[model][2];
	end;
end;

-- Called to check if a player does have an item.
function PLUGIN:PlayerDoesHaveItem(player, itemTable)
	local locker = player:GetCharacterData("lockerstorage");
	
	if ( locker and locker[itemTable.uniqueID] ) then
		return locker[itemTable.uniqueID];
	end;
end;

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["lockerstorage"] = data["lockerstorage"] or {};
	data["lockercash"] = data["lockercash"] or 0;
	
	for k, v in pairs( data["lockerstorage"] ) do
		local itemTable = openAura.item:Get(k);
		
		if (!itemTable) then
			hook.Call("PlayerHasUnknownInventoryItem", openAura, player, data["lockerstorage"], k, v);
			
			data["lockerstorage"][k] = nil;
		end;
	end;
end;

-- Called when a player's character has initialized.
function PLUGIN:PlayerCharacterInitialized(player)
	player.nextGainInterestTime = CurTime() + 3600;
end;

-- Called when a player dies.
function PLUGIN:PlayerDeath(player, inflictor, attacker, damageInfo)
	player:SetCharacterData( "lockercash", math.max(player:GetCharacterData("lockercash") - 50, 0) );
	
	openAura.chatBox:Add(player, nil, "wire", "Your hospital bill of "..FORMAT_CASH(50).." has been taken from your bank.");
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	if (player.nextGainInterestTime) then
		if (curTime >= player.nextGainInterestTime) then
			local atmCash = player:GetCharacterData("lockercash");
			
			player.nextGainInterestTime = curTime + 3600;
			
			if (atmCash > 0 and atmCash < 50000) then
				local newCash = math.Round(atmCash / 100);
				
				if (newCash > 0) then
					openAura.chatBox:Add(player, nil, "wire", "You have gained "..FORMAT_CASH(cash).." interest from your bank.");
				end;
			end;
		end;
	end;
end;