--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "generator_base";
ITEM.name = "Standard Printer";
ITEM.cost = 10;
ITEM.business = true;
ITEM.blacklist = {CLASS_POLICE, CLASS_DISPENSER, CLASS_RESPONSE, CLASS_PRESIDENT, CLASS_SECRETARY};
ITEM.description = "Generates a steady rate of dollars over time.";

ITEM.generator = {
	powerPlural = "Batteries",
	powerName = "Battery",
	uniqueID = "aura_standardprinter",
	maximum = 2,
	health = 80,
	power = 3,
	cash = 10,
	name = "Standard Printer",
};

openAura.item:Register(ITEM);