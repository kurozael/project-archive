--[[
Name: "sh_melon.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Melon";
ITEM.cost = 10;
ITEM.model = "models/props_junk/watermelon01.mdl";
ITEM.weight = 1;
ITEM.access = "v";
ITEM.useText = "Eat";
ITEM.classes = {CLASS_CPA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A green fruit, it has a hard outer shell.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_ACROBATICS, 2, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_AGILITY, 2, 120);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item's functions should be edited.
function ITEM:OnEditFunctions(functions)
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer, false) ) then
		for k, v in pairs(functions) do
			if (v == "Eat") then functions[k] = nil; end;
		end;
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);