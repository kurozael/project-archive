--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("custom_clothes");
	ITEM.name = "C.D.F Uniform";
	ITEM.weight = 2;
	ITEM.iconModel = "models/cedaops/ceda_op2.mdl";
	ITEM.protection = 0.4;
	ITEM.description = "A tactical uniform with a mandatory gas-mask and a C.D.F insignia on the sleeve.";
	ITEM.replacement = "models/cedaops/ceda_op2.mdl";
	ITEM.pocketSpace = 2;
	ITEM.runSound = {
		"npc/metropolice/gear1.wav",
		"npc/metropolice/gear2.wav",
		"npc/metropolice/gear3.wav",
		"npc/metropolice/gear4.wav",
		"npc/metropolice/gear5.wav",
		"npc/metropolice/gear6.wav"
	};
Clockwork.item:Register(ITEM);