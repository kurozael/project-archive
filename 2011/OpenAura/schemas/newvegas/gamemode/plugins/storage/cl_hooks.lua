--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when an entity's target ID HUD should be painted.
function PLUGIN:HUDPaintEntityTargetID(entity, info)
	local colorWhite = openAura.option:GetColor("white");
	
	if ( openAura.entity:IsPhysicsEntity(entity) ) then
		local model = string.lower( entity:GetModel() );
		
		if ( self.containers[model] ) then
			if (entity:GetNetworkedString("name") != "") then
				info.y = openAura:DrawInfo(entity:GetNetworkedString("name"), info.x, info.y, colorWhite, info.alpha);
			end;
		end;
	end;
end;

-- Called when an entity's menu options are needed.
function PLUGIN:GetEntityMenuOptions(entity, options)
	if ( openAura.entity:IsPhysicsEntity(entity) ) then
		local model = string.lower( entity:GetModel() );
		
		if ( self.containers[model] ) then
			options["Open"] = "aura_containerOpen";
		end;
	end;
end;

-- Called when the local player's storage is rebuilt.
function PLUGIN:PlayerStorageRebuilt(panel, categories)
	if (panel.name == "Container") then
		local entity = openAura.storage:GetEntity();
		
		if (IsValid(entity) and entity.message) then
			local messageForm = vgui.Create("DForm", panel);
			local helpText = messageForm:Help(entity.message);
			
			messageForm:SetPadding(5);
			messageForm:SetName("Message");
			helpText:SetFont("Default");
			
			panel:AddItem(messageForm);
		end;
	end;
end;