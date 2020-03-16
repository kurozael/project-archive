--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "AUG";
ITEM.cost = 5000;
ITEM.model = "models/weapons/w_rif_aug.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.weaponClass = "rcs_aug";
ITEM.description = "A scoped firearm with a light tan.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

Clockwork.item:Register(ITEM);