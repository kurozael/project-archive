--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Famas";
	ITEM.cost = 1200;
	ITEM.model = "models/weapons/w_rif_famas.mdl";
	ITEM.weight = 3;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.business = true;
	ITEM.uniqueID = "rcs_famas";
	ITEM.description = "An average sized grey rifle with a big magazine.\nThis firearm utilises 5.56x45mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
Clockwork.item:Register(ITEM);