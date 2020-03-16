--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if (self.characters and self.economy) then
		if (infoTable.wages > 0) then
			infoTable.wages = self:ConvertCurrency(infoTable.wages);
		end;
	end;
end;

-- Called when kuroScript has initialized.
function MOUNT:KuroScriptInitialized()
	if (!self.defaultCurrency) then
		self.defaultCurrency = kuroScript.config.Get("default_currency"):Get();
	end;
	
	-- Check if a statement is true.
	if (!self.doorCost) then
		self.doorCost = kuroScript.config.Get("door_cost"):Get();
	end;
	
	-- Calculate the inflation.
	self:CalculateInflation();
end;

-- Called when a player's character has loaded.
function MOUNT:PlayerCharacterLoaded(player)
	self:UpdateCosts(player);
	
	-- Set some information.
	kuroScript.frame:CreateTimer("Calculate Inflation", 8, 1, function()
		self:CalculateInflation();
	end);
end;

-- Called when kuroScript config has initialized.
function MOUNT:KuroScriptConfigInitialized(key, value)
	if (key == "default_currency") then
		self.defaultCurrency = value;
	elseif (key == "door_cost") then
		self.doorCost = value;
	end;
end;

-- Called when kuroScript config has changed.
function MOUNT:KuroScriptConfigChanged(key, data, previousValue, newValue)
	if (!data.temporary) then
		if (key == "default_currency") then
			self.defaultCurrency = newValue;
			
			-- Calculate the default currency inflation.
			self:CalculateDefaultCurrencyInflation();
		elseif (key == "door_cost") then
			self.doorCost = newValue;
			
			-- Calculate the door inflation.
			self:CalculateDoorInflation();
		end;
	end;
end;

-- Called when a player's prop cost info should be adjusted.
function MOUNT:PlayerAdjustPropCostInfo(player, entity, info)
	if (self.characters and self.economy) then
		info.cost = self:ConvertCurrency(info.cost);
	end;
end;