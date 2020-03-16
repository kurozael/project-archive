--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Notepad";
ITEM.cost = 80;
ITEM.model = "models/props_lab/clipboard.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Edit";
ITEM.business = true;
ITEM.category = "Reusables";
ITEM.description = "A clean and professional notepad with a cardboard backing.";

--[[ Add the data type for storing the notepad text. --]]
ITEM:AddData("Text", "");
ITEM:AddData("Hint", "", true);

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	Clockwork:StartDataStream(player, "Notepad", {
		definition = Clockwork.item:GetDefinition(self),
		text = self:GetData("Text")
	});
	
	Clockwork.player:SetMenuOpen(player, false);
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		local clientSideInfo = "";
		local itemHint = self:GetData("Hint");
		
		if (itemHint != "") then
			clientSideInfo = Clockwork:AddMarkupLine(clientSideInfo, itemHint);
		end;
		
		return (clientSideInfo != "" and clientSideInfo);
	end;
end;

Clockwork.item:Register(ITEM);