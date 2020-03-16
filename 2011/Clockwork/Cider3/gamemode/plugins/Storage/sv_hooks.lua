--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player is given wages cash.
function PLUGIN:PlayerGiveWagesCash(player, cash, wagesName)
	Clockwork.chatBox:Add(player, nil, "wire", "You have been wire transfered your "..string.lower(wagesName).." of "..FORMAT_CASH(cash)..".");
	player:SetCharacterData("BankCash", player:GetCharacterData("BankCash") + cash);
	
	return false;
end;

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadPersonalStorage();
	self:LoadStorage();
	self.highestCost = 0;
	self.randomItems = {};
	
	for k, v in pairs(Clockwork.item:GetAll()) do
		if (v("business") and !v("isRareItem") and !v("isBaseItem")) then
			if (v("cost") > self.highestCost) then
				self.highestCost = v.cost;
			end;
			
			self.randomItems[#self.randomItems + 1] = {
				v("uniqueID"),
				v("weight"),
				v("cost")
			};
		end;
	end;
end;

-- Called when data should be saved.
function PLUGIN:SaveData() self:SaveStorage(); end;

-- Called when a player attempts to breach an entity.
function PLUGIN:PlayerCanBreachEntity(player, entity)
	if (entity.cwInventory and entity.cwPassword) then
		return true;
	end;
end;

-- Called when an entity attempts to be auto-removed.
function PLUGIN:EntityCanAutoRemove(entity)
	if (self.storage[entity] or entity:GetNetworkedString("Name") != "") then
		return false;
	end;
end;

-- Called when an entity's menu option should be handled.
function PLUGIN:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if ((class == "cw_locker" or class == "cw_cashmachine") and arguments == "cwContainerOpen") then
		self:OpenContainer(player, entity);
	elseif (arguments == "cwContainerOpen") then
		if (Clockwork.entity:IsPhysicsEntity(entity)) then
			local model = string.lower(entity:GetModel());
			
			if (self.containers[model]) then
				local containerWeight = self.containers[model][1];
				
				if (!entity.cwPassword or entity.cwIsBreached) then
					self:OpenContainer(player, entity, containerWeight);
				else
					umsg.Start("cwContainerPassword", player);
						umsg.Entity(entity);
					umsg.End();
				end;
			end;
		end;
	end;
end;

-- Called when an entity has been breached.
function PLUGIN:EntityBreached(entity, activator)
	if (entity.cwInventory and entity.cwPassword) then
		entity.cwIsBreached = true;
		
		Clockwork:CreateTimer("ResetBreach"..entity:EntIndex(), 120, 1, function()
			if (IsValid(entity)) then entity.cwIsBreached = nil; end;
		end);
	end;
end;

-- Called when an entity is removed.
function PLUGIN:EntityRemoved(entity)
	if (IsValid(entity) and !entity.cwIsBelongings) then
		Clockwork.entity:DropItemsAndCash(entity.cwInventory, entity.cwCash, entity:GetPos(), entity);
		
		entity.cwInventory = nil;
		entity.cwCash = nil;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function PLUGIN:PlayerAdjustPropCostInfo(player, entity, info)
	local model = string.lower(entity:GetModel());
	
	if (self.containers[model]) then
		info.name = self.containers[model][2];
	end;
end;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if (data["LockerItems"]) then
		data["LockerItems"] = Clockwork.inventory:ToSaveable(data["LockerItems"]);
	end;
end;

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["LockerItems"] = Clockwork.inventory:ToLoadable(data["LockerItems"] or {});
	data["BankCash"] = data["BankCash"] or 0;
end;

-- Called when a player's character has initialized.
function PLUGIN:PlayerCharacterInitialized(player)
	player.cwNextInterestTime = CurTime() + 3600;
end;

-- Called when a player dies.
function PLUGIN:PlayerDeath(player, inflictor, attacker, damageInfo)
	player:SetCharacterData("BankCash", math.max(player:GetCharacterData("BankCash") - 50, 0));
	Clockwork.chatBox:Add(player, nil, "wire", "Your hospital bill of "..FORMAT_CASH(50).." has been taken from your bank.");
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	if (player.cwNextInterestTime) then
		if (curTime >= player.cwNextInterestTime) then
			local atmCash = player:GetCharacterData("BankCash");
			
			player.cwNextInterestTime = curTime + 3600;
			
			if (atmCash > 0 and atmCash < 50000) then
				local newCash = math.Round(atmCash / 100);
				
				if (newCash > 0) then
					Clockwork.chatBox:Add(player, nil, "wire", "You have gained "..FORMAT_CASH(cash).." interest from your bank.");
				end;
			end;
		end;
	end;
end;