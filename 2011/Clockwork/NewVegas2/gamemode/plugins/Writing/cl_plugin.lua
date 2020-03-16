--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork:HookDataStream("ViewPaper", function(data)
	local PLUGIN = Clockwork.plugin:FindByID("Writing");
	
	if (IsValid(data[1])) then
		if (IsValid(PLUGIN.paperPanel)) then
			PLUGIN.paperPanel:Close();
			PLUGIN.paperPanel:Remove();
		end;
		
		if (!data[3]) then
			local uniqueID = data[2];
			
			if (PLUGIN.paperIDs[uniqueID]) then
				data[3] = PLUGIN.paperIDs[uniqueID];
			else
				data[3] = "Error!";
			end;
		else
			local uniqueID = data[2];
			
			PLUGIN.paperIDs[uniqueID] = data[3];
		end;
		
		PLUGIN.paperPanel = vgui.Create("cwViewPaper");
		PLUGIN.paperPanel:SetEntity(data[1]);
		PLUGIN.paperPanel:Populate(data[3]);
		PLUGIN.paperPanel:MakePopup();
		
		gui.EnableScreenClicker(true);
	end;
end);

usermessage.Hook("cwEditPaper", function(msg)
	local entity = msg:ReadEntity();
	local PLUGIN = Clockwork.plugin:FindByID("Writing");
	
	if (IsValid(entity)) then
		if (IsValid(PLUGIN.paperPanel)) then
			PLUGIN.paperPanel:Close();
			PLUGIN.paperPanel:Remove();
		end;
		
		PLUGIN.paperPanel = vgui.Create("cwEditPaper");
		PLUGIN.paperPanel:SetEntity(entity);
		PLUGIN.paperPanel:Populate();
		PLUGIN.paperPanel:MakePopup();
		
		gui.EnableScreenClicker(true);
	end;
end);