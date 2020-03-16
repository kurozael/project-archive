--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local GROUP_SUPER = 1;
local GROUP_ADMIN = 2;
local GROUP_OPER = 3;
local GROUP_USER = 4;

if (CLIENT) then
	MODERATOR = openAura.moderator:New();
	MODERATOR.name = "Manage Groups";
	MODERATOR.toolTip = "A way to manage all administration groups.";
	MODERATOR.groupType = GROUP_USER;
	MODERATOR.groupPage = 1;
	MODERATOR.groupPlayers = nil;
	MODERATOR.doesCreateForm = false;

	-- Called to get whether the local player has access to the moderator.
	function MODERATOR:HasAccess()
		if ( !openAura.config:Get("use_own_group_system"):Get() ) then
			local commandTable = openAura.command:Get("PlySetGroup");
			
			if ( commandTable and openAura.player:HasFlags(openAura.Client, commandTable.access) ) then
				return true;
			end;
		end;
	end;

	-- Called when the moderator should be displayed.
	function MODERATOR:OnDisplay(moderatorPanel, moderatorForm)
		if (self.groupType == GROUP_USER) then
			local label = vgui.Create("aura_InfoText", moderatorPanel);
				label:SetText("Selecting a user group will bring up a list of users in that group.");
				label:SetInfoColor("blue");
			moderatorPanel.panelList:AddItem(label);
			
			local userGroupsForm = vgui.Create("DForm", moderatorPanel);
				userGroupsForm:SetName("User Groups");
				userGroupsForm:SetPadding(4);
			moderatorPanel.panelList:AddItem(userGroupsForm);
			
			local userGroups = {"Super Admins", "Administrators", "Operators"};
			
			for k, v in ipairs(userGroups) do
				local groupButton = vgui.Create("DButton", moderatorPanel);
					groupButton:SetToolTip("Manage users within the "..v.." user group.");
					groupButton:SetText(v);
					groupButton:SetWide( moderatorPanel:GetParent():GetWide() );
				
					-- Called when the button is clicked.
					function groupButton.DoClick(button)
						self.groupPlayers = nil;
						self.groupType = k;
						self:Rebuild();
					end;
				userGroupsForm:AddItem(groupButton);
			end;
		else
			local backButton = vgui.Create("DButton", moderatorPanel);
				backButton:SetText("Back to User Groups");
				backButton:SetWide( moderatorPanel:GetParent():GetWide() );
				
				-- Called when the button is clicked.
				function backButton.DoClick(button)
					self.groupType = GROUP_USER;
					self:Rebuild();
				end;
			moderatorPanel.navigationForm:AddItem(backButton);
			
			if (!self.noRefresh) then
				openAura:StartDataStream( "ModeratorGroupGet", {self.groupType, self.groupPage} );
			else
				self.noRefresh = nil;
			end;
			
			if (self.groupPlayers) then
				if (#self.groupPlayers > 0) then
					for k, v in ipairs(self.groupPlayers) do
						local label = vgui.Create("aura_InfoText", moderatorPanel);
							label:SetText(v.steamName);
							label:SetButton(true);
							label:SetToolTip("This player's Steam ID is "..v.steamID..".");
							label:SetInfoColor("blue");
						moderatorPanel.panelList:AddItem(label);
						
						-- Called when the button is clicked.
						function label.DoClick(button)
							local commandTable = openAura.command:Get("PlyDemote");
							
							if ( commandTable and openAura.player:HasFlags(openAura.Client, commandTable.access) ) then
								Derma_Query("Are you sure that you want to demote "..v.steamName.."?", "Demote "..v.steamName..".", "Yes", function()
									openAura:StartDataStream( "ModeratorGroupDemote", {v.steamID, v.steamName, self.groupType} );
								end, "No", function() end);
							end;
						end;
					end;
					
					if (self.pageCount > 1) then
						local pageForm = vgui.Create("DForm", moderatorPanel);
							pageForm:SetName("Page "..self.groupPage.."/"..self.pageCount);
							pageForm:SetPadding(4);
						moderatorPanel.panelList:AddItem(pageForm);
						
						if (self.isNext) then
							local nextButton = pageForm:Button("Next");
							
							-- Called when the button is clicked.
							function nextButton.DoClick(button)
								openAura:StartDataStream( "ModeratorGroupGet", {self.groupType, self.groupPage + 1} );
							end;
						end;
						
						if (self.isBack) then
							local backButton = pageForm:Button("Back");
							
							-- Called when the button is clicked.
							function backButton.DoClick(button)
								openAura:StartDataStream( "ModeratorGroupGet", {self.groupType, self.groupPage - 1} );
							end;
						end;
					end;
				else
					local label = vgui.Create("aura_InfoText", moderatorPanel);
						label:SetText("There are no users to display in this group.");
						label:SetInfoColor("orange");
					moderatorPanel.panelList:AddItem(label);
				end;
			else
				local label = vgui.Create("aura_InfoText", moderatorPanel);
					label:SetText("Hold on while the group users are retrieved...");
					label:SetInfoColor("blue");
				moderatorPanel.panelList:AddItem(label);
			end;
		end;
	end;

	openAura.moderator:Register(MODERATOR);
	
	openAura:HookDataStream("ModeratorGroupRebuild", function(data)
		local moderatorTable = openAura.moderator:Get("Manage Groups");
		
		if (moderatorTable and moderatorTable:IsActive() ) then
			moderatorTable:Rebuild();
		end;
	end);
	
	openAura:HookDataStream("ModeratorGroupGet", function(data)
		if (type(data) == "table") then
			local moderatorTable = openAura.moderator:Get("Manage Groups");
			
			if (moderatorTable) then
				moderatorTable.groupPlayers = data.players;
				moderatorTable.groupPage = data.page;
				moderatorTable.pageCount = data.pageCount;
				moderatorTable.noRefresh = true;
				moderatorTable.isBack = data.isBack;
				moderatorTable.isNext = data.isNext;
				moderatorTable:Rebuild();
			end;
		else
			local moderatorTable = openAura.moderator:Get("Manage Groups");
			
			if (moderatorTable) then
				moderatorTable.groupPlayers = {};
				moderatorTable.groupPage = 1;
				moderatorTable.noRefresh = true;
					
				if ( moderatorTable:IsActive() ) then
					moderatorTable:Rebuild();
				end;
			end;
		end;
	end);
else
	openAura:HookDataStream("ModeratorGroupDemote", function(player, data)
		local commandTable = openAura.command:Get("PlyDemote");
		
		if ( commandTable and type(data) == "table"
		and openAura.player:HasFlags(player, commandTable.access) ) then
			local target = openAura.player:Get( data[1] );
			
			if (target) then
				openAura.player:RunOpenAuraCommand( player, "PlyDemote", data[1] );
				
				timer.Simple(1, function()
					if ( IsValid(player) ) then
						openAura:StartDataStream(player, "ModeratorGroupRebuild", true);
					end;
				end);
			else
				local schemaFolder = openAura:GetSchemaFolder();
				local playersTable = openAura.config:Get("mysql_players_table"):Get();
				local userGroup = "user";
				
				if (data[3] == GROUP_SUPER) then
					userGroup = "superadmin";
				elseif (data[3] == GROUP_ADMIN) then
					userGroup = "admin";
				elseif (data[3] == GROUP_OPER) then
					userGroup = "operator";
				end;
				
				tmysql.query("UPDATE "..playersTable.." SET _UserGroup = \"user\" WHERE _SteamID = \""..tmysql.escape( data[1] ).."\" AND _Schema = \""..schemaFolder.."\"", function(result)
					openAura:StartDataStream(player, "ModeratorGroupRebuild", true);
				end);
			
				openAura.player:NotifyAll(player:Name().." has demoted "..data[2].." from "..userGroup.." to user.");
			end;
		end;
	end);
	
	openAura:HookDataStream("ModeratorGroupGet", function(player, data)
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
			
			local schemaFolder = openAura:GetSchemaFolder();
			local playersTable = openAura.config:Get("mysql_players_table"):Get();
			
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
					openAura:StartDataStream( player, "ModeratorGroupGet", {
						pageCount = pageCount,
						players = sendPlayers,
						isNext = (groupPlayers[finishIndex + 1] != nil),
						isBack = (groupPlayers[startIndex - 1] != nil),
						page = groupPage
					} );
				else
					openAura:StartDataStream(player, "ModeratorGroupGet", false);
				end;
			end, 1);
		end;
	end);
end;