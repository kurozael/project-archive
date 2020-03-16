--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("sh_init.lua")

-- Called each frame.
function ENT:Think()
	local playerEyePos = openAura.Client:EyePos();
	local player = self:GetPlayer();
	local eyePos = EyePos();
	
	if ( IsValid(player) ) then
		local isPlayer = player:IsPlayer();
		
		if ( (eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != openAura.Client
		or openAura.Client != player or !isPlayer) and ( !isPlayer or player:Alive() ) ) then
			self:SetNoDraw(false);
		else
			self:SetNoDraw(true);
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	local playerEyePos = openAura.Client:EyePos();
	local r, g, b, a = self:GetColor();
	local modelScale = Vector();
	local itemTable = self:GetItem();
	local eyePos = EyePos();
	local player = self:GetPlayer();
	
	if (itemTable and itemTable.attachmentModelScale) then
		modelScale = itemTable.attachmentModelScale;
	end;
	
	if ( IsValid(player) and ( player:GetMoveType() == MOVETYPE_WALK or player:IsRagdolled() or player:InVehicle() ) ) then
		local position, angles = self:GetRealPosition();
		local isPlayer = player:IsPlayer();
		
		if (position and angles) then
            self:SetPos(position);
            self:SetAngles(angles);
			
			if (itemTable and itemTable.GetAttachmentModelScale) then
				local newModelScale = itemTable:GetAttachmentModelScale(player, self);
				
				if (newModelScale) then
					modelScale = newModelScale;
				end;
			end;
			
			if ( (eyePos:Distance(playerEyePos) > 32 or GetViewEntity() != openAura.Client
			or openAura.Client != player or !isPlayer) and ( !isPlayer or player:Alive() ) ) then
				self:SetModelScale(modelScale);
				
				if (a > 0) then
					self:DrawModel();
				end;
			end;
		end;
	end;
	
	self:SetModelScale( Vector() );
end;