--[[
Name: "cl_players.lua".
Product: "nexus".
--]]

local OVERWATCH = {};

OVERWATCH.name = "Players";
OVERWATCH.toolTip = "An alternative to the staff scoreboard menu.";
OVERWATCH.doesCreateForm = false;

-- Called to get whether the local player has access to the overwatch.
function OVERWATCH:HasAccess()
	return nexus.player.IsAdmin(g_LocalPlayer);
end;

-- Called when the overwatch should be displayed.
function OVERWATCH:OnDisplay(overwatchPanel, overwatchForm)
	local availableClasses = {};
	local classes = {};
	
	for k, v in ipairs( g_Player.GetAll() ) do
		if ( v:HasInitialized() ) then
			local class = nexus.mount.Call("GetPlayerScoreboardClass", v);
			
			if (class) then
				if ( !availableClasses[class] ) then
					availableClasses[class] = {};
				end;
				
				availableClasses[class][#availableClasses[class] + 1] = v;
			end;
		end;
	end;
	
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return nexus.mount.Call("ScoreboardSortClassPlayers", k, a, b);
		end);
		
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	if (table.Count(classes) > 0) then
		local label = vgui.Create("nx_InfoText", overwatchPanel);
			label:SetText("Clicking on a player may bring up some options.");
			label:SetInfoColor("blue");
		overwatchPanel.panelList:AddItem(label);
		
		for k, v in pairs(classes) do
			local characterForm = vgui.Create("DForm", overwatchPanel);
			local panelList = vgui.Create("DPanelList", overwatchPanel);
			
			for k2, v2 in pairs(v.players) do
				local label = vgui.Create("nx_InfoText", overwatchPanel);
					label:SetText( v2:Name() );
					label:SetButton(true);
					label:SetToolTip("This player's name is "..v2:SteamName()..".\nThis player's Steam ID is "..v2:SteamID()..".");
					label:SetInfoColor( g_Team.GetColor( v2:Team() ) );
				panelList:AddItem(label);
				
				-- Called when the button is clicked.
				function label.DoClick(button)
					if ( IsValid(v2) ) then
						local options = {};
							nexus.mount.Call("GetPlayerScoreboardOptions", v2, options);
						NEXUS:AddMenuFromData(nil, options);
					end;
				end;
			end;
			
			overwatchPanel.panelList:AddItem(characterForm);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			characterForm:SetName(v.name);
			characterForm:AddItem(panelList);
			characterForm:SetPadding(4); 
		end;
	else
		local label = vgui.Create("nx_InfoText", overwatchPanel);
			label:SetText("There are no players to display.");
			label:SetInfoColor("orange");
		overwatchPanel.panelList:AddItem(label);
	end;
end;

nexus.overwatch.Register(OVERWATCH);