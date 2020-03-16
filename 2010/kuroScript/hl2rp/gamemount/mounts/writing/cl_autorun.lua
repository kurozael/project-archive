--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a data stream.
datastream.Hook("ks_ViewPaper", function(handler, uniqueID, rawData, procData)
	if ( ValidEntity( procData[1] ) ) then
		if ( MOUNT.paperPanel and MOUNT.paperPanel:IsValid() ) then
			MOUNT.paperPanel:Close();
			MOUNT.paperPanel:Remove();
		end;
		
		-- Check if a statement is true.
		if ( !procData[3] ) then
			local uniqueID = procData[2];
			
			-- Check if a statement is true.
			if ( MOUNT.paperIDs[uniqueID] ) then
				procData[3] = MOUNT.paperIDs[uniqueID];
			else
				procData[3] = "Error!";
			end;
		else
			local uniqueID = procData[2];
			
			-- Set some information.
			MOUNT.paperIDs[uniqueID] = procData[3];
		end;
		
		-- Set some information.
		MOUNT.paperPanel = vgui.Create("ks_ViewPaper");
		MOUNT.paperPanel:SetEntity( procData[1] );
		MOUNT.paperPanel:Populate( procData[3] );
		MOUNT.paperPanel:MakePopup();
		
		-- Enable the screen clicker.
		gui.EnableScreenClicker(true);
	end;
end);

-- Hook a user message.
usermessage.Hook("ks_EditPaper", function(msg)
	local entity = msg:ReadEntity();
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		if ( MOUNT.paperPanel and MOUNT.paperPanel:IsValid() ) then
			MOUNT.paperPanel:Close();
			MOUNT.paperPanel:Remove();
		end;
		
		-- Set some information.
		MOUNT.paperPanel = vgui.Create("ks_EditPaper");
		MOUNT.paperPanel:SetEntity(entity);
		MOUNT.paperPanel:Populate();
		MOUNT.paperPanel:MakePopup();
		
		-- Enable the screen clicker.
		gui.EnableScreenClicker(true);
	end;
end);