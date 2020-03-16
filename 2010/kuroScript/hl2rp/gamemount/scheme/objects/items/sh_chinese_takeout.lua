--[[
Name: "sh_chinese_takeout.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Chinese Takeout";
ITEM.cost = 10;
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.weight = 0.8;
ITEM.access = "v";
ITEM.useText = "Eat";
ITEM.classes = {CLASS_CPA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A takeout carton, it's filled with cold noodles.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_ENDURANCE, 2, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_ACCURACY, 1, 120);
end;

-- Called when the item's functions should be edited.
function ITEM:OnEditFunctions(functions)
	if ( kuroScript.game:PlayerIsCombine(g_LocalPlayer, false) ) then
		for k, v in pairs(functions) do
			if (v == "Eat") then functions[k] = nil; end;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);