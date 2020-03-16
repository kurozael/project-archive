
--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 7000;
ITEM.name = "Bluemerc Gasmask";
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
ITEM.replacement = "models/napalm_atc/blue.mdl";
ITEM.description = "Some Bluemerc branded armor with a mandatory gasmask.\nProvides you with 42.5% bullet resistance.\nProvides you with tear gas protection.";
ITEM.hasJetpack = true;
ITEM.tearGasProtection = true;
ITEM.requiresArmadillo = true;

openAura.schema:RegisterLeveledArmor(ITEM);