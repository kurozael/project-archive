--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 750;
ITEM.name = "Minigun";
ITEM.model = "models/weapons/w_mach_m249para.mdl";
ITEM.batch = 1;
ITEM.weight = 4;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_m249";
ITEM.description = "A large old and rusted machine gun.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.loweredAngles = Angle(-10, 40, -40);
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);