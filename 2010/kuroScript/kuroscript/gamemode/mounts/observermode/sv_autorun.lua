--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to make a player exit observer mode.
function MOUNT:MakePlayerExitObserverMode(player)
	kuroScript.player.NotifyAll(player:Name().." has exited observer mode.");
	
	-- Set the player's move type.
	player:SetMoveType(player._ObserverMoveType or MOVETYPE_WALK);
	
	-- Check if a statement is true.
	if (player._ObserverPosition) then
		player:SetPos(player._ObserverPosition);
	end;
	
	-- Check if a statement is true.
	if (player._ObserverAngles) then
		player:SetEyeAngles(player._ObserverAngles);
	end;
	
	-- Check if a statement is true.
	if (player._ObserverColor) then
		player:SetColor( unpack(player._ObserverColor) );
	end;
	
	-- Set some information.
	player._ObserverMoveType = nil;
	player._ObserverPosition = nil;
	player._ObserverAngles = nil;
	player._ObserverMode = nil;
end;

-- A function to make a player enter observer mode.
function MOUNT:MakePlayerEnterObserverMode(player)
	kuroScript.player.NotifyAll(player:Name().." has entered observer mode.");
	
	-- Set some information.
	player._ObserverMoveType = player:GetMoveType();
	player._ObserverPosition = player:GetPos();
	player._ObserverAngles = player:EyeAngles();
	player._ObserverColor = { player:GetColor() };
	player._ObserverMode = true;
	
	-- Set the player's move type.
	player:SetMoveType(MOVETYPE_NOCLIP);
end;