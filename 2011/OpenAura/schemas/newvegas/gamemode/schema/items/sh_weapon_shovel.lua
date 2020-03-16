--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 110;
ITEM.name = "Shovel";
ITEM.model = "models/weapons/w_shovel.mdl";
ITEM.batch = 1;
ITEM.weight = 1.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.category = "Melee";
ITEM.weaponClass = "aura_shovel";
ITEM.description = "A metal shovel, it is really heavy and powerful.";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 255, 0);
ITEM.attachmentOffsetVector = Vector(5, 5, -8);

openAura.item:Register(ITEM);