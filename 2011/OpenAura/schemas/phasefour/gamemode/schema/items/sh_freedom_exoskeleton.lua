--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 7500;
ITEM.name = "Freedom Exoskeleton";
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
ITEM.armorScale = 0.45;
ITEM.replacement = "models/srp/masterfreedom.mdl";
ITEM.hasJetpack = true;
ITEM.description = "A Freedom branded exoskeleton.\nProvides you with 45% bullet resistance.\nProvides you with tear gas protection.";
ITEM.requiresArmadillo = true;
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);