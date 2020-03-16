--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when a player's character data should be saved.
function MOUNT:PlayerSaveCharacterData(player, data)
	data["flashlight"] = math.Round( data["flashlight"] );
end;

-- Called when a player's character data should be restored.
function MOUNT:PlayerRestoreCharacterData(player, data)
	data["flashlight"] = data["flashlight"] or 100;
end;

-- Called just after a player spawns.
function MOUNT:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("flashlight", 100);
	end;
end;

-- Called when a player switches their flashlight on or off.
function MOUNT:PlayerSwitchFlashlight(player, on)
	local flashlight = player:GetCharacterData("flashlight");
	
	-- Check if a statement is true.
	if (flashlight) then
		local depleted = (flashlight < 10 and flashlight != -1);
		
		-- Check if a statement is true.
		if ( on and ( depleted or !self:PlayerHasFlashlight(player) ) ) then
			return false;
		end;
	else
		return false;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "ks_Flashlight", math.Round( player:GetCharacterData("flashlight") ) );
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	if (player:GetCharacterData("flashlight") != -1) then
		if ( !kuroScript.game.scanners[player] ) then
			if ( player:FlashlightIsOn() ) then
				if ( !self:PlayerHasFlashlight(player) ) then
					player:Flashlight(false);
				else
					player:SetCharacterData( "flashlight", math.Clamp(player:GetCharacterData("flashlight") - 1, 0, 100) );
					
					-- Check the player's stamina to see if it's at its maximum.
					if (player:GetCharacterData("flashlight") == 0) then
						player:Flashlight(false);
					end;
				end;
			else
				player:SetCharacterData( "flashlight", math.Clamp(player:GetCharacterData("flashlight") + 0.5, 0, 100) );
			end;
		end;
	end;
end;