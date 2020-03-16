--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.datastream:Hook("ViewPaper", function(data)
	if (IsValid(data[1])) then
		if (IsValid(cwWriting.paperPanel)) then
			cwWriting.paperPanel:Close();
			cwWriting.paperPanel:Remove();
		end;
		
		if (!data[3]) then
			local uniqueID = data[2];
			
			if (cwWriting.paperIDs[uniqueID]) then
				data[3] = cwWriting.paperIDs[uniqueID];
			else
				data[3] = "Error!";
			end;
		else
			local uniqueID = data[2];
			
			cwWriting.paperIDs[uniqueID] = data[3];
		end;
		
		cwWriting.paperPanel = vgui.Create("cwViewPaper");
		cwWriting.paperPanel:SetEntity(data[1]);
		cwWriting.paperPanel:Populate(data[3]);
		cwWriting.paperPanel:MakePopup();
		
		gui.EnableScreenClicker(true);
	end;
end);

usermessage.Hook("cwEditPaper", function(msg)
	local entity = msg:ReadEntity();
	
	if (IsValid(entity)) then
		if (IsValid(cwWriting.paperPanel)) then
			cwWriting.paperPanel:Close();
			cwWriting.paperPanel:Remove();
		end;
		
		cwWriting.paperPanel = vgui.Create("cwEditPaper");
		cwWriting.paperPanel:SetEntity(entity);
		cwWriting.paperPanel:Populate();
		cwWriting.paperPanel:MakePopup();
		
		gui.EnableScreenClicker(true);
	end;
end);