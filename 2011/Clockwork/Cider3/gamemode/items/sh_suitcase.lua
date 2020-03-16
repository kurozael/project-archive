--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("weapon_base");
ITEM.name = "Suitcase";
ITEM.cost = 10;
ITEM.model = "models/weapons/w_suitcase_passenger.mdl";
ITEM.weight = 2;
ITEM.classes = {CLASS_MERCHANT};
ITEM.category = "Reusables";
ITEM.uniqueID = "cw_suitcase";
ITEM.business = true;
ITEM.isMeleeWeapon = true;
ITEM.description = "It doesn't do anything, but it looks cool, right?";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_R_Hand";
ITEM.attachmentOffsetAngles = Angle(0, 90, -10);
ITEM.attachmentOffsetVector = Vector(0, 0, 4);

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	return (Clockwork.player:GetWeaponClass(player) == self("weaponClass"));
end;

Clockwork.item:Register(ITEM);