--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Glock";
ITEM.model = "models/weapons/w_pist_glock18.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "weapon_glock";
ITEM.weaponClass = "rcs_glock";
ITEM.description = "A small, dirty pistol with something engraved into the side.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

openAura.item:Register(ITEM);