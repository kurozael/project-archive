--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = 8000;
ITEM.name = "Stalker Exoskeleton";
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
ITEM.armorScale = 0.475;
ITEM.replacement = "models/srp/masterstalker.mdl";
ITEM.description = "A Stalker branded exoskeleton.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

Clockwork.item:Register(ITEM);