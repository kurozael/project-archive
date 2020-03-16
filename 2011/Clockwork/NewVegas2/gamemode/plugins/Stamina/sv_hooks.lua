--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player uses an item.
function PLUGIN:PlayerUseItem(player, itemTable)
	if (itemTable("category") == "Consumables" or itemTable("category") == "Alcohol") then
		player:SetCharacterData("Stamina", 100);
	end;
end;

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
	player:SetCharacterData("Stamina", math.Clamp(player:GetCharacterData("Stamina") - 5, 0, 100));
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar("Stamina", math.Round(player:GetCharacterData("Stamina")));
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
		player:SetCharacterData(
			"Stamina", math.Clamp(player:GetCharacterData("Stamina") + regeneration, 0, 100)
		);
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
	
	infoTable.runSpeed = newRunSpeed - (diffRunSpeed - ((diffRunSpeed / 100) * player:GetCharacterData("Stamina")));
end;