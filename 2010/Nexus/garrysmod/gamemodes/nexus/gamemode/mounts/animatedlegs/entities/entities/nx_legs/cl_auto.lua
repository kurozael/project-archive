--[[
Name: "cl_auto.lua".
Product: "nexus".
--]]

NEXUS:IncludePrefixed("sh_auto.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	function self:BuildBonePositions(bones, physicsBones)
		local boneTable = {"ValveBiped.Head", "ValveBiped.Bip01_Head1"};
		local model = self:GetModel();
		
		if ( !self:GetOwner():InVehicle() ) then
			boneTable = {
				"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine",
				"ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4",
				"ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_UpperArm",
				"ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Forearm",
				"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Clavicle"
			};
			
			if ( string.find(model, "vortigaunt") ) then
				boneTable[#boneTable + 1] = "ValveBiped.Head";
			end;
		else
			boneTable = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine"};
			
			if ( string.find(model, "vortigaunt") ) then
				boneTable[#boneTable + 1] = "ValveBiped.Head";
				boneTable[#boneTable + 1] = "ValveBiped.Neck1";
				boneTable[#boneTable + 1] = "ValveBiped.Neck2";
				boneTable[#boneTable + 1] = "ValveBiped.Spine1";
				boneTable[#boneTable + 1] = "ValveBiped.Spine2";
				boneTable[#boneTable + 1] = "ValveBiped.Spine3";
				boneTable[#boneTable + 1] = "ValveBiped.Spine4";
			end;
		end;
		
		for k, v in pairs(boneTable) do
			local bone = self:LookupBone(v);
			local matrix = self:GetBoneMatrix(bone);
			
			if (bone) then
				matrix:Scale( Vector(0, 0, 0) );
				self:SetBoneMatrix(bone, matrix);
			end;
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	local viewEntityClass = GetViewEntity():GetClass();
	local owner = self:GetOwner();
	
	if (!IsValid(owner) or g_LocalPlayer != owner) then
		return;
	end;
	
	local moveType = owner:GetMoveType();
	local moveTest = (moveType != MOVETYPE_OBSERVER and moveType != 0);
	local position = owner:GetPos();
	local angles = owner:GetRenderAngles();
	
	if ( !moveTest or viewEntityClass == "gmod_cameraprop"
	or nexus.mount.Call("ShouldDrawLocalPlayer") ) then
		return;
	end;
	
	self:SetAngles(angles);
	
	if ( !owner:InVehicle() ) then
		self:SetPos( position + ( angles:Forward() * -16 ) );
	elseif ( IsValid( owner:GetVehicle() ) ) then
		if ( nexus.entity.IsChairEntity( owner:GetVehicle() ) ) then
			self:SetPos( position + ( angles:Forward() * -8 ) );
		else
			self:SetPos(position);
		end;
	else
		self:SetPos( position + ( angles:Forward() * -8 ) );
	end;
	
	if ( owner:InVehicle() and IsValid( owner:GetVehicle() ) ) then
		if (GetConVarNumber("gmod_vehicle_viewmode") != 1) then
			if ( nexus.entity.IsChairEntity( owner:GetVehicle() ) ) then
				if (owner:EyeAngles().yaw > -180 and owner:EyeAngles().yaw < 180) then
					if (owner:EyeAngles().pitch > 12) then
						self:DrawModel();
					end;
				elseif (owner:EyeAngles().pitch > 32) then
					self:DrawModel();
				end;
			elseif ( nexus.entity.IsPodEntity( owner:GetVehicle() ) ) then
				if (owner:EyeAngles().yaw > -180 and owner:EyeAngles().yaw < 180) then
					self:DrawModel();
				elseif (owner:EyeAngles().pitch > 83) then
					self:DrawModel();
				end;
			elseif (owner:EyeAngles().yaw > -180 and owner:EyeAngles().yaw < 180) then
				self:DrawModel();
			elseif (owner:EyeAngles().pitch > 6) then
				self:DrawModel();
			end;
		end;
	else
		if (owner:EyeAngles().pitch > 55) then
			self:DrawModel();
		end;
	end;
end;

-- Called when the entity should draw translucent.
function ENT:DrawTranslucent()
	self:Draw();
end;