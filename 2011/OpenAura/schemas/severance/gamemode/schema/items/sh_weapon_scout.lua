--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Scout";
ITEM.model = "models/weapons/w_snip_scout.mdl";
ITEM.weight = 4;
ITEM.uniqueID = "weapon_scout";
ITEM.weaponClass = "rcs_scout";
ITEM.description = "A long grey sniper rifle for attacking at long range distances.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);