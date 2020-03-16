--[[
Name: "sh_kevlar.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Kevlar";
ITEM.cost = 75;
ITEM.model = "models/props_c17/suitcase_passenger_physics.mdl";
ITEM.weight = 3;
ITEM.access = "V";
ITEM.useText = "Wear";
ITEM.classes = {CLASS_CPA, CLASS_OTA};
ITEM.category = "Clothing";
ITEM.business = true;
ITEM.blacklist = {VOC_CPA_RCT};
ITEM.description = "A well stitched fabric, it's very heavy.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetArmor( math.Clamp( player:Armor() + 100, 0, player:GetMaxArmor() ) );
	
	-- Boost the player's attribute.
	kuroScript.attributes.Boost(player, self.name, ATB_DEXTERITY, 5, 120);
	kuroScript.attributes.Boost(player, self.name, ATB_STRENGTH, 5, 120);
	
	-- Progress the player's attribute.
	kuroScript.attributes.Progress(player, ATB_DEXTERITY, 2.5, true);
	kuroScript.attributes.Progress(player, ATB_STRENGTH, 2, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);