--[[
Name: "sh_cyanide.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Cyanide";
ITEM.model = "models/props_junk/garbage_plasticbottle002a.mdl";
ITEM.weight = 0.6;
ITEM.useText = "Drinks";
ITEM.description = "A bottle of cyanide, warnings are plastered all over it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local function drinkCyanide(player)
		if ( ValidEntity(player) and player:Alive() ) then
			player:TakeDamage(1, player, player);
			
			-- Check if a statement is true.
			if ( player:Health() > 0 and player:Alive() ) then
				timer.Simple(1, drinkCyanide, player);
			end;
		end;
	end;
	
	-- Set some information.
	timer.Simple(1, drinkCyanide, player);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Register the item.
kuroScript.item.Register(ITEM);