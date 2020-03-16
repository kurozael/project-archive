--[[
Name: "sh_canned_beans.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Canned Beans";
ITEM.cost = 5;
ITEM.model = "models/props_lab/jar01b.mdl";
ITEM.weight = 0.6;
ITEM.access = "v";
ITEM.useText = "Eat";
ITEM.classes = {CLASS_CPA};
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A tinned can, it slushes when you shake it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + 5, 0, player:GetMaxHealth() ) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_ENDURANCE, 1, 120);
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