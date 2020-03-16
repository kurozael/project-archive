--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

PLUGIN.BoneHoldTypes = {
	["none"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	["default"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Upperarm",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Upperarm",
		"ValveBiped.Bip01_R_Clavicle"
	},
	["vehicle"] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	}
};

PLUGIN.PlaybackRate = 1;
PLUGIN.OldWeapon = nil;
PLUGIN.Sequence = nil;
PLUGIN.Velocity = 0;
PLUGIN.HoldType = nil;

PLUGIN.ForwardOffset = -24;
PLUGIN.BonesToRemove = {};
PLUGIN.RenderAngle = nil;
PLUGIN.RenderColor = {};
PLUGIN.BreathScale = 0.5;
PLUGIN.BoneMatrix = nil;
PLUGIN.NextBreath = 0;
PLUGIN.BiaisAngle = nil;
PLUGIN.ClipVector = vector_up * -1;
PLUGIN.RenderPos = nil;
PLUGIN.RadAngle = nil;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to get whether the legs should be drawn.
function PLUGIN:ShouldDrawLegs()
	return IsValid(self.legsEntity) and openAura.Client:Alive()
	and self:CheckDrawVehicle() and GetViewEntity() == openAura.Client
	and !openAura.Client:ShouldDrawLocalPlayer() and !openAura.Client:GetObserverTarget();
end;

-- A function to check if a vehicle should be drawn.
function PLUGIN:CheckDrawVehicle()
	return openAura.Client:InVehicle() and !gmod_vehicle_viewmode:GetBool() or !openAura.Client:InVehicle();
end;

-- A function to create the legs.
function PLUGIN:CreateLegs()
	self.legsEntity = ClientsideModel(openAura.Client:GetModel(), RENDER_GROUP_OPAQUE_ENTITY);
	self.legsEntity:SetNoDraw(true);
	self.legsEntity:SetSkin( openAura.Client:GetSkin() );
	self.legsEntity:SetMaterial( openAura.Client:GetMaterial() );
	self.legsEntity.LastTick = 0;
end;

-- A function to get when a weapon is changed.
function PLUGIN:WeaponChanged(weapon)
	if ( IsValid(self.legsEntity) ) then
		if ( IsValid(weapon) ) then
			self.HoldType = weapon:GetHoldType();
		else
			self.HoldType = "none";
		end;
		
		self.legsEntity.BuildBonePositions = function(numBones, numPhysBones)
			self.BonesToRemove = {"ValveBiped.Bip01_Head1"};
			
			if ( !openAura.Client:InVehicle() ) then
				self.BonesToRemove = self.BoneHoldTypes[self.HoldType] or self.BoneHoldTypes["default"];
			else
				self.BonesToRemove = self.BoneHoldTypes["vehicle"];
			end;
			
			for k, v in ipairs(self.BonesToRemove) do
				self.BoneMatrix = self.legsEntity:GetBoneMatrix( self.legsEntity:LookupBone(v) );
				
				if (self.BoneMatrix) then
					self.BoneMatrix:Scale(vector_origin);
					self.legsEntity:SetBoneMatrix(self.legsEntity:LookupBone(v), self.BoneMatrix);
				end;
			end;
		end;
	end;
end;

-- Called every frame for the legs.
function PLUGIN:LegsThink(maxSeqGroundSpeed)
	local curTime = CurTime();
	
	if ( IsValid(self.legsEntity) ) then
		if (openAura.Client:GetActiveWeapon() != self.OldWeapon) then
			self.OldWeapon = openAura.Client:GetActiveWeapon();
			self:WeaponChanged(self.OldWeapon);
		end;
		
		if ( self.legsEntity:GetModel() != openAura.Client:GetModel() ) then
			self.legsEntity:SetModel( openAura.Client:GetModel() );
		end
		
		self.legsEntity:SetMaterial( openAura.Client:GetMaterial() );
		self.legsEntity:SetSkin( openAura.Client:GetSkin() );
		self.Velocity = openAura.Client:GetVelocity():Length2D();
		self.PlaybackRate = 1;

		if (self.Velocity > 0.5) then
			if (maxSeqGroundSpeed < 0.001) then
				self.PlaybackRate = 0.01;
			else
				self.PlaybackRate = self.Velocity / maxSeqGroundSpeed;
				self.PlaybackRate = math.Clamp(self.PlaybackRate, 0.01, 10);
			end
		end
		
		self.legsEntity:SetPlaybackRate(self.PlaybackRate);
		self.Sequence = openAura.Client:GetSequence();
		
		if (self.legsEntity.Anim != self.Sequence) then
			self.legsEntity.Anim = self.Sequence;
			self.legsEntity:ResetSequence(self.Sequence);
		end;
		
		self.legsEntity:FrameAdvance(curTime - self.legsEntity.LastTick);
		self.legsEntity.LastTick = curTime;
		
		if (self.NextBreath <= curTime) then
			self.NextBreath = curTime + 1.95 / self.BreathScale;
			self.legsEntity:SetPoseParameter("breathing", self.BreathScale);
		end
		
		self.legsEntity:SetPoseParameter("move_yaw", (openAura.Client:GetPoseParameter("move_yaw") * 360) - 180);
		self.legsEntity:SetPoseParameter("body_yaw", (openAura.Client:GetPoseParameter("body_yaw") * 180) - 90);
		self.legsEntity:SetPoseParameter("spine_yaw", (openAura.Client:GetPoseParameter("spine_yaw") * 180) - 90)
		
		if ( openAura.Client:InVehicle() ) then
			self.legsEntity:SetColor(color_transparent);
			self.legsEntity:SetPoseParameter("vehicle_steer", (openAura.Client:GetVehicle():GetPoseParameter("vehicle_steer") * 2) - 1);
		end;
	end;
end;
