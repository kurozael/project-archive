--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Christmas Hat";
ITEM.model = "models/props/cs_office/Snowman_face.mdl";
ITEM.category = "Festivities";
ITEM.description = "This festive mask brings out the jolly in you.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentModelScale = Vector(1, 1, 1);
ITEM.attachmentOffsetAngles = Angle(180, 270, 0);
ITEM.attachmentOffsetVector = Vector(0, 3, 3);

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetVector = Vector(0, 3, 1.75);
	end;
end;

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	return true;
end;

openAura.item:Register(ITEM);