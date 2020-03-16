--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "CDF MRE: Matches";
ITEM.model = "models/props_lab/box01a.mdl";
ITEM.weight = 0.1;
ITEM.useText = "Light";
ITEM.uniqueID = "mre_matches"
ITEM.category = "Consumables"
ITEM.description = "A small pack of 24 matches.";
--ITEM.useSound = "items/ammocrate_open.wav"; --TODO: FIND MATCH SOUND, OR SOMETHING SIMILAR FROM THE HL2 SOUND LIBRARY

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
--[[-------------------------------------------------------------------------
TODO: MATCHES FUNCTIONALITY WITH 'CAMPFIRE'
---------------------------------------------------------------------------]]
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);