--[[
Name: "sv_hooks.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Called when a player uses a ration.
function MOUNT:PlayerUseRation(player)
	kuroScript.inventory.Update(player, "breens_water", 1, true);
end;

-- Called when kuroScript has loaded all of the entities.
function MOUNT:KuroScriptInitPostEntity()
	self:LoadVendingMachines();
end;

-- Called just after data should be saved.
function MOUNT:PostSaveData()
	self:SaveVendingMachines();
end;

-- Called when a player's character data should be saved.
function MOUNT:PlayerSaveCharacterData(player, data)
	if ( data["stamina"] ) then
		data["stamina"] = math.Round( data["stamina"] );
	end;
end;

-- Called when a player's character data should be restored.
function MOUNT:PlayerRestoreCharacterData(player, data)
	data["stamina"] = data["stamina"] or 100;
end;

-- Called just after a player spawns.
function MOUNT:PostPlayerSpawn(player, lightSpawn, changeVocation, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("stamina", 100);
	end;
end;

-- Called when a player attempts to throw a punch.
function MOUNT:PlayerCanThrowPunch(player)
	if (player:GetCharacterData("stamina") <= 10) then
		return false;
	end;
end;

-- Called when a player throws a punch.
function MOUNT:PlayerPunchThrown(player)
	local attribute = kuroScript.attributes.Get(player, ATB_STAMINA);
	local carrying = (kuroScript.inventory.GetMaximumWeight(player) / 100) * kuroScript.inventory.GetWeight(player);
	local decrease = 10 + (carrying / 5);
	local maximum = 100;
	
	-- Check if a statement is true.
	if (attribute) then
		decrease = decrease / ( 1 + (0.02 * attribute) );
	end;
	
	-- Set some information.
	player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - decrease, 0, maximum) );
end;

-- Called when a player presses a key.
function MOUNT:KeyPress(player, key)
	if ( player:HasInitialized() ) then
		if ( player:Alive() and !player:IsRagdolled() ) then
			if (!player:InVehicle() and player:IsOnGround() and key == IN_JUMP) then
				local attribute = kuroScript.attributes.Get(player, ATB_STAMINA);
				local carrying = (kuroScript.inventory.GetMaximumWeight(player) / 100) * kuroScript.inventory.GetWeight(player);
				local decrease = 10 + (carrying / 5);
				local maximum = 100;
				
				-- Check if a statement is true.
				if (attribute) then
					decrease = decrease / ( 1 + (0.02 * attribute) );
				end;
				
				-- Set some information.
				player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - decrease, 0, maximum) );
			end;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function MOUNT:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "ks_Stamina", math.Round( player:GetCharacterData("stamina") ) );
end;

-- Called at an interval while a player is connected.
function MOUNT:PlayerThink(player, curTime, infoTable)
	local maximum = 100;
	
	-- Check if a statement is true.
	if (infoTable.running or infoTable.jogging) then
		local attribute = kuroScript.attributes.Get(player, ATB_STAMINA);
		local carrying = (kuroScript.inventory.GetMaximumWeight(player) / 100) * kuroScript.inventory.GetWeight(player);
		local decrease = 3 + (carrying / 40) + ( 1 - (math.min(player:Health(), 100) / 100) );
		
		-- Check if a statement is true.
		if (attribute) then
			decrease = decrease / ( 1 + (0.02 * attribute) );
		end;
		
		-- Check if a statement is true.
		if (jogging) then
			decrease = decrease / 2;
		end;
		
		-- Set some character data.
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") - decrease, 0, maximum) );
		
		-- Check if a statement is true.
		if (player:GetCharacterData("stamina") > 1) then
			if (infoTable.running) then
				kuroScript.attributes.Progress(player, ATB_STAMINA, 0.125, true);
			elseif (infoTable.jogging) then
				kuroScript.attributes.Progress(player, ATB_STAMINA, 0.0625, true);
			end;
		end;
	else
		player:SetCharacterData( "stamina", math.Clamp(player:GetCharacterData("stamina") + 2 - ( 1 - (math.min(player:Health(), 100) / 100) ), 0, maximum) );
	end;
	
	-- Check if a statement is true.
	if (player:GetCharacterData("stamina") <= 1) then
		infoTable.running = false;
		infoTable.jogging = false;
	end;
end;