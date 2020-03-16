--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to take a player's legs.
function MOUNT:TakeAnimatedLegs(player)
	if ( IsValid(player.animatedLegs) ) then
		player.animatedLegs:Remove();
	end;
	
	player.animatedLegs = nil;
end;

-- A function to give a player some legs.
function MOUNT:GiveAnimatedLegs(player)
	self:TakeAnimatedLegs(player);
	
	local legs = ents.Create("nx_legs");
		legs:DrawShadow(false);
		legs:SetParent(player);
		legs:SetModel( player:GetModel() );
		legs:SetOwner(player);
		legs:SetPos( player:GetPos() );
		legs:Spawn();
	player.animatedLegs = legs;
end;