--[[
Name: "sv_auto.lua".
Product: "blueprint".
--]]

BLUEPRINT:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SetModel("models/weapons/w_bugbait.mdl");
	self:SetSolid(SOLID_NONE);
	self:SetNoDraw(true);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_BBOX);
end;

-- Called when the entity is used.
function ENT:Use(activator, caller) end;

-- Called each frame.
function ENT:Think()
	local dayAndNight = blueprint.plugin.Get("Day and Night");
	local minute = blueprint.time.GetMinute();
	
	if ( dayAndNight and blueprint.config.Get("daynight_enabled"):Get() ) then
		if (!dayAndNight.lastMinute or minute != dayAndNight.lastMinute) then
			dayAndNight:CalculateLight();
			dayAndNight.lastMinute = minute;
		end;
	end;
end;