--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.cost = 80;
ITEM.name = "Crowbar";
ITEM.model = "models/weapons/w_crowbar.mdl";
ITEM.batch = 1;
ITEM.weight = 1;
ITEM.access = "T";
ITEM.business = true;
ITEM.category = "Melee";
ITEM.business = true;
ITEM.description = "A scratched up and dirty metal crowbar.";
ITEM.weaponClass = "aura_crowbar";
ITEM.meleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-18, -5, 5);
ITEM.loweredAngles = Angle(-10, 10, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(200, 200, 0);
ITEM.attachmentOffsetVector = Vector(0, 5, 2);

openAura.item:Register(ITEM);