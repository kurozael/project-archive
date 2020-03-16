local RoundModule = {};

function team.GetAllLives(teamIndex)
	local sum = 0;

	for k, v in pairs(team.GetPlayers(teamIndex)) do
		if (v.eliminationLives) then
			sum = math.Max(sum + v.eliminationLives, 0);
		end;
	end;

	return sum;
end;

function team.SetReserveLives(teamIndex)

end;

function team.GetReserveLives(teamIndex)
end;

if (SERVER) then
	function RoundModule:AdjustRoundWinner(results)
		results.tied = false;

		if (team.GetAllLives(results.blue) < team.GetAllLives(results.red)) then
			results.winner = results.red;
		elseif (team.GetAllLives(results.blue) > team.GetAllLives(results.red)) then
			results.winner = results.blue;
		else
			results.tied = true;
		end;
	end;

	function RoundModule:PostPlayerDeath(player)
		if (CrowRounds:GetName() == "Round") then
			if (!player.eliminationLives) then
				RoundModule:SetLives(player, CrowBall._ELIMINATION_LIVES or 3);
			else
				RoundModule:SetLives(player, math.Max(player.eliminationLives - 1, 0));
			end;

			if (player.eliminationLives == 0) then
				local teamIndex = player:Team();
				local teamDeaths = team.TotalDeaths(teamIndex);
				local maxDeaths = team.NumPlayers(teamIndex) * CrowBall._ELIMINATION_LIVES;

				player.queueTeam = teamIndex;

				if (maxDeaths - teamDeaths <= 0) then
					CrowRounds:NextStage();
				end;
			end;		
		end;
	end;

	function RoundModule:PrePlayerChangeTeam(player, plyTeam)
		if (CrowRounds:GetName() == "Round" and plyTeam != TEAM_SPECTATOR and !player:IsBot()) then
			player.queueTeam = plyTeam;
			player:SetTeam(TEAM_SPECTATOR);
			player:Spawn();

			return true;
		end;
	end;

	function RoundModule:DoPlayerDeathThink(player)
		if (player.eliminationLives and player.eliminationLives <= 0 and CrowRounds:GetName() == "Round") then
			local curTime = CurTime();

			if (!player.deathTimer) then
				player.deathTimer = curTime + 3
			elseif (player.deathTimer <= curTime) then
				player.queueTeam = player:Team();
				player:SetTeam(TEAM_SPECTATOR);

				return true;
			end;

			return false;
		end;
	end;

	function RoundModule:PostCrowRoundAdvance(newIndex, newStage)
		local players = _player.GetAll();

		for k, v in pairs(players) do
			if (v.queueTeam) then
				v:SetTeam(v.queueTeam);
				v.queueTeam = nil;
			end;

			v.eliminationLives = nil;
		end;

		RoundModule:SyncAllLives(players);
	end;

	function RoundModule:SyncAllLives(player)
		local sendTable = {};

		for k, v in pairs(_player.GetAll()) do
			sendTable[v:EntIndex()] = v.eliminationLives;	
		end;

		jsonstream.Send("CrowBallEliminationLives", sendTable, player);
	end;

	function RoundModule:SyncLives(player, target)
		jsonstream.Send("CrowBallEliminationLives", {[player:EntIndex()] = player.eliminationLives}, target);
	end;

	function RoundModule:SetLives(player, lives)
		player.eliminationLives = lives;

		RoundModule:SyncLives(player, _player.GetAll());
	end;
else
	jsonstream.Receive("CrowBallEliminationLives", function(data)
		for k, v in pairs(data) do
			Entity(k).eliminationLives = v;
		end;
	end);

	local timerFont = "CrowBallHUDNormal";
	local titleFont = "CrowBallHUDTiny";
	local colorWhite = Color(255, 255, 255, 255);

	function RoundModule:DrawLeftStatBox(client, enemyTeam, clientTeam, x, titleY, textY)
		draw.SimpleText(team.GetAllLives(clientTeam), timerFont, x, textY, colorWhite, TEXT_ALIGN_CENTER);
		draw.SimpleText(string.gsub(team.GetName(clientTeam), "Team", "Lives"), titleFont, x, titleY, colorWhite, TEXT_ALIGN_CENTER);

		return true;
	end;

	function RoundModule:DrawRightStatBox(client, enemyTeam, clientTeam, x, titleY, textY)
		draw.SimpleText(team.GetAllLives(enemyTeam), timerFont, x, textY, colorWhite, TEXT_ALIGN_CENTER);
		draw.SimpleText(string.gsub(team.GetName(enemyTeam), "Team", "Lives"), titleFont, x, titleY, colorWhite, TEXT_ALIGN_CENTER);

		return true;
	end;
end;

CrowRounds:AddRound(3, "Elimination", true, nil, RoundModule, "Last team standing, bring the other team's lives to zero to win!");