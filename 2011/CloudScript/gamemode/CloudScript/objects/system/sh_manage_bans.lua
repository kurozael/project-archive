--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	SYSTEM = CloudScript.system:New();
	SYSTEM.name = "Manage Bans";
	SYSTEM.toolTip = "A method to unban players graphically.";
	SYSTEM.bannedPage = 1;
	SYSTEM.bannedPlayers = nil;
	SYSTEM.doesCreateForm = false;

	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local unbanTable = CloudScript.command:Get("PlyUnban");
		
		if ( unbanTable and CloudScript.player:HasFlags(CloudScript.Client, unbanTable.access) ) then
			return true;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		if (!self.noRefresh) then
			CloudScript:StartDataStream("SystemUnbanGet", self.bannedPage);
		else
			self.noRefresh = nil;
		end;
		
		if (self.bannedPlayers) then
			if (#self.bannedPlayers > 0) then
				for k, v in ipairs(self.bannedPlayers) do
					local timeLeftMessage = "This player is banned permanently.";
					local infoColor = "red";
					
					if (v.timeLeft > 0) then
						local hoursLeft = math.Round( math.max(v.timeLeft / 3600, 0) );
						local minutesLeft = math.Round( math.max(v.timeLeft / 60, 0) );
						
						if (hoursLeft >= 1) then
							timeLeftMessage = "Unbanned in "..hoursLeft.." hour(s).";
						elseif (minutesLeft >= 1) then
							timeLeftMessage = "Unbanned in "..hoursLeft.." minute(s).";
						else
							timeLeftMessage = "Unbanned in "..v.timeLeft.." second(s).";
						end;
						
						infoColor = "orange";
					end;
					
					local label = vgui.Create("cloud_InfoText", systemPanel);
						label:SetText(v.steamName);
						label:SetButton(true);
						label:SetToolTip(v.identifier.."\n"..timeLeftMessage.."\nBanned for '"..v.reason.."'.");
						label:SetInfoColor(infoColor);
					systemPanel.panelList:AddItem(label);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						Derma_Query("Are you sure that you want to unban "..v.steamName.."?", "Unban "..v.steamName..".", "Yes", function()
							CloudScript:StartDataStream("SystemUnbanDo", v.identifier);
						end, "No", function() end);
					end;
				end;
				
				if (self.pageCount > 1) then
					local pageForm = vgui.Create("DForm", systemPanel);
						pageForm:SetName("Page "..self.bannedPage.."/"..self.pageCount);
						pageForm:SetPadding(4);
					systemPanel.panelList:AddItem(pageForm);
					
					if (self.isNext) then
						local nextButton = pageForm:Button("Next");
						
						-- Called when the button is clicked.
						function nextButton.DoClick(button)
							CloudScript:StartDataStream("SystemUnbanGet", self.bannedPage + 1);
						end;
					end;
					
					if (self.isBack) then
						local backButton = pageForm:Button("Back");
						
						-- Called when the button is clicked.
						function backButton.DoClick(button)
							CloudScript:StartDataStream("SystemUnbanGet", self.bannedPage - 1);
						end;
					end;
				end;
			else
				local label = vgui.Create("cloud_InfoText", systemPanel);
					label:SetText("There are no banned players to display.");
					label:SetInfoColor("orange");
				systemPanel.panelList:AddItem(label);
			end;
		else
			local label = vgui.Create("cloud_InfoText", systemPanel);
				label:SetText("Hold on while the banned player list is retrieved...");
				label:SetInfoColor("blue");
			systemPanel.panelList:AddItem(label);
		end;
	end;

	CloudScript.system:Register(SYSTEM);
	
	CloudScript:HookDataStream("SystemUnbanRebuild", function(data)
		local systemTable = CloudScript.system:Get("Manage Bans");
		
		if (systemTable and systemTable:IsActive() ) then
			systemTable:Rebuild();
		end;
	end);
	
	CloudScript:HookDataStream("SystemUnbanGet", function(data)
		if (type(data) == "table") then
			local systemTable = CloudScript.system:Get("Manage Bans");
			
			if (systemTable) then
				systemTable.bannedPlayers = data.players;
				systemTable.bannedPage = data.page;
				systemTable.pageCount = data.pageCount;
				systemTable.noRefresh = true;
				systemTable.isBack = data.isBack;
				systemTable.isNext = data.isNext;
				systemTable:Rebuild();
			end;
		else
			local systemTable = CloudScript.system:Get("Manage Bans");
			
			if (systemTable) then
				systemTable.bannedPlayers = {};
				systemTable.bannedPage = 1;
				systemTable.noRefresh = true;
					
				if ( systemTable:IsActive() ) then
					systemTable:Rebuild();
				end;
			end;
		end;
	end);
else
	CloudScript:HookDataStream("SystemUnbanDo", function(player, data)
		if (type(data) == "string") then
			CloudScript.player:RunCloudScriptCommand(player, "PlyUnban", data);
			
			CloudScript:StartDataStream(player, "SystemUnbanRebuild", true);
		end;
	end);
	
	CloudScript:HookDataStream("SystemUnbanGet", function(player, data)
		local page = tonumber(data);
		
		if (page) then
			local bannedPlayers = {};
			local sendPlayers = {};
			local finishIndex = page * 8;
			local startIndex = finishIndex - 7;
			local pageCount = 0;
			local unixTime = os.time();
			
			for k, v in pairs(CloudScript.BanList) do
				if (v.unbanTime == 0 or v.unbanTime > unixTime) then
					local timeLeft = v.unbanTime - unixTime;
					
					if (v.unbanTime == 0) then
						timeLeft = 0;
					end;
					
					bannedPlayers[#bannedPlayers + 1] = {
						identifier = k,
						steamName = v.steamName,
						timeLeft = timeLeft,
						reason = v.reason
					};
				end;
			end;
			
			table.sort(bannedPlayers, function(a, b)
				return a.steamName < b.steamName;
			end);
			
			pageCount = math.ceil(#bannedPlayers / 8);
			
			for k, v in ipairs(bannedPlayers) do
				if (k >= startIndex and k <= finishIndex) then
					sendPlayers[#sendPlayers + 1] = v;
				end;
			end;
			
			if (#sendPlayers > 0) then
				CloudScript:StartDataStream( player, "SystemUnbanGet", {
					pageCount = pageCount,
					players = sendPlayers,
					isNext = (bannedPlayers[finishIndex + 1] != nil),
					isBack = (bannedPlayers[startIndex - 1] != nil),
					page = page
				} );
			else
				CloudScript:StartDataStream(player, "SystemUnbanGet", false);
			end;
		end;
	end);
end;