--[[
Name: "sh_ammo_base.lua".
Product: "kuroScript".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Ammo Base";
ITEM.useText = "Load";
ITEM.useSound = false;
ITEM.category = "Ammo";
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 0;
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:GiveAmmo(self.ammoAmount, self.ammoClass);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);