--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 525;
ITEM.name = ".32 Hunting Rifle";
ITEM.model = "models/weapons/w_remingt.mdl";
ITEM.batch = 1;
ITEM.weight = 4;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "rcs_remington";
ITEM.description = "A dirty hunting rifle with a brown grip.\nThis firearm utilises .357 ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);