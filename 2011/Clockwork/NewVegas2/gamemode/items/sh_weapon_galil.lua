--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 525;
	ITEM.name = "Assault Rifle";
	ITEM.model = "models/weapons/w_rif_galil.mdl";
	ITEM.batch = 1;
	ITEM.weight = 3;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.weaponClass = "rcs_galil";
	ITEM.description = "An averaged sized firearm with an orange tint.\nThis firearm utilises 5.56x45mm ammunition.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(20, 70, 15);
	ITEM.attachmentOffsetVector = Vector(10, 0, -8);
Clockwork.item:Register(ITEM);