--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Baseball Cap";
ITEM.cost = 20;
ITEM.model = "models/props/de_tides/vending_hat.mdl";
ITEM.weight = 0.25;
ITEM.business = true;
ITEM.access = "v";
ITEM.btach = 1;
ITEM.category = "Accessories";
ITEM.uniqueID = "baseballcap";
ITEM.description = "A baseball cap depicting your love for a cartoon turtle.";
ITEM.isAttachment = true;

ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentOffsetAngles = Angle(180, 270, 0);
ITEM.attachmentOffsetVector = Vector(0, 1, 3);

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetVector = Vector(0, 1, 1.75);
	end;
end;

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
--	if ( string.find(player:GetModel(), "group%d%d") ) then
		if ( player:GetSharedVar("baseballCap") ) then
			return true;
		end;
--	end;
end;

-- Called when the item's local amount is needed.
function ITEM:GetLocalAmount(amount)
	if ( Clockwork.Client:GetSharedVar("baseballCap") ) then
		return amount - 1;
	else
		return amount;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, arguments)
	return player:GetSharedVar("baseballCap");
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, arguments)
	local baseballCapGear = Clockwork.player:GetGear(player, "baseballCap");
	
	if ( player:GetSharedVar("baseballCap") and IsValid(baseballCapGear) ) then
		player:SetCharacterData("baseballCap", nil);
		player:SetSharedVar("baseballCap", false);
		player:SetSharedVar("wearingHat", false);
		
		if ( IsValid(baseballCapGear) ) then
			baseballCapGear:Remove();
		end;
	end;
	
	player:UpdateInventory(self.uniqueID);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if ( player:GetSharedVar("baseballCap") ) then
		if (player:HasItem(self.uniqueID) == 1) then
			Clockwork.player:Notify(player, "You cannot drop this while you are wearing it!");
			
			return false;
		end;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if ( player:Alive() and !player:IsRagdolled() ) then
		if ( !player:GetSharedVar("wearingHat") ) then
			Clockwork.player:CreateGear(player, "baseballCap", self);
		
			player:SetCharacterData("baseballCap", true);
			player:SetSharedVar("baseballCap", true);
			player:SetSharedVar("wearingHat", true);

			player:UpdateInventory(self.uniqueID);
		
			if (itemEntity) then
			return true;
			end;
		end;
	else
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
	
	return false;
end;

ITEM:Register();