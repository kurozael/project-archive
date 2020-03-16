--[[
Name: "cl_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Hook a user message.
usermessage.Hook("ks_ViewBook", function(msg)
	local entity = msg:ReadEntity();
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		local index = entity:GetSharedVar("ks_Index");
		
		-- Check if a statement is true.
		if (index != 0) then
			local itemTable = kuroScript.item.Get(index);
			
			-- Check if a statement is true.
			if (itemTable and itemTable.bookInformation) then
				if ( MOUNT.bookPanel and MOUNT.bookPanel:IsValid() ) then
					MOUNT.bookPanel:Close();
					MOUNT.bookPanel:Remove();
				end;
				
				-- Set some information.
				MOUNT.bookPanel = vgui.Create("ks_ViewBook");
				MOUNT.bookPanel:SetEntity(entity);
				MOUNT.bookPanel:Populate(itemTable);
				MOUNT.bookPanel:MakePopup();
			end;
		end;
	end;
end);