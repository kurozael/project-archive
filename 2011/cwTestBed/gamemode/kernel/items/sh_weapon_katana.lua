--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "Katana";
ITEM.cost = 600;
ITEM.model = "models/weapons/w_katana.mdl";
ITEM.weight = 1.25;
ITEM.business = true;
ITEM.category = "Weapons";
ITEM.weaponClass = "cw_katana";
ITEM.description = "A long japanese katana which deals Godly damage.";
ITEM.isMeleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(90, 180, 20);
ITEM.attachmentOffsetVector = Vector(0, 6, 0);

Clockwork.item:Register(ITEM);