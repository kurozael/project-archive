--[[
Name: "sh_unban.lua".
Product: "nexus".
--]]

if (CLIENT) then
	local OVERWATCH = {};

	OVERWATCH.name = "Unban";
	OVERWATCH.toolTip = "A method to unban players graphically.";
	OVERWATCH.bannedPage = 1;
	OVERWATCH.bannedPlayers = nil;
	OVERWATCH.doesCreateForm = false;

	-- Called to get whether the local player has access to the overwatch.
	function OVERWATCH:HasAccess()
		local unbanTable = nexus.command.Get("PlyUnban");
		
		if ( unbanTable and nexus.player.HasFlags(g_LocalPlayer, unbanTable.access) ) then
			return true;
		end;
	end;

	-- Called when the overwatch should be displayed.
	function OVERWATCH:OnDisplay(overwatchPanel, overwatchForm)
		if (!self.noRefresh) then
			NEXUS:StartDataStream("OverwatchUnbanGet", OVERWATCH.bannedPage);
		else
			self.noRefresh = nil;
		end;
		
		if (self.bannedPlayers) then
			if (#self.bannedPlayers > 0) then
				for k, v in ipairs(self.bannedPlayers) do
					local timeLeftMessage = "This player was banned permanently.";
					local infoColor = "red";
					
					if (v.timeLeft > 0) then
						local hoursLeft = math.Round( math.max(v.timeLeft / 3600, 0) );
						local minutesLeft = math.Round( math.max(v.timeLeft / 60, 0) );
						
						if (hoursLeft >= 1) then
							timeLeftMessage = "This player will be unbanned in "..hoursLeft.." hour(s).";
						elseif (minutesLeft >= 1) then
							timeLeftMessage = "This player will be unbanned in "..hoursLeft.." minute(s).";
						else
							timeLeftMessage = "This player will be unbanned in "..v.timeLeft.." second(s).";
						end;
						
						infoColor = "orange";
					end;
					
					local label = vgui.Create("nx_InfoText", overwatchPanel);
						label:SetText(v.steamName);
						label:SetButton(true);
						label:SetToolTip("This player's identifier is "..v.identifier..".\n"..timeLeftMessage.."\nThis player was banned for '"..v.reason.."'.");
						label:SetInfoColor(infoColor);
					overwatchPanel.panelList:AddItem(label);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						Derma_Query("Are you sure that you want to unban "..v.steamName.."?", "Unban "..v.steamName..".", "Yes", function()
							NEXUS:StartDataStream("OverwatchUnbanDo", v.identifier);
						end, "No", function() end);
					end;
				end;
				
				local pageForm = vgui.Create("DForm", overwatchPanel);
					pageForm:SetName("Page "..self.bannedPage.."/"..self.pageCount);
					pageForm:SetPadding(4);
				overwatchPanel.panelList:AddItem(pageForm);
				
				if (self.isNext) then
					local nextButton = pageForm:Button("Next");
					
					-- Called when the button is clicked.
					function nextButton.DoClick(button)
						NEXUS:StartDataStream("OverwatchUnbanGet", self.bannedPage + 1);
					end;
				end;
				
				if (self.isBack) then
					local backButton = pageForm:Button("Back");
					
					-- Called when the button is clicked.
					function backButton.DoClick(button)
						NEXUS:StartDataStream("OverwatchUnbanGet", self.bannedPage - 1);
					end;
				end;
			else
				local label = vgui.Create("nx_InfoText", overwatchPanel);
					label:SetText("There are no banned players to display.");
					label:SetInfoColor("orange");
				overwatchPanel.panelList:AddItem(label);
			end;
		else
			local label = vgui.Create("nx_InfoText", overwatchPanel);
				label:SetText("Hold on while the banned player list is retrieved...");
				label:SetInfoColor("blue");
			overwatchPanel.panelList:AddItem(label);
		end;
	end;

	nexus.overwatch.Register(OVERWATCH);
	
	NEXUS:HookDataStream("OverwatchUnbanRebuild", function(data)
		local overwatchTable = nexus.overwatch.Get("Unban");
		
		if (overwatchTable and overwatchTable:IsActive() ) then
			overwatchTable:Rebuild();
		end;
	end);
	
	NEXUS:HookDataStream("OverwatchUnbanGet", function(data)
		if (type(data) == "table") then
			local overwatchTable = nexus.overwatch.Get("Unban");
			
			if (overwatchTable) then
				overwatchTable.bannedPlayers = data.players;
				overwatchTable.bannedPage = data.page;
				overwatchTable.pageCount = data.pageCount;
				overwatchTable.noRefresh = true;
				overwatchTable.isBack = data.isBack;
				overwatchTable.isNext = data.isNext;
				overwatchTable:Rebuild();
			end;
		else
			local overwatchTable = nexus.overwatch.Get("Unban");
			
			if (overwatchTable) then
				overwatchTable.bannedPlayers = {};
				
				if (overwatchTable.bannedPage != 1) then
					overwatchTable.bannedPage = 1;
					
					if ( overwatchTable:IsActive() ) then
						overwatchTable:Rebuild();
					end;
				end;
			end;
		end;
	end);
else
	NEXUS:HookDataStream("OverwatchUnbanDo", function(player, data)
		if (type(data) == "string") then
			nexus.player.RunNexusCommand(player, "PlyUnban", data);
			
			NEXUS:StartDataStream(player, "OverwatchUnbanRebuild", true);
		end;
	end);
	
	NEXUS:HookDataStream("OverwatchUnbanGet", function(player, data)
		local page = tonumber(data);
		
		if (page) then
			local bannedPlayers = {};
			local sendPlayers = {};
			local finishIndex = page * 8;
			local startIndex = finishIndex - 7;
			local pageCount = 0;
			local unixTime = os.time();
			
			for k, v in pairs(NEXUS.BanList) do
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
				NEXUS:StartDataStream( player, "OverwatchUnbanGet", {
					pageCount = pageCount,
					players = sendPlayers,
					isNext = (bannedPlayers[finishIndex + 1] != nil),
					isBack = (bannedPlayers[startIndex - 1] != nil),
					page = page
				} );
			else
				NEXUS:StartDataStream(player, "OverwatchUnbanGet", false);
			end;
		end;
	end);
end;