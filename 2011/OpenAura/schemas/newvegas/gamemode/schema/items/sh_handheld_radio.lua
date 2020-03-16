--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Handheld Radio";
ITEM.cost = 50;
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.category = "Communication"
ITEM.description = "A shiny handheld radio with a frequency tuner.";
ITEM.customFunctions = {"Frequency"};

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

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