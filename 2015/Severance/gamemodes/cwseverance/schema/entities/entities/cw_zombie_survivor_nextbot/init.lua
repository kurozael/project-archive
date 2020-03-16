--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.kernel:IncludePrefixed("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

-- Called when the entity is spawned.
function ENT:SpawnFunction(player, trace)
	if (!trace.Hit) then return; end;
	
	local spawnPos = trace.HitPos + trace.HitNormal * 20;
	local entity = ents.Create("cw_zombie_nextbot");
		entity:SelectRandomModel();
		entity:SetPos(spawnPos)
		entity:Spawn();
		entity:Activate();
	return entity;
end;

-- A function to select a random model for the zombie.
function ENT:SelectRandomModel()
	self:SetModel(self.cwRandomModels[math.random(1, #self.cwRandomModels)]);

	if (string.find(self:GetModel(), "infected_citizens")) then
		self:SetBodygroup(1, math.random(5, 9));
		self:SetBodygroup(2, math.random(2, 4));
		self:SetBodygroup(3, math.random(1, 3));
		self:SetBodygroup(4, math.random(1, 3));
		return true; --We're going to handle bodygroups for /these/ models differently, because we have a new zombie variant for them.
	end

	local bodygroups = self:GetBodyGroups();

	for k, v in pairs(bodygroups) do
		local start = 1;
		if (v.name == "head") then
			start = 2;
		end;

		self:SetBodygroup(v.id, math.random(start, v.num));
	end;
end;

-- Called when the entity is initialized.
function ENT:Initialize()
	--[[ Thanks to Chessnut for this breathing idea. --]]
	self.cwBreathSound = CreateSound(self, "npc/zombie_poison/pz_breathe_loop1.wav")
	self.cwBreathSound:Play()
	self.cwBreathSound:ChangePitch(60, 0)
	self.cwBreathSound:ChangeVolume(0.3, 0)
	
	self.loco:SetDeathDropHeight(750);
	self:SelectRandomModel();
	self:SetHealth(math.random(self.cwStartHealth * 0.25, self.cwStartHealth));
	self:SetCollisionBounds(Vector(-4, -4, 0), Vector(4, 4, 64));

	hook.Add("EntityRemoved", self, function()
		if (self.cwBreathSound) then
			self.cwBreathSound:Stop()
			self.cwBreathSound = nil
		end
	end)
end;