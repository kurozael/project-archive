--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "LPR-207X";
ITEM.cost = 7000;
ITEM.model = "models/weapons/w_rif_famas.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.weaponClass = "aura_laserrifle";
ITEM.description = "An averaged sized weapon powered by laser technology.\nThis firearm utilises X36-9mm ammunition.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.loweredAngles = Angle(0, 50, -30);
ITEM.loweredOrigin = Vector(0, 0, -6);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.schema:RegisterLeveledWeapon(ITEM);