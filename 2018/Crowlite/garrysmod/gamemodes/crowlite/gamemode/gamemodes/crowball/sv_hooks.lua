--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

local CrowPackage = Crow.nest:GetLibrary("package");

function CrowBall:PlayerDeathSound()
	return true
end;

function CrowBall:PlayerDeath(player, inflictor, attacker)
	player.deathTimer = nil;
	player.forceRespawnTimer = nil;
end;

function CrowBall:PreCrowRoundStart()
	self:AutoAssignTeams();

	self:ResetGame();
end;

function CrowBall:PostPlayerChangeTeam(player, oldTeam, newTeam)
	player:SetFrags(0);
	player:Spawn();
end;

function CrowBall:GivePhysGun(player)
	player:StripWeapons();

	if (player:Team() != TEAM_SPECTATOR and player:GetMoveType() == MOVETYPE_WALK) then	
		player:Give("weapon_physcannon");
	end;
end;

function CrowBall:ResetPlayers()
	local spawnTime = 0;

	for k, v in pairs(_player.GetAll()) do
		if (v:Team() != TEAM_SPECTATOR) then
			v:KillSilent();

			timer.Simple(spawnTime, function()
				if (IsValid(v)) then
					v:Spawn();
				end;
			end);

			spawnTime = spawnTime + 0.2;
		end;
	end;
end;

function CrowBall:AutoAssignTeams()
	if (CrowRounds:GetTeamBased()) then
		for k, v in pairs(_player.GetAll()) do
			local plyTeam = v:Team();

			if (plyTeam != self._TEAM_BLUE and plyTeam != self._TEAM_RED and plyTeam != TEAM_SPECTATOR or v:IsBot()) then
				local selectedTeam = team.BestAutoJoinTeam();

				v:SetTeam(selectedTeam);
			end;
		end;
	else
		for k, v in pairs(_player.GetAll()) do
			v:SetTeam(TEAM_UNASSIGNED);
		end;
	end;
end;

function CrowBall:DoPlayerDeathThink(player)
	local curTime = CurTime();

	if (!player.deathTimer) then 
		player.deathTimer = curTime + self._RESPAWN_TIMER; 
	end;

	if (!player.forceRespawnTimer) then
		player.forceRespawnTimer = curTime + (self._RESPAWN_TIMER * 3);
	end;

	if (player.deathTimer <= curTime) then
		if (player:KeyDown(IN_ATTACK)) then
			return true;
		end;
	end;

	if (player.forceRespawnTimer <= curTime) then
		return true;
	end;
end;

function CrowBall:EntityRemove(entity)
	if (entity:GetClass() == "dball_dodgeball") then
		
	end;
end;

