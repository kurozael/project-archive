--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

usermessage.Hook("aura_ViewBook", function(msg)
	local entity = msg:ReadEntity();
	
	if ( IsValid(entity) ) then
		local index = entity:GetDTInt("index");
		
		if (index != 0) then
			local itemTable = openAura.item:Get(index);
			
			if (itemTable and itemTable.bookInformation) then
				if ( IsValid(PLUGIN.bookPanel) ) then
					PLUGIN.bookPanel:Close();
					PLUGIN.bookPanel:Remove();
				end;
				
				PLUGIN.bookPanel = vgui.Create("aura_ViewBook");
				PLUGIN.bookPanel:SetEntity(entity);
				PLUGIN.bookPanel:Populate(itemTable);
				PLUGIN.bookPanel:MakePopup();
			end;
		end;
	end;
end);