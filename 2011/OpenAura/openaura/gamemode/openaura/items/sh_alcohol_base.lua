--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Alcohol Base";
ITEM.color = Color(255, 0, 255, 255);
ITEM.useText = "Drink";
ITEM.category = "Alcohol";
ITEM.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"};
ITEM.expireTime = 120;
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (self.attributes) then
		for k, v in pairs(self.attributes) do
			player:BoostAttribute(self.name, k, v, self.expireTime);
		end;
	end;
	
	openAura.player:SetDrunk(player, self.expireTime);
	
	if (self.OnDrink) then
		self:OnDrink(player);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);