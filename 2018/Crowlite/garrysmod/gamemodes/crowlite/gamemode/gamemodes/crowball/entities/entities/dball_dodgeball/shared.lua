--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

DEFINE_BASECLASS("base_anim");

ENT.PrintName 	= "Dodge Ball";
ENT.Author 		= "ruben and NightAngel";
ENT.Information = "A dodgeball.";
ENT.Category 	= "CrowBall";

ENT.Spawnable 	= true;
ENT.AdminOnly 	= false;

ENT.MinSize 	= 25;
ENT.MaxSize 	= 25;

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "BallSize", {KeyName = "ballsize"});
	self:NetworkVar("Vector", 0, "BallColor", {KeyName = "ballcolor"});
	self:NetworkVar("Int", 0, "ChainNumber", {KeyName = "chainnumber"});
	self:NetworkVar("Int", 1, "Bounces", {KeyName = "bounces"});
	self:NetworkVar("Int", 2, "Kills", {KeyName = "kills"});
	self:NetworkVar("Entity", 0, "ChainOrigin", {KeyName = "chainorigin"});
	self:NetworkVar("Entity", 1, "BallOwner", {KeyName = "ballowner"});
	self:NetworkVar("String", 1, "BallSprite", {KeyName = "ballowner"});
--	self:NetworkVar("String", 1, "BallTrail", {KeyName = "ballowner"});
end;

local colorWhite = Color(255, 255, 255, 255);

function ENT:StartTrail(trailData)
	if (self.trail) then
		self:StopTrail();
	end;
	
	if (!trailData) then
		trailData = {
			Color = colorWhite,
			EndSize = 0,
			Length = 0.5,
			StartSize = 16
		};
	end;

	self.trail = util.SpriteTrail(self, 0, trailData.Color, false, trailData.StartSize, trailData.EndSize, trailData.Length, 1 / ((trailData.StartSize + trailData.EndSize) * 0.5), self:GetTrail());
end;

function ENT:StopTrail()
	if (!self.trail) then return end;

	self.trail:Remove(); self.trail = nil;
end;

-- This is the spawn function. It's called when a client calls the entity to be spawned.
-- If you want to make your SENT spawnable you need one of these functions to properly create the entity
--
-- ply is the name of the player that is spawning it
-- tr is the trace from the player's eyes
--
function ENT:SpawnFunction(ply, trace, ClassName)

	if (!trace.Hit) then return; end;

	local size = 32;

	local ent = ents.Create(ClassName);
	ent:SetPos(trace.HitPos + trace.HitNormal * size);
	ent:SetBallSize(size);
	ent:Spawn();
	ent:Activate();

	return ent;
end;

--[[---------------------------------------------------------
	Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()
	-- We do NOT want to execute anything below in this FUNCTION on CLIENT
	if (CLIENT) then return; end;

	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl");

	-- We will put this here just in case, even though it should be called from OnBallSizeChanged in any case
	self:RebuildPhysics();

	self:SetBallColor(Vector(1, 1, 1));

	self:ResetTrail();

	if (CROWBALL_DEBUG) then
		self:SetBallColor(Vector(0, 1, 0));
	end;
end;

function ENT:GetTrail()
	return self.trailSprite;
end;

function ENT:SetTrail(trail)
	self.trailSprite = trail;
end;

function ENT:ResetTrail()
	self.trailSprite = "trails/smoke.vmt";
end;

function ENT:RebuildPhysics(value)
	local size = math.Clamp(value or self:GetBallSize(), self.MinSize, self.MaxSize) / 2.1;

	self:PhysicsInitSphere(size, "metal_bouncy");
	self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size));

	self:PhysWake();
end;

--[[---------------------------------------------------------
	Name: PhysicsCollide
-----------------------------------------------------------]]
local BounceSound = Sound("garrysmod/balloon_pop_cute.wav");

function ENT:PhysicsCollide(data, physobj)
	local origin = self:GetChainOrigin();

	if (!IsValid(origin)) then
		origin = self;
	end;

	if (!Crow.package:CallAll("OnDodgeballCollide", self, data, physobj, self:GetBallOwner(),
	self:GetBounces(), self:GetChainNumber(), origin, origin:GetKills())) then
		if (data.Speed > 60 && data.DeltaTime > 0.2) then
			local pitch = 32 + 33 - math.Clamp(self:GetBallSize(), self.MinSize, self.MaxSize);

			sound.Play(BounceSound, self:GetPos(), 75, math.random(pitch - 10, pitch + 10), math.Clamp(data.Speed / 150, 0, 1));
		end;

		local LastSpeed = math.max(data.OurOldVelocity:Length(), data.Speed);
		local NewVelocity = physobj:GetVelocity();
		NewVelocity:Normalize();

		LastSpeed = math.max(NewVelocity:Length(), LastSpeed);

		local TargetVelocity = NewVelocity * LastSpeed * 0.7;

		physobj:SetVelocity(TargetVelocity);
	end;
end;

function ENT:ResetValues()
	self:SetBallOwner(nil);
	self:SetBounces(0);
	self:SetChainOrigin(nil);
	self:SetChainNumber(0);
	self.chainedBalls = nil;
	self:SetKills(0);
	self.punted = nil;
	self:Extinguish();
	self:StopTrail();
end;

if ( SERVER ) then return; end; -- We do NOT want to execute anything below in this FILE on SERVER

local matBall = Material("crowlite/crowball/sprites/ball");
local colorWhite = Color(255, 255, 255, 255);
local colorRed = Color(255, 0, 0, 255);
local colorGreen = Color(0, 255, 0, 255);

function ENT:Draw()
	local pos = self:GetPos();
	local c = self:GetBallColor();
	local size = math.Clamp(self:GetBallSize(), self.MinSize, self.MaxSize);
	local color = Color(c.r * 255, c.g * 255, c.b * 255, 255);

	render.SetMaterial(matBall);
	render.DrawSprite(pos, size, size, color);
end;