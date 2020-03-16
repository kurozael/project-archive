--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 9500;
ITEM.name = "Duty Exoskeleton";
ITEM.weight = 4;
ITEM.business = true;
ITEM.runSound = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav",
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav"
};
ITEM.armorScale = 0.55;
ITEM.replacement = "models/srp/masterduty.mdl";
ITEM.hasJetpack = true;
ITEM.description = "A Duty branded exoskeleton.\nProvides you with 55% bullet resistance.\nProvides you with tear gas protection.";
ITEM.requiresArmadillo = true;
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);