--[[
	� 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "Laser Rifle";
ITEM.cost = (7000 * 0.5);
ITEM.model = "models/weapons/w_rif_famas.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.weaponClass = "cw_laserrifle";
ITEM.description = "An averaged sized weapon powered by laser technology.\nThis firearm utilises Energy ammunition.";
ITEM.isAttachment = true;
ITEM.loweredAngles = Angle(0, 50, -30);
ITEM.loweredOrigin = Vector(0, 0, -6);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

Clockwork.item:Register(ITEM);