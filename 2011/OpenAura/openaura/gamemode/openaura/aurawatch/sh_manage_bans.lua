--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

if (CLIENT) then
	MODERATOR = openAura.moderator:New();
	MODERATOR.name = "Manage Bans";
	MODERATOR.toolTip = "A method to unban players graphically.";
	MODERATOR.bannedPage = 1;
	MODERATOR.bannedPlayers = nil;
	MODERATOR.doesCreateForm = false;

	-- Called to get whether the local player has access to the moderator.
	function MODERATOR:HasAccess()
		local unbanTable = openAura.command:Get("PlyUnban");
		
		if ( unbanTable and openAura.player:HasFlags(openAura.Client, unbanTable.access) ) then
			return true;
		end;
	end;

	-- Called when the moderator should be displayed.
	function MODERATOR:OnDisplay(moderatorPanel, moderatorForm)
		if (!self.noRefresh) then
			openAura:StartDataStream("ModeratorUnbanGet", self.bannedPage);
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
					
					local label = vgui.Create("aura_InfoText", moderatorPanel);
						label:SetText(v.steamName);
						label:SetButton(true);
						label:SetToolTip(v.identifier.."\n"..timeLeftMessage.."\nBanned for '"..v.reason.."'.");
						label:SetInfoColor(infoColor);
					moderatorPanel.panelList:AddItem(label);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						Derma_Query("Are you sure that you want to unban "..v.steamName.."?", "Unban "..v.steamName..".", "Yes", function()
							openAura:StartDataStream("ModeratorUnbanDo", v.identifier);
						end, "No", function() end);
					end;
				end;
				
				if (self.pageCount > 1) then
					local pageForm = vgui.Create("DForm", moderatorPanel);
						pageForm:SetName("Page "..self.bannedPage.."/"..self.pageCount);
						pageForm:SetPadding(4);
					moderatorPanel.panelList:AddItem(pageForm);
					
					if (self.isNext) then
						local nextButton = pageForm:Button("Next");
						
						-- Called when the button is clicked.
						function nextButton.DoClick(button)
							openAura:StartDataStream("ModeratorUnbanGet", self.bannedPage + 1);
						end;
					end;
					
					if (self.isBack) then
						local backButton = pageForm:Button("Back");
						
						-- Called when the button is clicked.
						function backButton.DoClick(button)
							openAura:StartDataStream("ModeratorUnbanGet", self.bannedPage - 1);
						end;
					end;
				end;
			else
				local label = vgui.Create("aura_InfoText", moderatorPanel);
					label:SetText("There are no banned players to display.");
					label:SetInfoColor("orange");
				moderatorPanel.panelList:AddItem(label);
			end;
		else
			local label = vgui.Create("aura_InfoText", moderatorPanel);
				label:SetText("Hold on while the banned player list is retrieved...");
				label:SetInfoColor("blue");
			moderatorPanel.panelList:AddItem(label);
		end;
	end;

	openAura.moderator:Register(MODERATOR);
	
	openAura:HookDataStream("ModeratorUnbanRebuild", function(data)
		local moderatorTable = openAura.moderator:Get("Manage Bans");
		
		if (moderatorTable and moderatorTable:IsActive() ) then
			moderatorTable:Rebuild();
		end;
	end);
	
	openAura:HookDataStream("ModeratorUnbanGet", function(data)
		if (type(data) == "table") then
			local moderatorTable = openAura.moderator:Get("Manage Bans");
			
			if (moderatorTable) then
				moderatorTable.bannedPlayers = data.players;
				moderatorTable.bannedPage = data.page;
				moderatorTable.pageCount = data.pageCount;
				moderatorTable.noRefresh = true;
				moderatorTable.isBack = data.isBack;
				moderatorTable.isNext = data.isNext;
				moderatorTable:Rebuild();
			end;
		else
			local moderatorTable = openAura.moderator:Get("Manage Bans");
			
			if (moderatorTable) then
				moderatorTable.bannedPlayers = {};
				moderatorTable.bannedPage = 1;
				moderatorTable.noRefresh = true;
					
				if ( moderatorTable:IsActive() ) then
					moderatorTable:Rebuild();
				end;
			end;
		end;
	end);
else
	openAura:HookDataStream("ModeratorUnbanDo", function(player, data)
		if (type(data) == "string") then
			openAura.player:RunOpenAuraCommand(player, "PlyUnban", data);
			
			openAura:StartDataStream(player, "ModeratorUnbanRebuild", true);
		end;
	end);
	
	openAura:HookDataStream("ModeratorUnbanGet", function(player, data)
		local page = tonumber(data);
		
		if (page) then
			local bannedPlayers = {};
			local sendPlayers = {};
			local finishIndex = page * 8;
			local startIndex = finishIndex - 7;
			local pageCount = 0;
			local unixTime = os.time();
			
			for k, v in pairs(openAura.BanList) do
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
				openAura:StartDataStream( player, "ModeratorUnbanGet", {
					pageCount = pageCount,
					players = sendPlayers,
					isNext = (bannedPlayers[finishIndex + 1] != nil),
					isBack = (bannedPlayers[startIndex - 1] != nil),
					page = page
				} );
			else
				openAura:StartDataStream(player, "ModeratorUnbanGet", false);
			end;
		end;
	end);
end;