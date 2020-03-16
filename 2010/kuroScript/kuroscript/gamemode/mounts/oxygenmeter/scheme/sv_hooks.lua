--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player's character data should be saved.
function MOUNT:PlayerSaveCharacterData(player, data)
	data["oxygen"] = math.Round( data["oxygen"] );
end;

-- Called when a player's character data should be restored.
function MOUNT:PlayerRestoreCharacterData(player, data)
	data["oxygen"] = data["oxygen"] or 100;
end;

-- Called just after a player spawns.
function MOUNT:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("oxygen", 100);
	end;
end;

-- Called when a player's character screen info should be adjusted.
function MOUNT:PlayerAdjustCharacterScreenInfo(player, character, info)
	if ( character._Data["oxygen"] ) then
		if (character._Data["oxygen"] <= 25) then
			info.tags["Suffocating"] = true;
		elseif (character._Data["oxygen"] <= 50) then
			info.tags["Breathless"] = true;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "ks_Oxygen", math.Round( player:GetCharacterData("oxygen") ) );
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if ( player:Alive() ) then
		if (player:WaterLevel() > 2) then
			player:SetCharacterData( "oxygen", math.Clamp(player:GetCharacterData("oxygen") - 1, 0, 100) );
			
			-- Check if a statement is true.
			if (player:GetCharacterData("oxygen") == 0) then
				local world = GetWorldEntity();
				
				-- Damage the player.
				player:TakeDamage(2, world, world);
			end;
		else
			player:SetCharacterData( "oxygen", math.Clamp(player:GetCharacterData("oxygen") + 2, 0, 100) );
		end;
	end;
end;