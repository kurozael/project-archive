--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ENT.Base = "base_nextbot";
ENT.Author = "kurozael";
ENT.Spawnable = true;
ENT.Category = "Severance";
ENT.PrintName = "Zombie";
ENT.AdminSpawnable = true;
ENT.Information = "A bloodthirsty zombie, watch out!";

if (SERVER) then ENT.Type = "nextbot"; end;

-- Set some Clockwork specific variables for the zombie.
ENT.cwDamage = 13;
ENT.cwTarget = nil;
ENT.cwAnimScale = 3;
ENT.cwStartHealth = 175;
ENT.cwClawSounds = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"};
ENT.cwPainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav"};
ENT.cwDeathSounds = {"runner/death1.wav", "runner/death2.wav"};
ENT.cwTauntSounds = {"runner/alert1.wav", "runner/alert2.wav"};
ENT.cwAttackSounds = {"runner/attack1.wav", "runner/attack2.wav"};
ENT.cwWalkSpeed = 80;
ENT.cwChaseSpeed = 120;
ENT.cwWalkAnim = ACT_WALK;
ENT.cwWanderRange = 512;
ENT.cwSwingAnims = {
	"attackA",
	"attackB",
	"attackC",
	"attackD",
	"attackE",
	"attackF",
	"swatleftmid",
	"swatrightmid",
	"swatleftlow",
	"swatrightlow"
};
ENT.cwRandomModels = {
	"models/bloocobalt/infected_citizens/male_01.mdl",
	"models/bloocobalt/infected_citizens/male_02.mdl",
	"models/bloocobalt/infected_citizens/male_03.mdl",
	"models/bloocobalt/infected_citizens/male_04.mdl",
	"models/bloocobalt/infected_citizens/male_05.mdl",
	"models/bloocobalt/infected_citizens/male_06.mdl",
	"models/bloocobalt/infected_citizens/male_07.mdl",
	"models/bloocobalt/infected_citizens/male_08.mdl",
	"models/bloocobalt/infected_citizens/female_01.mdl",
	"models/bloocobalt/infected_citizens/female_02.mdl",
	"models/bloocobalt/infected_citizens/female_03.mdl",
	"models/bloocobalt/infected_citizens/female_04.mdl",
	"models/bloocobalt/infected_citizens/female_06.mdl",
	"models/bloocobalt/infected_citizens/female_07.mdl"


};
--[[-------------------------------------------------------------------------
TODO: Basic Infected Loot Table
SHOULD DROP: Pre 'apocalyptic' stuff, but also gear they would have gotten
in a rush to escape, painkillers, vitamins, anything of the sort.
ON LIST: Making it so that they don't /always/ drop items.
---------------------------------------------------------------------------]]
ENT.cwLootTable = {
	[1] = {"bubble_gum", "buble_gum", "bubble_gum"},
	[2] = {"gin", "bubble_gum", "mre_menu1_meal"}
};
ENT.ZombieType = "Basic Infected"

--[[
	Preload the models so it doesn't load them on spawn, causing lag.
--]]
for k, v in ipairs(ENT.cwRandomModels) do
	util.PrecacheModel(v);
end;

function ENT:StartWalkAnim()
	self:StartActivity(self.cwWalkAnim);
end;

