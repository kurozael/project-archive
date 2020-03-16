--[[
Name: "cl_autorun.lua".
Product: "kuroScript".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Called when the entity initializes.
function ENT:Initialize()
	function self:BuildBonePositions(bones, physicsBones)
		local boneTable = {"ValveBiped.Bip01_Head1"};
		
		-- Check if a statement is true.
		if ( !self:GetOwner():InVehicle() ) then
			boneTable = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Clavicle", "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Clavicle"};
		else
			boneTable = {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1", "ValveBiped.Bip01_Spine"};
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(boneTable) do
			local bone = self:LookupBone(v);
			local matrix = self:GetBoneMatrix(bone);
			
			-- Scale the bone matrix.
			matrix:Scale( Vector(0, 0, 0) ); self:SetBoneMatrix(bone, matrix);
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	local owner = self:GetOwner();
	
	-- Check if a statement is true.
	if ( ValidEntity( owner ) ) then
		local moveType = owner:GetMoveType();
		
		-- Check if a statement is true.
		if (g_LocalPlayer == owner and GetViewEntity():GetClass() != "gmod_cameraprop") then
			if (moveType != MOVETYPE_OBSERVER and moveType != 0) then
				if ( owner:InVehicle() ) then
					if (GetConVarNumber("gmod_vehicle_viewmode") != 1) then
						if ( ValidEntity( owner:GetVehicle() ) ) then
							if ( kuroScript.entity.IsChairEntity( owner:GetVehicle() ) ) then
								if (owner:EyeAngles().yaw > -180 and owner:EyeAngles().yaw < 180) then
									if (owner:EyeAngles().pitch > 12) then
										self:DrawModel();
									end;
								elseif (owner:EyeAngles().pitch > 32) then
									self:DrawModel();
								end;
							elseif ( kuroScript.entity.IsPodEntity( owner:GetVehicle() ) ) then
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
						else
							self:DrawModel();
						end;
					end;
				elseif (owner:EyeAngles().pitch > 55) then
					self:DrawModel();
				end;
			end;
		end;
	end;
end;

-- Called when the entity should draw translucent.
function ENT:DrawTranslucent() self:Draw(); end;

-- Called each frame.
function ENT:Think() end;