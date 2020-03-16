--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Advanced Printer";
ITEM.cost = 20;
ITEM.model = "models/props_c17/cashregister01a.mdl";
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
	uniqueID = "cw_printer_advanced",
	maximum = 1,
	health = 160,
	power = 4,
	cash = 10,
	name = "Advanced Printer",
};

Clockwork.item:Register(ITEM);