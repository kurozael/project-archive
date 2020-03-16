--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "M16A4";
	ITEM.model = "models/weapons/w_rif_m4a1.mdl";
	ITEM.weight = 3;
	ITEM.uniqueID = "weapon_m4a1";
	ITEM.weaponClass = "bs_m4a1";
	ITEM.description = "A worn, military grade M16 rifle.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = false;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);