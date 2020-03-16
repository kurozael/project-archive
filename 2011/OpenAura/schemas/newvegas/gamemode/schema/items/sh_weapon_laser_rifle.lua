--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "Laser Rifle";
ITEM.cost = 700;
ITEM.model = "models/weapons/w_rif_famas.mdl";
ITEM.batch = 1;
ITEM.weight = 3;
ITEM.access = "T";
ITEM.business = true;
ITEM.weaponClass = "aura_laserrifle";
ITEM.description = "An averaged sized weapon powered by laser technology.\nThis firearm utilises Energy Cell ammunition.";
ITEM.isAttachment = true;
ITEM.loweredAngles = Angle(0, 50, -30);
ITEM.loweredOrigin = Vector(0, 0, -6);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.weaponCopiesItem = true;
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);