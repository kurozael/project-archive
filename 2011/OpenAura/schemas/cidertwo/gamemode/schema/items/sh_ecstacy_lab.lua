--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "generator_base";
ITEM.name = "Ecstacy Lab";
ITEM.cost = 100;
ITEM.model = "models/props_lab/reciever01a.mdl";
ITEM.classes = {CLASS_HUSTLER};
ITEM.category = "Drug Labs";
ITEM.business = true;
ITEM.description = "Manufactures a temporary flow of ecstacy.";

ITEM.generator = {
	powerPlural = "Lifetime",
	powerName = "Lifetime",
	uniqueID = "aura_ecstacylab",
	maximum = 2,
	health = 100,
	power = 5,
	cash = 0,
	name = "Ecstacy Lab",
};

openAura.item:Register(ITEM);