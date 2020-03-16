--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to take a player's legs.
function MOUNT:TakeAnimatedLegs(player)
	if ( ValidEntity(player._AnimatedLegs) ) then
		player._AnimatedLegs:Remove();
	end;
	
	-- Set some information.
	player._AnimatedLegs = nil;
end;

-- A function to give a player some legs.
function MOUNT:GiveAnimatedLegs(player)
	self:TakeAnimatedLegs(player);
	
	-- Set some information.
	local legs = ents.Create("ks_legs");
	
	-- Check if a statement is true.
	if ( !player:InVehicle() ) then
		legs:SetPos( player:GetPos() + ( player:GetForward() * -16 ) );
	elseif ( ValidEntity( player:GetVehicle() ) ) then
		if ( kuroScript.entity.IsChairEntity( player:GetVehicle() ) ) then
			legs:SetPos( player:GetPos() + ( player:GetForward() * -8 ) );
		else
			legs:SetPos( player:GetPos() );
		end;
	else
		legs:SetPos( player:GetPos() + ( player:GetForward() * -8 ) );
	end;
	
	-- Set some information.
	legs:SetAngles( Angle(0, (player:GetAngles().y), 0) );
	legs:DrawShadow(false);
	legs:SetParent(player);
	legs:SetModel( player:GetModel() );
	legs:SetOwner(player);
	legs:Spawn();
	
	-- Set some information.
	player._AnimatedLegs = legs;
end;