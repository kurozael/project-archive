--[[
	� 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("alcohol_base");
	ITEM.name = "Beer";
	ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl";
	ITEM.weight = 0.6;
	ITEM.attributes = {Strength = 2};
	ITEM.category = "Consumables"
	ITEM.description = "A glass bottle filled with liquid, it has a funny smell.";
	ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav";
	ITEM.ThirstAmount = 10
	ITEM.EnergyAmount = -5
	ITEM.HungerAmount = 0
Clockwork.item:Register(ITEM);