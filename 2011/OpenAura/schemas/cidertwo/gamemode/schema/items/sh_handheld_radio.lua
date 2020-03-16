--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Handheld Radio";
ITEM.cost = 15;
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_MERCHANT};
ITEM.category = "Communication";
ITEM.business = true;
ITEM.description = "A shiny handheld radio with a frequency tuner.";
ITEM.customFunctions = {"Frequency"};

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item's right click should be handled.
function ITEM:OnHandleRightClick()
	return "Frequency";
end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Frequency") then
			umsg.Start("aura_Frequency", player);
				umsg.String( player:GetCharacterData("frequency", "") );
			umsg.End();
		end;
	end;
end;

openAura.item:Register(ITEM);