function CrowBall:ResetGame()
	game.CleanUpMap();

	self:ResetPlayers();

	local spawns = ents.FindByClass("info_dball_spawn");

	if (spawns and #spawns > 0) then
		local spawnIndex = 1;

		for i = 1, self._BALL_NUMBER do
			local spawn = spawns[spawnIndex];

			local ball = ents.Create("dball_dodgeball");

			ball:SetPos(spawn:GetPos());

			timer.Simple(i * 0.3, function()
				if (IsValid(ball)) then
					ball:Spawn();
					ball:Activate();
				end;
			end);

			spawnIndex = spawnIndex + 1;

			if (spawnIndex > #spawns) then
				spawnIndex = 1;
			end;
		end;
	else
		local players = _player.GetAll();

		if (players and #players >= 1) then
			for i = 1, self._BALL_NUMBER do
				local ball = ents.Create("dball_dodgeball");
						
				local player = players[i];

				if (!player) then
					player = players[#players];
				end;

				ball:SetPos(player:GetPos() + Vector(0, 0, 100));

				timer.Simple(i * 0.3, function()	
					ball:Spawn();
					ball:Activate();
				end);
			end;
		end;
	end;
end;

function CrowBall:PostCrowRoundAdvance(index, stage)
	local players = _player.GetAll();
	local fragTable = {};

	for k, v in pairs(players) do
		if (stage.name == "Post-Round") then
			local frags = v:Frags();

			if (frags > 0) then
		 		table.insert(fragTable, {v:Name(), frags});
		 	end;
		else
			v:SetFrags(0);
			v:SetDeaths(0);
		end;
	end;

	if (stage.name == "Round") then
		self:ResetGame();
	end;
end;

local colorWhite = Color(255, 255, 255, 255);
local colorRed = Color(255, 100, 100, 255);

function CrowBall:PreCrowRoundAdvance(index, stage)
	if (stage.name == "Post-Round") then
		local results = self:GetWinner();
		local winner = "tied";

		if (!results.tied) then
			winner = results.winner;

			MsgC(colorRed, "[CROWBALL] ", colorWhite, team.GetName(results.winner).." wins the round!\n");
		else
			MsgC(colorRed, "[CROWBALL] ", colorWhite, "The round ended in a tie!\n");
		end;

		jsonstream.Send("CrowBallRoundWinner", {winner}, _player.GetAll());
	end;
end;

function CrowBall:PostCrowRoundStart()
	self:ResetWinner();
end;

function CrowBall:ResetWinner()
	self.winner = nil;

	jsonstream.Send("CrowBallRoundWinner", {}, _player.GetAll());
end;

function CrowBall:GetWinner()
	local results = {
		blue = self._TEAM_BLUE, 
		red = self._TEAM_RED, 
		tied = false,
		winner = self._TEAM_BLUE
	};

	if (team.TotalFrags(results.blue) < team.TotalFrags(results.red)) then
		results.winner = results.red;
	elseif (team.TotalFrags(results.blue) == team.TotalFrags(results.red)) then
		results.tied = true;
	end;

	CrowPackage:CallAll("AdjustRoundWinner", results);

	return results;
end;

function CrowBall:PostCrowRoundOver()
	if (#_player.GetAll() >= self._MINIMUM_PLAYERS) then
		CrowRounds:HandleStart();
	else
		self:ResetGame();
	end;
end;

function CrowBall:PlayerConnect(player)
	if (#_player.GetAll() + 1 >= self._MINIMUM_PLAYERS and !CrowRounds:GetActive()) then
		CrowRounds:HandleStart();
	end;
end;

function CrowBall:PlayerDisconnected(player)
	if (#_player.GetAll() - 1 < self._MINIMUM_PLAYERS) then
		CrowRounds:StopRound();

		self:ResetGame();
	end;
end;

function CrowBall:EntityTakeDamage(entity, damageInfo)
	if (damageInfo:GetInflictor():GetClass() != "dball_dodgeball" or damageInfo:IsDamageType(DMG_BURN)) then
		return true;
	end;
end;

local immuneGroup = COLLISION_GROUP_WORLD;

function CrowBall:PostPlayerSpawn(player)
	self:GivePhysGun(player);

	if (CrowRounds:GetTeamBased()) then
		local plyTeam = player:Team();

		if (plyTeam) then
			if (team.GetName(plyTeam) != "Unassigned") then
				local teamColor = team.GetColor(plyTeam);

				player:SetPlayerColor(Vector(teamColor.r / 255, teamColor.g / 255, teamColor.b / 255));
			else
				local newTeam = team.BestAutoJoinTeam();
				local teamColor = team.GetColor(newTeam);

				player:SetTeam(newTeam);
				player:SetPlayerColor(Vector(teamColor.r / 255, teamColor.g / 255, teamColor.b / 255));
			end;
		end;
	end;
end;

function CrowBall:TeamSpawn(player)
	local spawnTable = team.GetSpawnPoints(player:Team());

	if (spawnTable and #spawnTable > 0) then
		local spawnPoint = table.Random(spawnTable);

		player:SetPos(spawnPoint:GetPos());
		player:SetAngles(spawnPoint:GetAngles());
	end;
end;

function CrowBall:PrePlayerSpawn(player)
	if (player:Team() != TEAM_SPECTATOR) then
		player:UnSpectate();

		local oldColor = player:GetColor();

		self:TeamSpawn(player);

		player.oldGroup = player:GetCollisionGroup();
		player.oldMode = player:GetRenderMode();

		player:SetCollisionGroup(immuneGroup);
		player:SetRenderMode(RENDERMODE_TRANSALPHA);
		player:SetColor(Color(oldColor.r, oldColor.g, oldColor.b, 100));
		player.immunityTime = CurTime() + self._SPAWN_IMMUNITY;

		jsonstream.Send("CrowBallImmunityPing", {self._SPAWN_IMMUNITY}, player);
	else
		player:Spectate(OBS_MODE_ROAMING);
		player:StripWeapons();

		return true;
	end;
end;

function CrowBall:PlayerTick(player)
	if (player.immunityTime) then
		local curTime = CurTime();

		if (player.immunityFlash == nil) then
			player.immunityFlash = true;
		end;

		if (!player.nextImmunityFlash) then
			player.nextImmunityFlash = curTime + ((player.immunityTime - curTime) * 0.05);
		end;

		if (player.nextImmunityFlash <= curTime) then
			local playerColor = player:GetColor();

			if (player.immunityFlash == true) then
				player:SetColor(Color(playerColor.r, playerColor.g, playerColor.b, 255));
			else
				player:SetColor(Color(playerColor.r, playerColor.g, playerColor.b, 100));
			end;

			player.nextImmunityFlash = nil;
			player.immunityFlash = !player.immunityFlash;
		end;

		if (player.immunityTime <= curTime) then
			local playerColor = player:GetColor();

			player:SetCollisionGroup(player.oldGroup);
			player:SetRenderMode(player.oldMode);
			player:SetColor(Color(playerColor.r, playerColor.g, playerColor.b, 255));

			player.oldGroup = nil;
			player.oldMode = nil;
			player.isImmune = nil;
			player.immunityTime = nil;
			player.immunityFlash = nil;
			player.nextImmunityFlash = nil;
		end;
	end;
end;

--[[
function CrowBall:GravGunPickupAllowed(player, entity)
	if (player:GetCollisionGroup() == immuneGroup) then
--		return false;
	end;
end;
--]]

function CrowBall:GravGunOnPickedUp(player, entity)
	player.isHoldingBall = true;
	entity:ResetValues();
	entity.isHeld = true;
	entity:SetBallOwner(player);
	entity:SetBounces(0);

	Crow.package:CallAll("PostDodgeballArmed", entity, entity.isHeld, player);

	if (self._DEBUG) then
		entity:SetBallColor(Vector(1, 0, 0));
	end;
end;

function CrowBall:GravGunOnDropped(player, entity)
	player.isHoldingBall = nil;
	entity.isHeld = nil;

	if (!entity.punted) then
		entity:ResetValues();
	end;
end;

function CrowBall:GravGunPunt(player, entity)
	if (player:GetCollisionGroup() == immuneGroup) then
		jsonstream.Send("CrowBallImmunityPuntPing", {}, player);

		return false;
	end;

	entity.punted = true;

	if (entity:GetBallOwner() != player) then
		entity:SetChainOrigin(nil);
		entity:SetChainNumber(0);
		entity.chainedBalls = nil;
		entity:SetKills(0);
	end;

	entity:SetBallOwner(player);
	entity.faded = true;

	--[[ This prevents suicides by sprint-jumping and firing a ball in the same direction. --]]
	timer.Simple(0.1, function()
		if (IsValid(entity)) then
			entity.faded = nil;
		end;
	end);

	Crow.package:CallAll("PostDodgeballArmed", entity, nil, player);

	if (self._DEBUG) then
		entity:SetBallColor(Vector(1, 0, 0));
	end;
end;

function CrowBall:PostDodgeballArmed(ball, isHeld, player)
	if (IsValid(ball) and !isHeld) then
		if (player and player.ballTrail) then
			ball:SetTrail(player.ballTrail);	
		end;

		ball:StartTrail();
	end;
end;

function CrowBall:PreDodgeballKill(ball, entity, crowOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin)
	if (bounces == 0 and crowOwner == entity and ball.faded) then
		return true;
	end;

	if (entity:GetCollisionGroup() == immuneGroup or crowOwner:GetCollisionGroup() == immuneGroup) then
		jsonstream.Send("CrowBallImmunityPuntPing", {}, crowOwner);

		return true;
	end;

	if (CrowRounds:GetTeamBased() and entity:Team() == crowOwner:Team() and crowOwner != entity) then
		return true;
	end;
end;

local killMessages = {
	"domed",
	"rekt",
	"absolutely destroyed",
	"crushed",
	"completely humiliated",
	"a ticket to meet their maker",
	"roasted"
};

local suicideMessages = {
	"crushed themself!",
	"decided to end it all swiftly!",
	"bid farewell, cruel world!",
	"decided that no one loves them!",
	"decided their next life was waiting for them!",
	"realized they f#@%ed up!",
	"needs to read the tutorial!"
};

local comboMessages = {
	{"a double kill."},
	{"a triple kill."},
	{"a quadra kill."},
	{"a penta kill."},
	{"a hexa kill."},
	{"a hepta kill."},
	{"an octa kill."},
	{"a whole lot of kills."},
	{"- how are they getting so many kills?!"},
	{
		"- I quit, I've run out of things to say.",
		"- HOW ARE YOU DOING THIS?!",
		"- Somebody please stop them, I'm running out of things to say.."
	}
};

function CrowBall:PostDodgeballKill(ball, entity, crowOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin)
	SlowMo:SlowTime(0.35, 1);

	if (crowOwner != entity) then
		local kills = chainOrigin:GetKills();
		
		if (kills <= 1) then
			local killMsg = entity:Name().." got "..killMessages[math.random(1, #killMessages)].." by "..crowOwner:Name().."!";

--			PrintMessage(HUD_PRINTCENTER, killMsg);
			PrintMessage(HUD_PRINTTALK, killMsg);
		else
			local messageTable = comboMessages[kills - 1] or comboMessages[#comboMessages];
			local comboMsg = crowOwner:Name().." killed "..entity:Name().." for "..messageTable[math.random(1, #messageTable)];

--			PrintMessage(HUD_PRINTCENTER, comboMsg);
			PrintMessage(HUD_PRINTTALK, comboMsg);
		end;

		ball:Ignite(30);
	else
		local suicideMsg = entity:Name().." "..suicideMessages[math.random(1, #suicideMessages)];

--		PrintMessage(HUD_PRINTCENTER, suicideMsg);
		PrintMessage(HUD_PRINTTALK, suicideMsg);
	end;

	local sendTable = {
		ball = ball:EntIndex(),
		entity = entity:EntIndex(),
		dmgInfo = dmgInfo,
		data = data,
		bounces = bounces,
		chainNumber = chainNumber,
		chainOrigin = chainOrigin:EntIndex(),
		combo = chainOrigin:GetKills()
	};

	jsonstream.Send("PostCrowBallKillEffects", sendTable, crowOwner);

	local effectData = EffectData();

	effectData:SetOrigin(entity:GetPos());
	effectData:SetEntity(entity);

	util.Effect("Explosion", effectData);
end;

function CrowBall:PostDodgeballDisarm(ball, data, physobj)
	ball:Extinguish();

	ball:StopTrail();
end;

function CrowBall:PreDodgeballDisarm(ball, ballOwner, data, physobj, bounces, chainNumber, chainOrigin)
	local kills = ball:GetKills();

	if (kills > 1) then
		local message = ballOwner:Name().." got "..kills.." kills in one chain!";

--		PrintMessage(HUD_PRINTCENTER, message);
		PrintMessage(HUD_PRINTTALK, message);
	end;
end;

function CrowBall:OnDodgeballCollide(ball, data, physobj, ballOwner, bounces, chainNumber, chainOrigin, kills)
	if (IsValid(ballOwner)) then
		local entity = data.HitEntity;

		if (IsValid(entity)) then
			if (entity:IsPlayer()) then
				local dmgInfo = DamageInfo();
				dmgInfo:SetDamage(entity:Health());
				dmgInfo:SetInflictor(ball);
				dmgInfo:SetAttacker(ballOwner);
				dmgInfo:SetDamageForce(-ball:GetVelocity() * 1000);
				dmgInfo:SetDamageType(DMG_CRUSH);

				if (!Crow.package:CallAll("PreDodgeballKill", ball, entity, ballOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin, kills)) then
					entity:TakeDamageInfo(dmgInfo);

					if (ballOwner != entity) then
						chainOrigin:SetKills(kills + 1);
					end;

					Crow.package:CallAll("PostDodgeballKill", ball, entity, ballOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin, kills);
				end;
			elseif (entity:GetClass() == "dball_dodgeball" and entity:GetBallOwner() != ball:GetBallOwner()) then
				if (!Crow.package:CallAll("PreDodgeballInfect", ball, entity, ballOwner, data, physobj, bounces, chainNumber, chainOrigin)) then

					if (self._DEBUG) then
						entity:SetBallColor(Vector(1, 0, 0));
					end;

					entity:SetBallOwner(ballOwner);

					Crow.package:CallAll("PostDodgeballArmed", entity, entity.isHeld, ballOwner);

					if (!IsValid(entity:GetChainOrigin()) or ballOwner != entity:GetBallOwner()) then
						if (!chainOrigin.chainedBalls) then
							chainOrigin.chainedBalls = {};
						end;

						if (!table.HasValue(chainOrigin.chainedBalls, entity)) then
							chainOrigin.chainedBalls[#chainOrigin.chainedBalls + 1] = entity;
							entity:SetChainNumber(#chainOrigin.chainedBalls);
							entity:SetChainOrigin(chainOrigin);
						end;
					end;

					Crow.package:CallAll("PostDodgeballInfect", ball, entity, ballOwner, data, physobj, bounces, chainNumber, chainOrigin);		
				end;				
			end;
		end;

		if (!ball.isHeld) then
			if (data.Speed <= 100) then
				if (!Crow.package:CallAll("PreDodgeballDisarm", ball, ballOwner, data, physobj, bounces, chainNumber, chainOrigin)) then
					if (self._DEBUG) then
						ball:SetBallColor(Vector(0, 1, 0));
					end;

					ball:ResetValues();

					Crow.package:CallAll("PostDodgeballDisarm", ball, data, physobj);
				end;
			else
				if (!Crow.package:CallAll("PreDodgeballBounce", ball, bounces, ballOwner, data, physobj, chainNumber, chainOrigin)) then
					bounces = bounces + 1;

					ball:SetBounces(bounces);

					if (ball.faded) then
						ball.faded = nil;
					end;

					Crow.package:CallAll("PostDodgeballBounce", ball, bounces, ballOwner, data, physobj, chainNumber, chainOrigin);
				end;
			end;
		end;
	end;
end;

function CrowBall:PostDodgeballBounce(ball, bounces, ballOwner, data, physobj, chainNumber, chainOrigin)
	if (ball:IsOnFire()) then
		local ent = data.HitEntity;
		local pos1 = data.HitPos + data.HitNormal;
		local pos2 = data.HitPos - data.HitNormal;

		if (!IsValid(ent)) then
			ent = game.GetWorld();
		end;

		if (IsValid(ent) or ent:IsWorld()) then
			util.Decal("Scorch", pos1, pos2);
		end;
	end;
end;

function CrowBall:ShowTeam(player)
	jsonstream.Send("CrowBallShowTeam", {}, player);
end;

net.Receive("CrowBallChangeTeam", function(len, player)
--	local newTeam = data[1];
	local newTeam = net.ReadInt(32);
	local oldTeam = player:Team();

	if (!CrowPackage:CallAll("PrePlayerChangeTeam", player, newTeam, oldTeam)) then
		player:SetTeam(newTeam);

		CrowPackage:CallAll("PostPlayerChangeTeam", player, newTeam, oldTeam);
	end;
end);

concommand.Add("crowball", function(ply, cmd, args)
	if (args[1] == "round") then
		if (args[2] == "start") then
			CrowRounds:HandleStart();
		elseif (args[2] == "change") then
			local name = table.concat(args, " ", 3);
			CrowRounds:SetCurrentRound(name);
		end;
	elseif (args[1] == "debug") then
		if (args[2] == "trail") then
			if (args[3] == "set") then
				ply.ballTrail = args[4];
				print(ply:Name().."'s trail set to "..args[4]);
			elseif (args[3] == "reset") then
				ply.ballTrail = nil;
				print(ply:Name().."'s trail set to nil");
			end;
		end;
	end;
end);