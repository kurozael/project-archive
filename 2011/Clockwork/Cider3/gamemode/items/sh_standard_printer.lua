--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Standard Printer";
ITEM.cost = 10;
ITEM.business = true;
ITEM.blacklist = {CLASS_POLICE, CLASS_DISPENSER, CLASS_RESPONSE, CLASS_PRESIDENT, CLASS_SECRETARY};
ITEM.description = "Generates a steady rate of dollars over time.";

--[[
	Set up the generator information. This
	data is given to the Clockwork.generator library.
--]]
ITEM.generatorInfo = {
	powerPlural = "Batteries",
	powerName = "Battery",
	uniqueID = "cw_printer_standard",
	maximum = 2,
	health = 80,
	power = 3,
	cash = 10,
	name = "Standard Printer",
};

Clockwork.item:Register(ITEM);