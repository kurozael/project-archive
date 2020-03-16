--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 550;
ITEM.name = "Chinese Assault Rifle";
ITEM.model = "models/weapons/w_rif_ak47.mdl";
ITEM.batch = 1;
ITEM.weight = 3;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_ak47";
ITEM.description = "A rusted grey and brown rifle.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);