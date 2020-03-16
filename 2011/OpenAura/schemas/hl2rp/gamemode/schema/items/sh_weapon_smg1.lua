--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "MP7";
ITEM.cost = 200;
ITEM.model = "models/weapons/w_smg1.mdl";
ITEM.weight = 2.5;
ITEM.access = "V";
ITEM.classes = {CLASS_EMP, CLASS_EOW};
ITEM.uniqueID = "weapon_smg1";
ITEM.business = true;
ITEM.description = "A compact weapon coated in a dark grey, it has a convenient handle.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-2, 5, 4);

openAura.item:Register(ITEM);