function ENT:StartSwingAnim()
	local swingAnims = self.cwSwingAnims;

	self:PlaySequenceAndWait(swingAnims[math.random(1, #swingAnims)]);
end;

-- Called when the zombies behaviour should be handled (co-routine.)
function ENT:RunBehaviour()
	while (true) do
		local target = self.cwTarget;
		
		if (!target or self:CanTargetPlayer(target)) then
			for k, v in ipairs(ents.FindByClass("cw_entityflare")) do
				if (self:GetRangeTo(v) <= 1000) then
					self.cwTarget = v;
					break;
				end;
			end;
		end;
		
		if (IsValid(target) and (!self:CanTargetPlayer(target) or target:Alive()) and self:GetRangeTo(target) <= 1200) then
			if (self:GetRangeTo(target) <= 48) then
				if (!target:IsPlayer()) then
					self:StartWalkAnim();
					return;
				end;
				
				self:EmitSound("rage/rage_"..math.random(1, 13)..".wav", 100, math.random(75, 125))

				self:SimpleDelay(0.3, function()
					self:EmitSound("hitsound/claw_miss_"..math.random(1, 2)..".wav")
				end)

				self:SimpleDelay(0.4, function()
					if (IsValid(target) and self:GetRangeTo(target) <= 40) then
						local damageInfo = DamageInfo();
							damageInfo:SetAttacker(self);
							damageInfo:SetDamage(self.cwDamage);
							damageInfo:SetDamageType(DMG_CLUB);

							local force = target:GetAimVector() * -300;
								force.z = 16;
							damageInfo:SetDamageForce(force);
						target:TakeDamageInfo(damageInfo);
						target:EmitSound("hitsound/hit_punch_"..math.random(1, 13)..".wav", 100, math.random(80, 160));
						target:ViewPunch(VectorRand():Angle() * 0.1);
						target:SetVelocity(force);
					end;
				end);

				self:SimpleDelay(0.45, function()
					if (IsValid(target) and !target:Alive()) then
						target.cwTarget = nil;
					end;
				end);

				self:StartSwingAnim();
			else
				if (!self:CanTargetPlayer(target)) then
					self.cwTarget = nil;
				end;

			--	self:StartActivity(ACT_RUN);
				self:StartWalkAnim();
				self.loco:SetDesiredSpeed(self.cwChaseSpeed);

				if (self.cwBreathSound) then
					self.cwBreathSound:ChangePitch(80, 1)
					self.cwBreathSound:ChangeVolume(1.25, 1)
				end;

				if (math.random(1, 2) == 2 and (self.nextYell or 0) < CurTime()) then
					self:EmitSound("runner/attack"..math.random(1, 2)..".wav", 80, math.random(30, 50));
					self.nextYell = CurTime() + math.random(4, 8);
				end;

			--	self.loco:SetDesiredSpeed(230);
				self:MoveToPos(target:GetPos(), {
					maxage = 0.67
				});
			end;
		else
			self.cwTarget = nil;
			self:StartWalkAnim();
			self.loco:SetDesiredSpeed(self.cwWalkSpeed);
			
			self:MoveToPos(self:GetPos() + Vector(
				math.random(
					-self.cwWanderRange, 
					self.cwWanderRange
				), 
				math.random(
					-self.cwWanderRange,
					self.cwWanderRange
				), 
				0
			),
			{
				repath = 3,
				maxage = 2
			});

			if (math.random(1, 8) == 2) then
				self:EmitSound("runner/idle/idle"..math.random(1, 17)..".wav", 100, 30);

				self:PlaySequenceAndWait("Idle01", math.random(0.5, 1));
			end;

			if (!self.cwTarget) then
				for k, v in pairs(player.GetAll()) do
					if (v:Alive() and self:CanTargetPlayer(v) and self:GetRangeTo(v) <= 700) then
						self:AlertNearby(v);
						self.cwTarget = v;

						if (self:GetRangeTo(v) > 540) then
							self:PlaySequenceAndWait("Tantrum", 0.9);
						end;

						break;
					end;
				end;
			end;
		end;

		coroutine.yield();
	end;
end;

-- A function to determine if a zombie will want to target a player.
function ENT:CanTargetPlayer(player)
	return (player:IsValid() and player:IsPlayer() and !Clockwork.player:IsNoClipping(player) and !Severance:PlayerIsZombie(player));
end;

-- Called when the entity is killed by an attacker (provides DamageInfo structure.)
function ENT:OnKilled(damageInfo)
	self:EmitSound(table.Random(self.cwDeathSounds), 100, math.random(75, 100));
	local ragdoll = Clockwork.entity:MakeIntoRagdoll(self);

	if (IsValid(ragdoll)) then
		local ranSelection = table.Random(self.cwLootTable);
		ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);

		if (!ragdoll.cwInventory) then
			cwStorage.storage[ragdoll] = ragdoll;
			ragdoll.cwInventory = {};

			for k, v in pairs(ranSelection) do
				Clockwork.inventory:AddInstance(ragdoll.cwInventory, Clockwork.item:CreateInstance(v));
			end;
		end;

		ragdoll:SetBodygroup(1, self:GetBodygroup(1));
		ragdoll:SetBodygroup(2, self:GetBodygroup(2));
		ragdoll:SetBodygroup(3, self:GetBodygroup(3));
		ragdoll:SetBodygroup(4, self:GetBodygroup(4));
		Clockwork.entity:Decay(ragdoll, 120);
		self:Remove();
	end;
end;
-- Send out a signal to alert other nearby zombies.
-- Thanks again, Chessnut, for this function (you saved me a few seconds.)
function ENT:AlertNearby(target, range, boNoise)
	if (range == nil) then range = 2400; end;
	if (IsValid(self.cwTarget)) then return; end;

	if (!bNoNoise) then
		self:EmitSound("runner/become_alert"..math.random(1, 4)..".wav", 100, 120);
	end

	for k, v in pairs(ents.FindByClass("cw_zombie_nextbot")) do
		if (self != v and !IsValid(v.cwTarget) and self:GetRangeTo(v) <= range) then
			timer.Create("AlertZombie_"..v:EntIndex(), self:GetRangeTo(v) / 800, 1, function()
				if (!IsValid(v) or !IsValid(target)) then return; end;

				v.cwTarget = target;
				v:EmitSound("npc/zombie/zombie_alert"..math.random(1, 3)..".wav", 100, math.random(60, 120));
				v:AlertNearby(target, range + 640);
			end)
		end;
	end;
end;

--[[
	A function to run a specific function after a delay.
	Saves time, code, and performs a valid check.
--]]
function ENT:SimpleDelay(delayTime, Callback)
	timer.Simple(delayTime, function()
		if (IsValid(self)) then Callback(); end;
	end);
end;

-- Called when the zombie hits the ground after a jump or fall.
function ENT:OnLandOnGround()
	self:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 6)..".wav");
end;

-- Called when the zombie is injured by some attacker (w/ DamageInfo structure.)
function ENT:OnInjured(damageInfo)
	local attacker = damageInfo:GetAttacker()
	self:EmitSound("pain/been_shot_"..math.random(1, 16)..".wav", 100, math.random(50, 100));
	
	if (self:CanTargetPlayer(attacker)) then
		self.cwTarget = attacker;
	end;

	if (self:Health() <= 0) then
		self:OnKilled(damageInfo);
	end;
end;

-- Called to update the animations.
function ENT:BodyUpdate()
	local act = self:GetActivity();
	
	if (act == self.cwWalkAnim) then
		self:BodyMoveXY();
	end;

	self:FrameAdvance();
end;