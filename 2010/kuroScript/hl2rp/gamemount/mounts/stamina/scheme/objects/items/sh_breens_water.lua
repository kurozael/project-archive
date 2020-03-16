--[[
Name: "sh_breens_water.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Breen's Water";
ITEM.model = "models/props_junk/popcan01a.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Consumables"
ITEM.description = "A blue aluminium can, it swishes when you shake it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("stamina", 10);
	player:SetHealth( math.Clamp( player:Health() + 4, 0, player:GetMaxHealth() ) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_AGILITY, 1, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STAMINA, 1, 120);
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