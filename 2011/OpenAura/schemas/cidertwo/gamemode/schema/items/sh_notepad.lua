--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Notepad";
ITEM.cost = 10;
ITEM.model = "models/props_lab/clipboard.mdl";
ITEM.weight = 0.2;
ITEM.classes = {CLASS_MERCHANT};
ITEM.useText = "Edit";
ITEM.business = true;
ITEM.category = "Reusables";
ITEM.description = "A clean and professional notepad with a cardboard backing.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	openAura:StartDataStream(player, "Notepad", player:GetCharacterData("notepad") or "");
	
	openAura.player:SetMenuOpen(player, false);
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);