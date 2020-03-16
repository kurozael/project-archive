--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura:IncludePrefixed("sh_auto.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = openAura.option:GetColor("target_id");
	local colorWhite = openAura.option:GetColor("white");
	local index = self:GetDTInt("index");
	
	if (index != 0) then
		local itemTable = openAura.item:Get(index);
		
		if (itemTable) then
			y = openAura:DrawInfo(itemTable.name, x, y, itemTable.color or colorTargetID, alpha);
			
			if (itemTable.weightText) then
				y = openAura:DrawInfo(itemTable.weightText, x, y, colorWhite, alpha);
			else
				y = openAura:DrawInfo(itemTable.weight.."kg", x, y, colorWhite, alpha);
			end;
		end;
	end;
end;

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
end;