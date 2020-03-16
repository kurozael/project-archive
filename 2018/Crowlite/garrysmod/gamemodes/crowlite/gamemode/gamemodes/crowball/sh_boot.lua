--[[
	© CloudSixteen.com
	http://crowlite.com/license
--]]

Crow.nest:IncludeFile("sh_enum.lua");
Crow.nest:IncludeFile("sv_hooks.lua");
Crow.nest:IncludeFile("cl_hooks.lua");

CrowBall.build = "Alpha";

function CrowBall:CreateTeams()
	team.SetUp(self._TEAM_BLUE, "Blue Team", Color(0, 100, 255, 255), true);
	team.SetUp(self._TEAM_RED, "Red Team", Color(255, 0, 0, 255), true);

	team.SetSpawnPoint(self._TEAM_BLUE, {"info_player_blue"});
	team.SetSpawnPoint(self._TEAM_RED, {"info_player_red"});
end;

function CrowBall:PlayerNoClip(player, desired)
	if (!player:IsAdmin() and desired == true) then
		return false;
	end;
end;

function CrowBall:GetOtherTeam(teamIndex)
	local result = self._TEAM_BLUE;

	if (teamIndex == result) then
		result = self._TEAM_RED;
	end;

	return result;
end;
	
function CrowBall:OnInitialize()
	--[[ Add The Simple Rounds --]]
	CrowRounds:AddRound(1, "Time Attack", true, nil, nil, "Get the most amount of kills before the timer runs out to win!");
	
	--[[ Temporary Options --]]
	self._DEBUG 			= false;
	self._MINIMUM_PLAYERS 	= 2;
	self._BALL_NUMBER 		= 9;
	self._SPAWN_IMMUNITY 	= 3;
	self._RESPAWN_TIMER 	= 1;
	self._ELIMINATION_LIVES = 1;
	self._COMBO_TIME 		= 3;

	if (!team.Valid(self._TEAM_BLUE) or team.GetName(self._TEAM_BLUE) != "Blue Team") then
		self:CreateTeams();
	end;

	if (SERVER) then
		util.AddNetworkString("CrowBallChangeTeam");

		if (#_player.GetAll() >= self._MINIMUM_PLAYERS) then
			CrowRounds:HandleStart();
		else
			self:AutoAssignTeams();
			self:ResetGame();
		end;
	end;
end;

function CrowBall:OnUnloaded()
	if (SERVER) then
		game.CleanUpMap();

		for k, v in pairs(_player.GetAll()) do
			local color = v:GetColor();				
				
			v:SetColor(color.r, color.g, color.b, 255);
			v:SetTeam(TEAM_UNASSIGNED);
		end;

		CrowRounds:StopRound();
	end;
end;