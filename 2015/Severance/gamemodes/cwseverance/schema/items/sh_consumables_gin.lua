--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("alcohol_base");
	ITEM.name = "Gin";
	ITEM.model = "models/props_junk/glassjug01.mdl";
	ITEM.weight = 1;
	ITEM.attributes = {Strength = 2};
	ITEM.category = "Consumables"
	ITEM.description = "A clear glass bottle filled with liquid, it has a funny smell.";
	ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav";
	ITEM.ThirstAmount = 10;
	ITEM.EnergyAmount = -10;
Clockwork.item:Register(ITEM);