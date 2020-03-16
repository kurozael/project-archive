--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

MISSION = Clockwork.mission:New();
MISSION.name = "Treasure Hunt";
MISSION.playTime = 600;
MISSION.musicSound = "music/hl2_song12_long.mp3";
MISSION.description = "Find the artifact and hold it in your hands for two minutes!";

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
		local locations = self:GetLocations();
		
		self.artifactEnt = ents.Create("prop_physics");
			self.artifactEnt:SetModel("models/gibs/hgibs.mdl");
			self.artifactEnt:SetPos(locations[math.random(1, #locations)] + Vector(0, 0, 32));
		self.artifactEnt:Spawn();
		self.artifactEnt:Activate();
		
		--[[ Let the client know that this entity is our artifact. --]]
		self.artifactEnt:SetNetworkedBool("IsArtifact", true);
		self.artifactEnt.cwIsInvincibile = true;
		
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
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				Clockwork.player:StopSound(v, "Mission", 2);
			end;
		end;
		
		if (IsValid(self.artifactEnt)) then
			self.artifactEnt:Remove();
		end;
		
		self.lastHolder = nil;
		
		if (IsValid(self.winner)) then
			Clockwork.player:GiveCash(self.winner, 300, "winning the Treasure Hunt");
			return self.winner:Name().." has won "..FORMAT_CASH(300, nil, true).."!";
		end;
	end;
end;

-- A function to setup a player's visibility.
function MISSION:SetupPlayerVisibility(player)
	if (IsValid(self.artifactEnt)) then
		AddOriginToPVS(self.artifactEnt:GetPos());
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function MISSION:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (entity:GetNetworkedBool("IsArtifact")) then
		info.y = Clockwork:DrawInfo("The Artifact", info.x, info.y, colorTargetID, info.alpha);
		info.y = Clockwork:DrawInfo("Hold it for two minutes to win.", info.x, info.y, colorWhite, info.alpha);
	end;
end;

-- Called just after the translucent renderables have been drawn.
function MISSION:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (!bDrawingSkybox and Clockwork.Client:Alive()) then
		if (!IsValid(self.artifactEnt)) then
			for k, v in ipairs(ents.FindByClass("prop_physics")) do
				if (v:GetNetworkedBool("IsArtifact")) then
					self.artifactEnt = v;
					break;
				end;
			end;
		else
			Clockwork.outline:RenderFromFade(
				self.artifactEnt, Color(0, 255, 255, 255), nil, true
			);
		end;
	end;
end;

-- Called at an interval while a player is connected.
function MISSION:PlayerThink(player, curTime, infoTable)
	local entity = player:GetHoldingEntity();
	
	if (IsValid(entity) and entity == self.artifactEnt) then
		if (!player.cwHoldArtifactTime) then
			player.cwHoldArtifactTime = curTime + 120;
			
			if (self.lastHolder != player) then
				Clockwork.mission:PrintCenter(
					nil, "TREASURE HUNT", player:Name().." has picked up the artifact!"
				);
				self.lastHolder = player;
			end;
		end;
	else
		player.cwHoldArtifactTime = nil;
		player.cwHoldAlertType = 30;
	end;
	
	if (player.cwHoldArtifactTime) then
		local timeLeft = math.max(player.cwHoldArtifactTime - curTime, 0);
		
		if (timeLeft == 0) then
			self.winner = player;
			self:Stop();
		elseif (timeLeft <= 30) then
			if (player.cwHoldAlertType != 30) then
				Clockwork.mission:PrintCenter(
					nil, "TREASURE HUNT", player:Name().." needs to hold the artifact for half a minute!"
				);
				player.cwHoldAlertType = 30;
			end;
		elseif (timeLeft <= 60) then
			if (player.cwHoldAlertType != 60) then
				Clockwork.mission:PrintCenter(
					nil, "TREASURE HUNT", player:Name().." needs to hold the artifact for one more minute!"
				);
				player.cwHoldAlertType = 60;
			end;
		end;
	end;
end;

MISSION:Register();