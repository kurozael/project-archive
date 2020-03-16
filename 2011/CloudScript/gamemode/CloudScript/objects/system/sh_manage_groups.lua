--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local GROUP_SUPER = 1;
local GROUP_ADMIN = 2;
local GROUP_OPER = 3;
local GROUP_USER = 4;

if (CLIENT) then
	SYSTEM = CloudScript.system:New();
	SYSTEM.name = "Manage Groups";
	SYSTEM.toolTip = "A way to manage all administration groups.";
	SYSTEM.groupType = GROUP_USER;
	SYSTEM.groupPage = 1;
	SYSTEM.groupPlayers = nil;
	SYSTEM.doesCreateForm = false;

	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		if ( !CloudScript.config:Get("use_own_group_system"):Get() ) then
			local commandTable = CloudScript.command:Get("PlySetGroup");
			
			if ( commandTable and CloudScript.player:HasFlags(CloudScript.Client, commandTable.access) ) then
				return true;
			end;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		if (self.groupType == GROUP_USER) then
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("Selecting a user group will bring up a list of users in that group.");
				label:SetInfoColor("blue");
			systemPanel.panelList:AddItem(label);
			
			local userGroupsForm = vgui.Create("DForm", systemPanel);
				userGroupsForm:SetName("User Groups");
				userGroupsForm:SetPadding(4);
			systemPanel.panelList:AddItem(userGroupsForm);
			
			local userGroups = {"Super Admins", "Administrators", "Operators"};
			
			for k, v in ipairs(userGroups) do
				local groupButton = vgui.Create("DButton", systemPanel);
					groupButton:SetToolTip("Manage users within the "..v.." user group.");
					groupButton:SetText(v);
					groupButton:SetWide( systemPanel:GetParent():GetWide() );
				
					-- Called when the button is clicked.
					function groupButton.DoClick(button)
						self.groupPlayers = nil;
						self.groupType = k;
						self:Rebuild();
					end;
				userGroupsForm:AddItem(groupButton);
			end;
		else
			local backButton = vgui.Create("DButton", systemPanel);
				backButton:SetText("Back to User Groups");
				backButton:SetWide( systemPanel:GetParent():GetWide() );
				
				-- Called when the button is clicked.
				function backButton.DoClick(button)
					self.groupType = GROUP_USER;
					self:Rebuild();
				end;
			systemPanel.navigationForm:AddItem(backButton);
			
			if (!self.noRefresh) then
				CloudScript:StartDataStream( "SystemGroupGet", {self.groupType, self.groupPage} );
			else
				self.noRefresh = nil;
			end;
			
			if (self.groupPlayers) then
				if (#self.groupPlayers > 0) then
					for k, v in ipairs(self.groupPlayers) do
						local label = vgui.Create("cloud_InfoText", systemPanel);
							label:SetText(v.steamName);
							label:SetButton(true);
							label:SetToolTip("This player's Steam ID is "..v.steamID..".");
							label:SetInfoColor("blue");
						systemPanel.panelList:AddItem(label);
						
						-- Called when the button is clicked.
						function label.DoClick(button)
							local commandTable = CloudScript.command:Get("PlyDemote");
							
							if ( commandTable and CloudScript.player:HasFlags(CloudScript.Client, commandTable.access) ) then
								Derma_Query("Are you sure that you want to demote "..v.steamName.."?", "Demote "..v.steamName..".", "Yes", function()
									CloudScript:StartDataStream( "SystemGroupDemote", {v.steamID, v.steamName, self.groupType} );
								end, "No", function() end);
							end;
						end;
					end;
					
					if (self.pageCount > 1) then
						local pageForm = vgui.Create("DForm", systemPanel);
							pageForm:SetName("Page "..self.groupPage.."/"..self.pageCount);
							pageForm:SetPadding(4);
						systemPanel.panelList:AddItem(pageForm);
						
						if (self.isNext) then
							local nextButton = pageForm:Button("Next");
							
							-- Called when the button is clicked.
							function nextButton.DoClick(button)
								CloudScript:StartDataStream( "SystemGroupGet", {self.groupType, self.groupPage + 1} );
							end;
						end;
						
						if (self.isBack) then
							local backButton = pageForm:Button("Back");
							
							-- Called when the button is clicked.
							function backButton.DoClick(button)
								CloudScript:StartDataStream( "SystemGroupGet", {self.groupType, self.groupPage - 1} );
							end;
						end;
					end;
				else
					local label = vgui.Create("cloud_InfoText", systemPanel);
						label:SetText("There are no users to display in this group.");
						label:SetInfoColor("orange");
					systemPanel.panelList:AddItem(label);
				end;
			else
				local label = vgui.Create("cloud_InfoText", systemPanel);
					label:SetText("Hold on while the group users are retrieved...");
					label:SetInfoColor("blue");
				systemPanel.panelList:AddItem(label);
			end;
		end;
	end;

	CloudScript.system:Register(SYSTEM);
	
	CloudScript:HookDataStream("SystemGroupRebuild", function(data)
		local systemTable = CloudScript.system:Get("Manage Groups");
		
		if (systemTable and systemTable:IsActive() ) then
			systemTable:Rebuild();
		end;
	end);
	
	CloudScript:HookDataStream("SystemGroupGet", function(data)
		if (type(data) == "table") then
			local systemTable = CloudScript.system:Get("Manage Groups");
			
			if (systemTable) then
				systemTable.groupPlayers = data.players;
				systemTable.groupPage = data.page;
				systemTable.pageCount = data.pageCount;
				systemTable.noRefresh = true;
				systemTable.isBack = data.isBack;
				systemTable.isNext = data.isNext;
				systemTable:Rebuild();
			end;
		else
			local systemTable = CloudScript.system:Get("Manage Groups");
			
			if (systemTable) then
				systemTable.groupPlayers = {};
				systemTable.groupPage = 1;
				systemTable.noRefresh = true;
					
				if ( systemTable:IsActive() ) then
					systemTable:Rebuild();
				end;
			end;
		end;
	end);
else
	CloudScript:HookDataStream("SystemGroupDemote", function(player, data)
		local commandTable = CloudScript.command:Get("PlyDemote");
		
		if ( commandTable and type(data) == "table"
		and CloudScript.player:HasFlags(player, commandTable.access) ) then
			local target = CloudScript.player:Get( data[1] );
			
			if (target) then
				CloudScript.player:RunCloudScriptCommand( player, "PlyDemote", data[1] );
				
				timer.Simple(1, function()
					if ( IsValid(player) ) then
						CloudScript:StartDataStream(player, "SystemGroupRebuild", true);
					end;
				end);
			else
				local schemaFolder = CloudScript:GetSchemaFolder();
				local playersTable = CloudScript.config:Get("mysql_players_table"):Get();
				local userGroup = "user";
				
				if (data[3] == GROUP_SUPER) then
					userGroup = "superadmin";
				elseif (data[3] == GROUP_ADMIN) then
					userGroup = "admin";
				elseif (data[3] == GROUP_OPER) then
					userGroup = "operator";
				end;
				
				tmysql.query("UPDATE "..playersTable.." SET _UserGroup = \"user\" WHERE _SteamID = \""..tmysql.escape( data[1] ).."\" AND _Schema = \""..schemaFolder.."\"", function(result)
					CloudScript:StartDataStream(player, "SystemGroupRebuild", true);
				end);
			
				CloudScript.player:NotifyAll(player:Name().." has demoted "..data[2].." from "..userGroup.." to user.");
			end;
		end;
	end);
	
	CloudScript:HookDataStream("SystemGroupGet", function(player, data)
		if (type(data) != "table") then
			return;
		end;
		
		local groupType = tonumber( data[1] );
		local groupPage = tonumber( data[2] );
		
		if (groupPage) then
			local groupPlayers = {};
			local sendPlayers = {};
			local finishIndex = groupPage * 8;
			local startIndex = finishIndex - 7;
			local groupName = "user";
			local pageCount = 0;
			
			if (groupType == GROUP_SUPER) then
				groupName = "superadmin";
			elseif (groupType == GROUP_ADMIN) then
				groupName = "admin";
			elseif (groupType == GROUP_OPER) then
				groupName = "operator";
			end;
			
			local schemaFolder = CloudScript:GetSchemaFolder();
			local playersTable = CloudScript.config:Get("mysql_players_table"):Get();
			
			tmysql.query("SELECT * FROM "..playersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _UserGroup = \""..groupName.."\"", function(result)
				if (result and type(result) == "table" and #result > 0) then
					for k, v in pairs(result) do
						groupPlayers[#groupPlayers + 1] = {
							steamName = v._SteamName,
							steamID = v._SteamID
						};
					end;
				end;
				
				table.sort(groupPlayers, function(a, b)
					return a.steamName < b.steamName;
				end);
				
				pageCount = math.ceil(#groupPlayers / 8);
				
				for k, v in ipairs(groupPlayers) do
					if (k >= startIndex and k <= finishIndex) then
						sendPlayers[#sendPlayers + 1] = v;
					end;
				end;
				
				if (#sendPlayers > 0) then
					CloudScript:StartDataStream( player, "SystemGroupGet", {
						pageCount = pageCount,
						players = sendPlayers,
						isNext = (groupPlayers[finishIndex + 1] != nil),
						isBack = (groupPlayers[startIndex - 1] != nil),
						page = groupPage
					} );
				else
					CloudScript:StartDataStream(player, "SystemGroupGet", false);
				end;
			end, 1);
		end;
	end);
end;