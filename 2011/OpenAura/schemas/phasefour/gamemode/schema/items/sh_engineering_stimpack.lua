--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Engineering Stimpack";
ITEM.cost = 1250;
ITEM.model = "models/props_c17/trappropeller_lever.mdl";
ITEM.batch = 1;
ITEM.weight = 1;
ITEM.useText = "Inject";
ITEM.category = "Stimpacks"
ITEM.business = true;
ITEM.description = "A Stimpack branded stimulator promising to enhance the body.\nThis stimpack permanently enhances your enginerring by 2%.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:UpdateAttribute(ATB_ENGINEERING, 1);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);