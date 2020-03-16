--[[ 
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;
local CrowPackage = CrowNest:GetLibrary("package");

--[[ Called whenever the player spawns. --]]
function Crow:PlayerSpawn(player)
	if (!CrowPackage:CallAll("PrePlayerSpawn", player)) then
		self.BaseClass:PlayerSpawn(player);

		CrowPackage:CallAll("PostPlayerSpawn", player);
	end;
end;

--[[ Called to create the teams for a teambased gamemode. --]]
function Crow:CreateTeams()
end;

--[[ Called before the player spawns. --]]
function Crow:PrePlayerSpawn(player) end;

--[[ Called after the player spawns. --]]
function Crow:PostPlayerSpawn(player) end;

--[[ Called when a player has connected and been authorized. --]]
function Crow:PlayerAuthed(player)
	timer.Simple(0.1, function()
		jsonstream.Send("crow-init", {Crow.nest.__bootdata, CrowPackage:GetActiveGamemode().folderName}, player);
	--	jsonstream.Send("crow-gamemode", {CrowPackage:GetActiveGamemode().folderName}, player);
	end);

	player.crowAuthed = nil;
end;

--[[ Called every tick on a player when they are dead. --]]
function Crow:PlayerDeathThink(player)
	local result = CrowPackage:CallAll("DoPlayerDeathThink", player);

	if (result) then
		player:Spawn();

		local post = CrowPackage:CallAll("PostPlayerDeathThink", player);
	end;
end;

function Crow:PlayerCanJoinTeam(player, newTeam)
	local result = CrowPackage:CallAll("PrePlayerCanJoinTeam", player, newTeam);

	if (result == false) then
		return false;		
	end;

	return true;
end;