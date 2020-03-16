--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Desert Eagle";
	ITEM.model = "models/weapons/w_pist_deagle.mdl";
	ITEM.weight = 1.5;
	ITEM.uniqueID = "bs_deagle";
	ITEM.description = "A bulky silver pistol that packs a lot of punch.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
	ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);
Clockwork.item:Register(ITEM);