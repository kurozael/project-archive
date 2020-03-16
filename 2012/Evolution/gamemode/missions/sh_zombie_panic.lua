--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

MISSION = Clockwork.mission:New();
MISSION.name = "Zombie Panic";
MISSION.playTime = 300;
MISSION.musicSound = "music/hl2_song20_submix4.mp3";
MISSION.description = "Zombies have taken over the area, kill them for some good loot!";

--[[
	Place any hooks here, the Mission is registered
	as a plugin module.
--]]

-- Called to get whether the mission can start.
function MISSION:CanStart()
	local locations = self:GetLocations();
	return (locations and #locations > 0);
end;

-- Called when the mission has started.
function MISSION:OnStart()
	if (SERVER) then
		self.uniqueItems = Schema:GetRareAndLegendaries();
		self.zombieList = {};
		
		for k, v in ipairs(self:GetLocations()) do
			self.zombieList[k] = ents.Create("npc_zombie");
			self.zombieList[k]:SetPos(v);
			self.zombieList[k]:Spawn();
			self.zombieList[k]:Activate();
		end;
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				Clockwork.player:StartSound(v, "Mission", self.musicSound, 0.5);
			end;
		end;
	end;
end;

-- Called when the mission has stopped.
function MISSION:OnStop()
	if (SERVER) then
		for k, v in ipairs(self.zombieList) do
			if (IsValid(v)) then
				Clockwork:CreateBloodEffects(v:GetPos(), 2, v, nil, 2);
					v:EmitSound("physics/flesh/flesh_bloody_break.wav");
				v:Remove();
			end;
		end;
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				Clockwork.player:StopSound(v, "Mission", 2);
			end;
		end;
		
		local topPlayer = {
			player = nil,
			kills = 0
		};
		
		for k, v in ipairs(player.GetAll()) do
			if (v.cwZombieKills and v.cwZombieKills > topPlayer.kills) then
				topPlayer.player = v;
				topPlayer.kills = v.cwZombieKills;
			end;
		end;
		
		self.uniqueItems = nil;
		self.zombieList = nil;
		
		if (IsValid(topPlayer.player)) then
			return topPlayer.player:Name().." has the most zombie kills!";
		end;
	end;
end;

-- A function to setup a player's visibility.
function MISSION:SetupPlayerVisibility(player)
	for k, v in ipairs(self.zombieList) do
		if (IsValid(v)) then
			AddOriginToPVS(v:GetPos());
		end;
	end;
end;

-- Called just after the translucent renderables have been drawn.
function MISSION:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox and Clockwork.Client:Alive()) then
		for k, v in ipairs(ents.FindByClass("npc_zombie")) do
			if (v:Health() > 0) then
				Clockwork.outline:RenderFromFade(
					v, Color(0, 255, 255, 255), 1024, true
				);
			end;
		end;
	end;
end;

-- Called when an NPC has been killed.
function MISSION:OnNPCKilled(victim, attacker, weapon)
	for k, v in ipairs(self.zombieList) do
		if (victim == v) then
			Clockwork:CreateBloodEffects(v:GetPos(), 2, v, nil, 2);
				v:EmitSound("physics/flesh/flesh_bloody_break.wav");
			table.remove(self.zombieList, k);
			break;
		end;
	end;
	
	local fRandom = math.random();
	
	if (fRandom < 0.02 and #self.uniqueItems.legendary > 0) then
		Clockwork.entity:CreateItem(
			nil, self.uniqueItems:GetRandomLegendaryItem(), victim:GetPos() + Vector(0, 0, 32)
		);
	elseif (fRandom < 0.15 and #self.uniqueItems.rare > 0) then
		Clockwork.entity:CreateItem(
			nil, self.uniqueItems:GetRandomRareItem(), victim:GetPos() + Vector(0, 0, 32)
		);
	else
		local randomItemInfo = Schema:GetRandomItemInfo(
			{"Consumables", "Disposables"}
		);
		
		if (randomItemInfo) then
			Clockwork.entity:CreateItem(
				nil, Clockwork.item:CreateInstance(randomItemInfo[1]),
				victim:GetPos() + Vector(0, 0, 32)
			);
		end;
	end;
	
	if (attacker:IsPlayer()) then
		attacker.cwZombieKills = attacker.cwZombieKills or 0;
		attacker.cwZombieKills = attacker.cwZombieKills + 1;
	end;
	
	if (#self.zombieList > 0) then
		return;
	end;
	
	--[[ There is no more zombies left, let's stop this madness! --]]
	self:Stop();
end;

MISSION:Register();