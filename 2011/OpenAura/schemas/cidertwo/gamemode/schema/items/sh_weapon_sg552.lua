--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "SG-552";
ITEM.cost = 1300;
ITEM.model = "models/weapons/w_rif_sg552.mdl";
ITEM.weight = 4;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.uniqueID = "rcs_sg552";
ITEM.description = "A moderately sized assault rifle with a scope.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);