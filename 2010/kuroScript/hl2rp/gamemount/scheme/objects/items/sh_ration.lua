--[[
Name: "sh_ration.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Ration";
ITEM.cost = 75;
ITEM.model = "models/weapons/w_package.mdl";
ITEM.batch = 1;
ITEM.weight = 2;
ITEM.useText = "Open";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.blacklist = {VOC_CPA_RCT};
ITEM.description = "A purple container, what goodies have they given you this time?";

-- Called when a player attempts to pick up the item.
function ITEM:CanPickup(player, quickUse, itemEntity)
	if (quickUse) then
		if ( !kuroScript.inventory.CanHoldWeight(player, self.weight) ) then
			kuroScript.player.Notify(player, "You do not have enough inventory space!");
			
			-- Return false to break the function.
			return false;
		end;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if ( kuroScript.game:PlayerIsCombine(player) ) then
		kuroScript.player.Notify(player, "The Combine cannot use rations!");
		
		-- Return false to break the function.
		return false;
	elseif (player:QueryCharacter("class") == CLASS_CAD) then
		kuroScript.player.Notify(player, "City Administrators cannot use rations!");
		
		-- Return false to break the function.
		return false;
	else
		if (player:GetData("donator") > 0) then
			kuroScript.player.GiveCurrency(player, 200, "Ration");
		else
			kuroScript.player.GiveCurrency(player, 120, "Ration");
		end;
		
		-- Update the player's inventory.
		kuroScript.inventory.Update(player, "chinese_takeout", 1, true);
		
		-- Call a mount hook.
		kuroScript.mount.Call("PlayerUseRation", player);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);