
--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = (7000 * 0.5);
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
ITEM.armorScale = 0.275;
ITEM.replacement = "models/napalm_atc/blue.mdl";
ITEM.description = "Some Bluemerc branded armor with a mandatory gasmask.";
ITEM.tearGasProtection = true;

Clockwork.item:Register(ITEM);