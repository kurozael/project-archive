--[[
Name: "sh_autorun.lua".
Product: "HL2 RP".
--]]

if (SERVER) then
	AddCSLuaFile("sh_autorun.lua");
end;

-- Check if a statement is true.
if (CLIENT) then
	SWEP.Slot = 4;
	SWEP.SlotPos = 4;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Flash Grenade";
	SWEP.DrawCrosshair = true;
end

-- Set some information.
SWEP.Instructions = "Primary Fire: Throw.";
SWEP.Purpose = "Disorientating characters with a bright white flash.";
SWEP.Contact = "";
SWEP.Author	= "kuromeku";

-- Set some information.
SWEP.WorldModel = "models/weapons/w_grenade.mdl";
SWEP.ViewModel = "models/weapons/v_grenade.mdl";

-- Set some information.
SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
-- Set some information.
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 0;
SWEP.Primary.Delay = 1;
SWEP.Primary.Ammo = "grenade";

-- Set some information.
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Delay = 1;
SWEP.Secondary.Ammo	= "";

-- Set some information.
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);

-- Called each frame.
function SWEP:Think()
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if ( self.PulledBack and !self.Owner:KeyDown(IN_ATTACK) ) then
		if (curTime >= self.PulledBack) then
			self.PulledBack = nil;
			self.Attacking = curTime + (self.Primary.Delay / 2);
			self.Raised = curTime + self.Primary.Delay + 2;
			
			-- Check if a statement is true.
			if (!self.AttackTime) then
				self.AttackTime = curTime;
			end;
			
			-- Create the grenade and emit a sound from the entity.
			self:CreateGrenade(math.Clamp(curTime - self.AttackTime, 0, 10) * 40);
			self:EmitSound("WeaponFrag.Throw");
			
			-- Set some information.
			self:SendWeaponAnim(ACT_VM_THROW);
			self:SetNextPrimaryFire(curTime + self.Primary.Delay);
			
			-- Set the player's animation.
			self.Owner:SetAnimation(PLAYER_ATTACK1);
		end;
	elseif (type(self.Attacking) == "number") then
		if (curTime >= self.Attacking) then
			self.Attacking = nil;
			
			-- Send a weapon animation.
			self:SendWeaponAnim(ACT_VM_DRAW);
			
			-- Check if a statement is true.
			if (SERVER) then
				self.Owner:RemoveAmmo(1, "grenade");
				
				-- Check if a statement is true.
				if (self.Owner:GetAmmoCount("grenade") == 0) then
					self.Owner:StripWeapon( self:GetClass() );
				end;
			end;
		end;
	end;
end;

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	if (SERVER) then
		self:SetWeaponHoldType("grenade");
	end;
	
	-- Send a weapon animation.
	self:SendWeaponAnim(ACT_VM_DRAW);
	
	-- Set some information.
	self.PulledBack = nil;
	self.Attacking = nil;
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	
	-- Set some information.
	self.PulledBack = nil;
	self.Attacking = nil;
	
	-- Return true to break the function.
	return true;
end;

-- Called to get whether the SWEP is raised.
function SWEP:GetRaised()
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if ( self.Attacking or (self.Raised and self.Raised > curTime) ) then
		return true;
	end;
end;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType("grenade");
	end;
end;

-- A function to create the SWEP's grenade.
function SWEP:CreateGrenade(power)
	if (SERVER) then
		local position = self.Owner:GetShootPos() + (self.Owner:GetAimVector() * 64);
		local entity = ents.Create("prop_physics");
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		-- Check if a statement is true.
		if (trace.HitPos:Distance( self.Owner:GetShootPos() ) <= 80) then
			position = trace.HitPos - (self.Owner:GetAimVector() * 16);
		end;
		
		-- Set some information.
		entity:SetModel("models/items/grenadeammo.mdl");
		entity:SetPos(position);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(entity) ) then
			if ( ValidEntity( entity:GetPhysicsObject() ) ) then
				entity:GetPhysicsObject():ApplyForceCenter( self.Owner:GetAimVector() * (800 + power) );
				entity:GetPhysicsObject():AddAngleVelocity( Angle(600, math.random(-1200, 1200), 0) );
			end;
			
			-- Set some information.
			local trail = util.SpriteTrail(entity, entity:LookupAttachment("fuse"), Color(255, 100, 0), true, 8, 1, 1, (1 / 9) * 0.5, "sprites/bluelaser1.vmt");
			
			-- Check if a statement is true.
			if ( ValidEntity(trail) ) then
				entity:DeleteOnRemove(trail);
			end;
			
			-- Set some information.
			timer.Simple(4, function()
				if ( ValidEntity(entity) ) then
					local effectData = EffectData();
					local position = entity:GetPos();
					local k, v;
					
					-- Set some information.
					effectData:SetStart( entity:GetPos() );
					effectData:SetOrigin( entity:GetPos() );
					effectData:SetScale(16);
					
					-- Set some information.
					util.Effect("Explosion", effectData, true, true);
					
					-- Loop through each value in a table.
					for k, v in ipairs( g_Player.GetAll() ) do
						if ( v:HasInitialized() ) then
							if (v:GetPos():Distance(position) <= 768) then
								if ( kuroScript.player.CanSeeEntity(v, entity, 0.9, true) ) then
									umsg.Start("ks_Flashed", v);
									umsg.End();
								end;
							end;
						end;
					end;
					
					-- Emit a sound from the entity and remove it.
					entity:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
					entity:Remove();
				end;
			end);
		end;
	end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	local curTime = CurTime();
	
	-- Check if a statement is true.
	if (!self.Attacking) then
		self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH);
		
		-- Set some information.
		self.PulledBack = curTime + 0.157;
		self.AttackTime = curTime;
		self.Attacking = true;
	end;
	
	-- Return false to break the function.
	return false;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;