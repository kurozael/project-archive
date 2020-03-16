--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if (data["stamina"]) then
		data["stamina"] = math.Round(data["stamina"]);
	end;
end;

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	if (!data["Stamina"]) then
		data["Stamina"] = 100;
	end;
end;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("Stamina", 100);
	end;
end;

-- Called when a player attempts to throw a punch.
function PLUGIN:PlayerCanThrowPunch(player)
	if (player:GetCharacterData("Stamina") <= 10) then
		return false;
	end;
end;

-- Called when a player throws a punch.
function PLUGIN:PlayerPunchThrown(player)
	local attribute = Clockwork.attributes:Fraction(player, ATB_STAMINA, 1.5, 0.25);
	local decrease = 5 / (1 + attribute);
	
	player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") - decrease, 0, 100));
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Stamina", math.Round(player:GetCharacterData("Stamina")));
	
	if (player:Alive()) then
		if (player:GetCharacterData("Thirst") == 100) then
			player:BoostAttribute("Thirst", ATB_STAMINA, -50);
		else
			player:BoostAttribute("Thirst", ATB_STAMINA, false);
		end;
	end;
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	local regeneration = 0;
	local attribute = Clockwork.attributes:Fraction(player, ATB_STAMINA, 1, 0.25);
	local decrease = (0.2 + (0.2 - (math.min(player:Health(), 500) / 500))) / (0.2 + attribute);
	
	if (infoTable.isRunning or infoTable.isJogging
	and !Clockwork.player:IsNoClipping(player)) then
		player:SetCharacterData(
			"Stamina", math.Clamp(
				player:GetCharacterData("Stamina") - decrease, 0, 100
			)
		);
		
		if (player:GetCharacterData("Stamina") > 1) then
			if (infoTable.isRunning) then
				player:ProgressAttribute(ATB_STAMINA, 0.025, true);
			elseif (infoTable.isJogging) then
				player:ProgressAttribute(ATB_STAMINA, 0.0125, true);
			end;
		end;
	elseif (player:GetVelocity():Length() == 0) then
		if (player:Crouching()) then
			regeneration = 0.2;
		else
			regeneration = 0.1;
		end;
	else
		regeneration = 0.05;
	end;

	if (regeneration > 0) then
		player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") + regeneration, 0, 100));
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
	
	infoTable.runSpeed = newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina")));
end;