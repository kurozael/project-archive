--[[
Name: "sh_antidepressants.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Antidepressants";
ITEM.cost = 20;
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl";
ITEM.weight = 0.2;
ITEM.access = "v";
ITEM.useText = "Swallow";
ITEM.category = "Medical";
ITEM.business = true;
ITEM.description = "A tin of pills, don't do drugs!";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetSharedVar("ks_Antidepressants", CurTime() + 600);
	
	-- Boost some of the player's attributes.
	kuroScript.attributes.Boost(player, self.name, ATB_ENDURANCE, 2, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STRENGTH, -2, 120);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);