--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "CDF MRE";
ITEM.model = "models/weapons/w_package.mdl";
ITEM.weight = 3;
ITEM.useText = "Open";
ITEM.category = "Consumables"
ITEM.description = "A package with 'CDF MEAL READY TO EAT' printed on the side.";
ITEM.useSound = "items/ammocrate_open.wav";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	--[[-------------------------------------------------------------------------
	If we're going to have MRE's. We've gotta have the right type of MRE's.
	--REMOVE COMMENT WHEN/IF SEVERANCE GOES TO SALE--
	---------------------------------------------------------------------------]]
	local MREMenus = {
		[1] = {"mre_menu1_meal", "mre_extras", "mre_menu1_snack"},
		--[2] = {"mre_menu2_meal", "mre_extras", "mre_menu2_snack"},
		--[3] = {"mre_menu3_meal", "mre_extras", "mre_menu3_snack"}
	}

	local ranmenu = table.Random(MREMenus);

	for k, v in pairs(ranmenu) do
		Clockwork.player:Notify(player, "You open the MRE, it appears to have been a Menu " .. k);
		player:GiveItem(v);
	end;
end;
-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);