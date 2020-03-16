--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Skull Mask";
ITEM.cost = 20;
ITEM.model = "models/gibs/hgibs.mdl";
ITEM.weight = 0.25;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.category = "Reusables";
ITEM.description = "A skull mask that can conceal your identity while wearing it.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentOffsetAngles = Angle(270, 270, 0);
ITEM.attachmentOffsetVector = Vector(0, 3, 3);

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if (string.find(player:GetModel(), "female")) then
		info.offsetVector = Vector(0, 3, 1.75);
	end;
end;

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	if (player:GetSharedVar("SkullMask")) then
		return true;
	end;
end;

-- Called when the item's local amount is needed.
function ITEM:GetLocalAmount(amount)
	if (Clockwork.Client:GetSharedVar("SkullMask")) then
		return amount - 1;
	else
		return amount;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return (player:GetSharedVar("SkullMask") == self("itemID"));
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	local skullMaskGear = Clockwork.player:GetGear(player, "SkullMask");
	
	if (player:GetSharedVar("SkullMask") and IsValid(skullMaskGear)) then
		player:SetCharacterData("SkullMask", nil);
		player:SetSharedVar("SkullMask", 0);
		
		if (IsValid(skullMaskGear)) then
			skullMaskGear:Remove();
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetSharedVar("SkullMask")  == self("itemID")) then
		Clockwork.player:Notify(player, "You cannot drop this while you are wearing it!");
		
		return false;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		Clockwork.player:CreateGear(player, "SkullMask", self);
		
		player:SetCharacterData("SkullMask", self("itemID"));
		player:SetSharedVar("SkullMask", self("itemID"));
		
		if (itemEntity) then
			return true;
		end;
	else
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
	
	return false;
end;

Clockwork.item:Register(ITEM);