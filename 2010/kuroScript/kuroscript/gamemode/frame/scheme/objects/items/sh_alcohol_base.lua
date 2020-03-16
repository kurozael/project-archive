--[[
Name: "sh_alcohol_base.lua".
Product: "kuroScript".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Alcohol Base";
ITEM.useText = "Drink";
ITEM.category = "Alcohol";
ITEM.expireTime = 120;
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self.attributes) then
		for k, v in pairs(self.attributes) do
			kuroScript.attributes.Boost(player, self.name, k, v, self.expireTime);
		end;
	end;
	
	-- Set some information.
	kuroScript.player.SetDrunk(player, self.expireTime);
	
	-- Check if a statement is true.
	if (self.OnDrink) then
		self:OnDrink(player);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);