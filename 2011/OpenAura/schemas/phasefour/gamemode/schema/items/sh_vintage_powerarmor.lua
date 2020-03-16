--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 11500;
ITEM.name = "Vintage Powerarmor";
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
ITEM.armorScale = 0.75;
ITEM.replacement = "models/nailgunner/slow.mdl";
ITEM.description = "Some Vintage branded powerarmor with extreme resistance.\nProvides you with 75% bullet resistance.\nProvides you with tear gas protection.";
ITEM.hasJetpack = true;
ITEM.tearGasProtection = true;
ITEM.requiresArmadillo = true;

openAura.schema:RegisterLeveledArmor(ITEM);