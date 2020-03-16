--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Disguise Kit";
ITEM.cost = 70;
ITEM.model = "models/props_lab/box01a.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
ITEM.category = "Reusables"
ITEM.business = true;
ITEM.description = "Allows you to disguise yourself as someone else\nfor two minutes, but it can only be used once.";
ITEM.customFunctions = {"Disguise"};

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item's right click should be handled.
function ITEM:OnHandleRightClick()
	return "Disguise";
end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Disguise") then
			local curTime = CurTime();
			
			if (!player.cwNextUseDisguise or curTime >= player.cwNextUseDisguise) then
				umsg.Start("cwDisguise", player);
				umsg.End();
			else
				Clockwork.player:Notify(player, "You cannot use another disguise kit for "..math.Round(math.ceil(player.cwNextUseDisguise - curTime)).." second(s)!");
			end;
		end;
	end;
end;

Clockwork.item:Register(ITEM);