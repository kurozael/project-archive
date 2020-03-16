
--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = 7000;
ITEM.name = "Hellmerc Gasmask";
ITEM.weight = 3;
ITEM.business = true;
ITEM.runSound = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav",
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav"
};
ITEM.armorScale = 0.425;
ITEM.replacement = "models/napalm_atc/slow.mdl";
ITEM.description = "Some Hellmerc branded armor with a mandatory gasmask.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

Clockwork.item:Register(ITEM);