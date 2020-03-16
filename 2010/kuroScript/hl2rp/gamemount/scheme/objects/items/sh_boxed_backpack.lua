--[[
Name: "sh_boxed_backpack.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Boxed Backpack";
ITEM.cost = 40;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 2;
ITEM.access = "i1";
ITEM.useText = "Open";
ITEM.category = "Perpetuities"
ITEM.business = true;
ITEM.vocations = {VOC_CPA_EPU, VOC_OTA_OWC};
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (kuroScript.inventory.HasItem(player, "backpack") and kuroScript.inventory.HasItem(player, "backpack") >= 1) then
		kuroScript.player.Notify(player, "You've hit the backpacks limit!");
		
		-- Return false to break the function.
		return false;
	end;
	
	-- Update the player's inventory with a new item.
	kuroScript.inventory.Update(player, "backpack", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);