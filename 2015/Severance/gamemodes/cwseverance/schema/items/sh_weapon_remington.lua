--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Remington 570";
	ITEM.model = "models/weapons/w_remingt.mdl";
	ITEM.weight = 3;
	ITEM.uniqueID = "weapon_remington570";
	ITEM.weaponClass = "bs_rem";
	ITEM.description = "A worn pump feed shotgun with a nice wood stock.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = false;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.loweredOrigin = Vector(3, 0, -4);
	ITEM.loweredAngles = Angle(0, 45, 0);
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);