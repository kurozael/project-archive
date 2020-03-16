--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player uses an item.
function PLUGIN:PlayerUseItem(player, itemTable)
	if (itemTable.category == "Consumables" or itemTable.category == "Alcohol") then
		player:SetCharacterData("stamina", 100);
	end;
end;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if ( data["stamina"] ) then
		data["stamina"] = math.Round( data["stamina"] );
	end;
end;

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["stamina"] = data["stamina"] or 100;
end;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("stamina", 100);
	end;
end;

-- Called when a player attempts to throw a punch.
function PLUGIN:PlayerCanThrowPunch(player)
	if (player:GetCharacterData("stamina") <= 10) then
		return false;
	end;
end;

-- Called when a player throws a punch.
function PLUGIN:PlayerPunchThrown(player)
	local carrying = (openAura.inventory:GetMaximumWeight(player) / 100) * openAura.inventory:GetWeight(player);
	local decrease = 5 + (carrying / 5)
	
	player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - decrease, 0, 100) );
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "stamina", math.Round( player:GetCharacterData("stamina") ) );
end;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player, curTime, infoTable)
	local regeneration = 0;
	
	if ( infoTable.running or infoTable.jogging and !openAura.player:IsNoClipping(player) ) then
		local attribute = openAura.attributes:Fraction(player, ATB_STAMINA, 1, 0.25);
		local carrying = (openAura.inventory:GetMaximumWeight(player) / 100) * openAura.inventory:GetWeight(player);
		local decrease = ( 1 + (carrying / 40) + ( 1 - (math.min(player:Health(), 100) / 100) ) ) / (1 + attribute);
		
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - decrease, 0, 100) );
	elseif (player:GetVelocity():Length() == 0) then
		if ( player:Crouching() ) then
			regeneration = 1;
		else
			regeneration = 0.5;
		end;
	else
		regeneration = 0.25;
	end;

	if (regeneration > 0) then
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") + regeneration, 0, 100) );
	end;
	
	local newRunSpeed = infoTable.runSpeed * 2;
	local diffRunSpeed = newRunSpeed - infoTable.walkSpeed;
	
	infoTable.runSpeed = newRunSpeed - ( diffRunSpeed - ( (diffRunSpeed / 100) * player:GetCharacterData("stamina") ) );
end;