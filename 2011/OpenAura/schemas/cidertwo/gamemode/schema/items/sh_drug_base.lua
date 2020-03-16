--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Drug Base";
ITEM.model = "models/cocn.mdl";
ITEM.weight = 0.1;
ITEM.useText = "Get High";
ITEM.attributes = {};
ITEM.expireTime = 3600;
ITEM.isBaseItem = true;
ITEM.description = "A generic illegal high, feels good man.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local action = openAura.player:GetAction(player);
	
	if (action != "drug") then
		local consumeTime = openAura.schema:GetDexterityTime(player);
		
		openAura.player:SetAction(player, "drug", consumeTime, nil, function()
			if ( IsValid(player) ) then
				umsg.Start("aura_GetHigh", player);
					umsg.Long(self.expireTime / 3);
				umsg.End();
				
				openAura.player:SetDrunk(player, self.expireTime / 8);
				
				player:UpdateInventory(self.uniqueID, -1);
				
				for k, v in pairs(self.attributes) do
					player:BoostAttribute(self.name, k, v, self.expireTime);
				end;
				
				openAura.plugin:Call("PlayerGetHighOnDrug", player, self);
				
				if (self.OnGetHigh) then
					self:OnGetHigh(player);
				end;
			end;
		end);
		
		openAura.player:SetMenuOpen(player, false);
		
		if (itemEntity) then
			return true;
		else
			return false;
		end;
	else
		openAura.player:Notify(player, "Your character is already getting high!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	local action = openAura.player:GetAction(player);
	
	if (action == "drug") then
		openAura.player:Notify(player, "Your character is already getting high!");
		
		return false;
	end;
end;

openAura.item:Register(ITEM);