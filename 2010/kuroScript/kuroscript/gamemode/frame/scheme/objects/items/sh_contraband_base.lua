--[[
Name: "sh_contraband_base.lua".
Product: "kuroScript".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Contraband Base";
ITEM.model = "models/props_combine/combine_mine01.mdl";
ITEM.batch = 1;
ITEM.weight = 3;
ITEM.category = "Contraband";
ITEM.isBaseItem = true;

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	return kuroScript.entity.CreateContraband(player, self.contraband.uniqueID, position);
end;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return kuroScript.entity.CreateContraband(player, self.contraband.uniqueID, position);
end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (self.contraband) then
		kuroScript.contraband.Register(
			self.contraband.name,
			self.contraband.power,
			self.contraband.health,
			self.contraband.maximum,
			self.contraband.currency,
			self.contraband.uniqueID,
			self.contraband.powerName,
			self.contraband.powerPlural
		);
	end;
end;

-- Called when a player attempts to order the item.
function ITEM:CanOrder(player)
	if (self.contraband) then
		local contraband = kuroScript.contraband.Get(self.contraband.uniqueID);
		local maximum = contraband.maximum;
		
		-- Check if a statement is true.
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		-- Check if a statement is true.
		if (contraband) then
			if (kuroScript.player.GetPropertyCount(player, self.contraband.uniqueID) >= maximum) then
				kuroScript.player.Notify(player, "You have reached this contraband's maximum!");
				
				-- Return false to break the function.
				return false;
			end;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (self.contraband) then
		local contraband = kuroScript.contraband.Get(self.contraband.uniqueID);
		local maximum = contraband.maximum;
		
		-- Check if a statement is true.
		if (self.OnGetMaximum) then
			maximum = self:OnGetMaximum(player, maximum);
		end;
		
		-- Check if a statement is true.
		if (contraband) then
			if (kuroScript.player.GetPropertyCount(player, self.contraband.uniqueID) == maximum) then
				kuroScript.player.Notify(player, "You have reached this contraband's maximum!");
				
				-- Return false to break the function.
				return false;
			end;
		end;
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);