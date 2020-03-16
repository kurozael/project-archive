--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("generator_base");
ITEM.name = "Heroin Lab";
ITEM.cost = 120;
ITEM.model = "models/props_lab/reciever01a.mdl";
ITEM.classes = {CLASS_HUSTLER};
ITEM.category = "Drug Labs";
ITEM.business = true;
ITEM.description = "Manufactures a temporary flow of heroin.";

--[[
	Set up the generator information. This
	data is given to the Clockwork.generator library.
--]]
ITEM.generatorInfo = {
	powerPlural = "Lifetime",
	powerName = "Lifetime",
	uniqueID = "cw_heroin_lab",
	maximum = 2,
	health = 100,
	power = 5,
	cash = 0,
	name = "Heroin Lab",
};

Clockwork.item:Register(ITEM);