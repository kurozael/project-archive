--[[
Name: "cl_init.lua".
Product: "kuroScript".
--]]

include("sh_init.lua")

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
			y = kuroScript.frame:DrawInfo(itemTable.name, x, y, Color(200, 100, 50, 255), alpha);
			
			-- Check if a statement is true.
			if (itemTable.OnUse) then
				y = kuroScript.frame:DrawInfo("Quick "..(itemTable.useText or "Use")..": Sprint + Use", x, y, COLOR_INFORMATION, alpha);
			end;
			
			-- Check if a statement is true.
			if (itemTable.weight == 1) then
				y = kuroScript.frame:DrawInfo(itemTable.weight.." Kilogram", x, y, COLOR_WHITE, alpha);
			else
				y = kuroScript.frame:DrawInfo(itemTable.weight.." Kilograms", x, y, COLOR_WHITE, alpha);
			end;
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