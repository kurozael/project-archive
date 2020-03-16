--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local index = self:GetSharedVar("ks_Index");
	
	-- Check if a statement is true.
	if (index != 0) then
		local itemTable = kuroScript.item.Get(index);
		
		-- Check if a statement is true.
		if (itemTable) then
			local owner = kuroScript.entity.GetOwner(self);
			
			-- Draw some information.
			y = kuroScript.frame:DrawInfo(itemTable.name, x, y, Color(175, 100, 150, 255), alpha);
			y = kuroScript.frame:DrawInfo("Press Use", x, y, COLOR_WHITE, alpha);
		end;
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;