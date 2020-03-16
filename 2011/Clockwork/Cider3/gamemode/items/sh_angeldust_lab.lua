--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Angel Dust Lab";
ITEM.cost = 130;
ITEM.model = "models/props_lab/reciever01a.mdl";
ITEM.classes = {CLASS_HUSTLER};
ITEM.category = "Drug Labs";
ITEM.business = true;
ITEM.description = "Manufactures a temporary flow of angel dust.";

--[[
	Set up the generator information. This
	data is given to the Clockwork.generator library.
--]]
ITEM.generatorInfo = {
	powerPlural = "Lifetime",
	powerName = "Lifetime",
	uniqueID = "cw_angeldust_lab",
	maximum = 2,
	health = 100,
	power = 5,
	cash = 0,
	name = "Angel Dust Lab",
};

Clockwork.item:Register(ITEM);