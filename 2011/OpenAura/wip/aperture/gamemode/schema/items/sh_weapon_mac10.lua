--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "MAC-10";
ITEM.cost = 2400;
ITEM.model = "models/weapons/w_smg_mac10.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.weaponClass = "rcs_mac10";
ITEM.description = "A dirty inaccurate firearm with grey coloring.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.schema:RegisterLeveledWeapon(ITEM);