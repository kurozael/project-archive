--[[
	© CloudSixteen.com
	http://crowlite.com/license
--]]

--[[ Localized Dependencies ]]--
local Crow = Crow;
local CrowNest = Crow.nest;

--[[ Localize Tables --]]
local _player = _player;
local string = string;
local table = table;
local util = util;
local ents = ents;

--[[ Localize Methods --]]
local IsPlayer = IsPlayer;
local pairs = pairs;
local type = type;

--[[ Create Library --]]
local CrowPlayer = CrowNest:GetLibrary("player");

--[[
	@codebase Shared
	@details A function to find a player by their name.
	@params String The name of the player to search for.
	@returns Player The player entity, if found.
--]]
function CrowPlayer:FindByID(identifier)
	for k, v in pairs(_player.GetAll()) do
		if (v:SteamID() == identifier
		or string.find(string.lower(v:Name()), string.lower(identifier), 1, true)) then
			return v;
		end;
	end;
end;

--[[
	@codebase Shared
	@details A function to find if a player is using noclip and not inside a vehicle.
	@params Player The player entity to check.
	@returns Bool Whether or not the player is in noclip and not in a vechicle.
--]]
function CrowPlayer:IsNoClipping(player)
	return (player:GetMoveType() == MOVETYPE_NOCLIP and !player:InVehicle());
end;

--[[
	@codebase Shared
	@details A function to find if a player has an admin usergroup or not.
	@params Player The player entity to check.
	@returns Bool Whether or not the player has an admin usergroup.
--]]
function CrowPlayer:IsAdmin(player)
	return (player:IsAdmin() or player:IsSuperAdmin());
end;

--[[
	@codebase Shared
	@details A function to check whether there is a direct line of sight between a player and a position.
	@params Player The player entity to check.
	@params Vector The position to check.
	@params Number The minimum fraction of the trace that needs to be used to be considered in line of sight.
	@params Table The table of ents to be ignored, defaults to all entities with ents.GetAll.
	@params Entity The entity that is the owner of the position if applicable (used by the other CanSee functions).
	@returns Bool Whether or not the position is in the player's line of sight.
--]]
function CrowPlayer:CanSeePosition(player, position, allowance, ignoreEnts, target)
	local trace = {};

	trace.filter = {player};

	if (target and IsEntity(target)) then
		if (player:GetEyeTraceNoCursor().Entity == target) then
			return true;
		end;

		if (IsPlayer(target)) then
			if (target:GetEyeTraceNoCursor().Entity == player) then
				return true;
			end;
		end;

		table.insert(trace.filter, target);
	end;

	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add(trace.filter, ents.GetAll());
		end;
	end;

	trace = util.TraceLine(trace);

	if (trace.Fraction >= (allowance or 0.75)) then
		return true;
	end;

	return false;
end;

--[[
	@codebase Shared
	@details A function to check whether there is a direct line of sight between a player and an NPC.
	@params Player The player entity to check.
	@params Entity The NPC entity that is being checked.
	@params Number The minimum fraction of the trace that needs to be used to be considered in line of sight.
	@params Table The table of ents to be ignored, defaults to all entities with ents.GetAll.
	@returns Bool Whether or not the target is in the player's line of sight.
--]]
function CrowPlayer:CanSeeNPC(player, target, allowance, ignoreEnts)
	self:CanSeePosition(player, target:GetShootPos(), allowance, ignoreEnts, target);
end;

--[[
	@codebase Shared
	@details A function to check whether there is a direct line of sight between two players.
	@params Player The player entity to check.
	@params Entity The other player entity that is being checked.
	@params Number The minimum fraction of the trace that needs to be used to be considered in line of sight.
	@params Table The table of ents to be ignored, defaults to all entities with ents.GetAll.
	@returns Bool Whether or not the target is in the player's line of sight.
--]]
function CrowPlayer:CanSeePlayer(player, target, allowance, ignoreEnts)
	self:CanSeePosition(player, target:GetShootPos(), allowance, ignoreEnts, target);
end;

--[[
	@codebase Shared
	@details A function to check whether there is a direct line of sight between a player and an entity.
	@params Player The player entity to check.
	@params Entity The entity that is being checked.
	@params Number The minimum fraction of the trace that needs to be used to be considered in line of sight.
	@params Table The table of ents to be ignored, defaults to all entities with ents.GetAll.
	@returns Bool Whether or not the target is in the player's line of sight.
--]]
function CrowPlayer:CanSeeEntity(player, target, allowance, ignoreEnts)
	self:CanSeePosition(player, target:LocalToWorld(target:OBBCenter()), allowance, ignoreEnts, target);
end;