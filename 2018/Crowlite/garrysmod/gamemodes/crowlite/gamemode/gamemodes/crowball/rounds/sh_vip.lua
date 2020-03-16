local CrowPackage = Crow.nest:GetLibrary("package");
local RoundModule = {};

RoundModule.teamVIPs = RoundModule.teamVIPs or {};

function RoundModule:SetTeamVIP(team, player)
	self.teamVIPs[team] = player;

	if (SERVER) then
		local entIndex = nil;

		if (IsValid(player)) then
			entIndex = player:EntIndex();
		end;

		jsonstream.Send("CrowBallVIPSet", {entIndex}, _team.GetPlayers(team));
	end;
end;

function RoundModule:IsVIP(player)
	return (self.teamVIPs[player:Team()] == player);
end;

if (SERVER) then
	local teamTable = {
		CrowBall._TEAM_BLUE,
		CrowBall._TEAM_RED
	};

	function RoundModule:PostCrowRoundAdvance(newIndex, newStage)
		local roundName = CrowRounds:GetName();

		if (roundName == "Round") then
			for k, v in pairs(teamTable) do
				local player = table.Random(team.GetPlayers(k));

				self:SetTeamVIP(k, player);
			end;
		elseif (roundName == "Warmup") then
			for k, v in pairs(teamTable) do
				self:SetTeamVIP(k, nil);
			end;
		end;
	end;

	function RoundModule:AdjustRoundWinner(results)
		results.tied = false;

		if (self.winner) then
			results.winner = self.winner;
			self.winner = nil;
		else
			results.tied = true;
		end;
	end;

	function RoundModule:GravGunPickupAllowed(player, entity)
		if (CrowRounds:GetName() == "Round" and self:IsVIP(player)) then
			return false;
		end;
	end;

	function RoundModule:PreDodgeballKill(ball, entity, crowOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin)
		if (CrowRounds:GetName() == "Round") then
			local entTeam = entity:Team();
			local plyTeam = crowOwner:Team();

			if (entTeam != plyTeam or entity == crowOwner) then
				if (!self:IsVIP(entity)) then
					crowOwner:TakeDamageInfo(dmgInfo);

					CrowPackage:CallAll("PostDodgeballKill", ball, crowOwner, crowOwner, dmgInfo, data, physobj, bounces, chainNumber, chainOrigin);

					if (self:IsVIP(crowOwner)) then
						self.winner = CrowBall:GetOtherTeam(plyTeam);

						timer.Simple(0.1, function()
							CrowRounds:NextStage();
						end);
					end;

					return true;
				else
					if (entity == crowOwner) then
						self.winner = CrowBall:GetOtherTeam(plyTeam);
					else
						self.winner = plyTeam;
					end;

					timer.Simple(0.1, function()
						CrowRounds:NextStage();
					end);
				end;
			end;
		end;
	end;
else
	function RoundModule:DrawLeftStatBox(client, enemyTeam, clientTeam, x, titleY, textY)
		return true;
	end;

	function RoundModule:DrawRightStatBox(client, enemyTeam, clientTeam, x, titleY, textY)
		return true;
	end;

	jsonstream.Receive("CrowBallVIPSet", function(data)
		local vip = Entity(data[1]);

		if (IsValid(vip)) then
			RoundModule:SetTeamVIP(vip:Team(), vip);
		end;
	end);
end;

CrowRounds:AddRound(4, "VIP", true, nil, RoundModule, "Eliminate the enemy team's VIP to win! Hitting the wrong person will kill you.");