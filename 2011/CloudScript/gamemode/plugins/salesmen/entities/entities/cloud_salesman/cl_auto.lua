--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = CloudScript.option:GetColor("target_id");
	local colorWhite = CloudScript.option:GetColor("white");
	local physDesc = self:GetSharedVar("physDesc");
	local name = self:GetSharedVar("name");
	
	y = CloudScript:DrawInfo(name, x, y, colorTargetID, alpha);
	
	if (physDesc != "") then
		y = CloudScript:DrawInfo(physDesc, x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	self.AutomaticFrameAdvance = true;
end;

-- Called every frame.
function ENT:Think()
	self:FrameAdvance( FrameTime() );
	self:NextThink( CurTime() );
end;