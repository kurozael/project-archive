--[[
Name: "sh_boxed_bag.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Boxed Bag";
ITEM.cost = 25;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 1;
ITEM.access = "i1";
ITEM.useText = "Open";
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (kuroScript.inventory.HasItem(player, "small_bag") and kuroScript.inventory.HasItem(player, "small_bag") >= 2) then
		kuroScript.player.Notify(player, "You've hit the bags limit!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Update the player's inventory with a new item.
	kuroScript.inventory.Update(player, "small_bag", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);