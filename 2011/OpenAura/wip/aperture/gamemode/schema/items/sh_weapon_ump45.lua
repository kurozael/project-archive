--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "UMP9";
ITEM.cost = 3750;
ITEM.model = "models/weapons/w_smg_ump45.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.weaponClass = "rcs_ump";
ITEM.description = "A dark grey firearm with a large magazine.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.schema:RegisterLeveledWeapon(ITEM);