--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.name = "C.E.D.A. Uniform";
ITEM.weight = 2;
ITEM.iconModel = "models/pmc/pmc_4/pmc__07.mdl";
ITEM.protection = 0.4;
ITEM.description = "A tactical uniform with a mandatory gas-mask and a C.E.D.A. insignia on the sleeve.";
ITEM.replacement = "models/pmc/pmc_4/pmc__07.mdl";
ITEM.pocketSpace = 2;

openAura.item:Register(ITEM);