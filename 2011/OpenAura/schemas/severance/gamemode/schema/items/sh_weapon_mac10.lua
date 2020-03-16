--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "MAC-10";
ITEM.model = "models/weapons/w_smg_mac10.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "weapon_mac10";
ITEM.weaponClass = "rcs_mac10";
ITEM.description = "A dirty light grey weapon with something engraved into the side.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.item:Register(ITEM);