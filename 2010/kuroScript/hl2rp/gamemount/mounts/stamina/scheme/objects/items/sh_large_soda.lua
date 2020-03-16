--[[
Name: "sh_large_soda.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Large Soda";
ITEM.cost = 15;
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl";
ITEM.weight = 1.5;
ITEM.access = "v";
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A plastic bottle, it's fairly big and filled with liquid.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 100);
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_AGILITY, 5, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STAMINA, 5, 120);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item's functions should be edited.
function ITEM:OnEditFunctions(functions)
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer, false) ) then
		for k, v in pairs(functions) do
			if (v == "Drink") then functions[k] = nil; end;
		end;
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);