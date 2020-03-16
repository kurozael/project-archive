--[[
Name: "sh_alcohol_base.lua".
Product: "nexus".
--]]

local ITEM = {};

ITEM.name = "Alcohol Base";
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
	
	nexus.player.SetDrunk(player, self.expireTime);
	
	if (self.OnDrink) then
		self:OnDrink(player);
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

nexus.item.Register(ITEM);