--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 13000;
ITEM.name = "Silicon Powerarmor";
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
ITEM.armorScale = 0.8;
ITEM.replacement = "models/nailgunner/silc.mdl";
ITEM.description = "Some Silicon branded powerarmor with extreme resistance.\nProvides you with 80% bullet resistance.\nProvides you with tear gas protection.";
ITEM.hasJetpack = true;
ITEM.tearGasProtection = true;
ITEM.requiresArmadillo = true;

openAura.schema:RegisterLeveledArmor(ITEM);