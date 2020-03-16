--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua");

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetNotSolid(true);
	self:DrawShadow(false);
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- A function to get whether the entity should exist.
function ENT:GetShouldExist(player)
	local itemTable = self:GetItem();
	
	if (itemTable) then
		if (itemTable.GetAttachmentExists) then
			return itemTable:GetAttachmentExists(player, self);
		elseif ( openAura.item:IsWeapon(itemTable) ) then
			if ( player:IsRagdolled() ) then
				return player:RagdollHasWeapon(itemTable.weaponClass);
			else
				return player:HasWeapon(itemTable.weaponClass);
			end;
		else
			return true;
		end;
	end;
end;

-- A function to get whether the entity is visible.
function ENT:GetIsVisible(player)
	local itemTable = self:GetItem();
	
	if (itemTable) then
		if (itemTable.GetAttachmentVisible) then
			return itemTable:GetAttachmentVisible(player, self);
		elseif ( openAura.item:IsWeapon(itemTable) ) then
			return openAura.player:GetWeaponClass(player) != itemTable.weaponClass;
		else
			return true;
		end;
	end;
end;

-- A function to set the entity's item.
function ENT:SetItem(itemTable)
	self:SetDTInt("index", itemTable.index);
end;

-- Called each frame.
function ENT:Think()
	local player = self:GetPlayer();
	
	if ( IsValid(player) and self:GetShouldExist(player) ) then
		local pr, pg, pb, pa = player:GetColor();
		local er, eg, eb, ea = self:GetColor();
		
		if ( !self:GetIsVisible(player) ) then
			self:SetColor(255, 255, 255, 0);
			self:SetNoDraw(true);
		else
			self:SetColor(er, eg, eb, pa);
			self:SetNoDraw(false);
		end;
		
		self:SetMaterial( player:GetMaterial() );
	else
		self:Remove();
	end;
end;