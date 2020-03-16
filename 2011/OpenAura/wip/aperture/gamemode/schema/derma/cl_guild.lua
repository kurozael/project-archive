--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

AccessorFunc(PANEL, "m_bPaintBackground", "PaintBackground");
AccessorFunc(PANEL, "m_bgColor", "BackgroundColor");
AccessorFunc(PANEL, "m_bDisabled", "Disabled");

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize( openAura.menu:GetWidth(), openAura.menu:GetHeight() );
	self:SetTitle("Guild");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.schema.guildPanel = self;
	
	self:Rebuild();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	
	return true;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear(true);
	
	local myGuild = openAura.Client:GetGuild();
	
	if (myGuild) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Click here if you want to leave the guild permanently.");
			label:SetButton(true);
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
		
		-- Called when the button is clicked.
		function label.DoClick(button)
			Derma_Query("Are you sure that you want to leave the guild?", "Leave the guild.", "Yes", function()
				openAura:RunCommand("GuildLeave");
			end, "No", function() end);
		end;
		
		local guildPlayers = {};
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				local playerGuild = v:GetGuild();
				
				if (playerGuild and playerGuild == myGuild) then
					guildPlayers[#guildPlayers + 1] = v;
				end;
			end;
		end;
		
		table.sort(guildPlayers, function(a, b)
			return a:GetRank() > b:GetRank();
		end);
		
		if (#guildPlayers > 0) then
			if ( openAura.Client:IsLeader() ) then
				local label = vgui.Create("aura_InfoText", self);
					label:SetText("You can manage characters in your guild by clicking their name.");
					label:SetInfoColor("blue");
				self.panelList:AddItem(label);
			end;
			
			local guildForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			for k, v in ipairs(guildPlayers) do
				local label = vgui.Create("aura_InfoText", self);
					label:SetText( v:GetRank(true)..". "..v:Name() );
					label:SetInfoColor( _team.GetColor( v:Team() ) );
				panelList:AddItem(label);
				
				if ( openAura.Client:IsLeader() ) then
					label:SetButton(true);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						if ( IsValid(v) and !v:IsLeader() ) then
							local options = {};
							
							options["Kick"] = function()
								openAura:StartDataStream("GuildKick", v);
							end;
							
							options["Rank"] = {};
							options["Rank"]["1. Recruit"] = function()
								openAura:StartDataStream( "GuildSetRank", {v, RANK_RCT} );
							end;
							options["Rank"]["2. Private"] = function()
								openAura:StartDataStream( "GuildSetRank", {v, RANK_PVT} );
							end;
							options["Rank"]["3. Sergeant"] = function()
								openAura:StartDataStream( "GuildSetRank", {v, RANK_SGT} );
							end;
							options["Rank"]["4. Lieutenant"] = function()
								openAura:StartDataStream( "GuildSetRank", {v, RANK_LT} );
							end;
							options["Rank"]["5. Captain"] = function()
								openAura:StartDataStream( "GuildSetRank", {v, RANK_CPT} );
							end;
							options["Rank"]["6. Major"] = function()
								Derma_Query("Are you sure that you want to make them a leader?", "Make them a leader.", "Yes", function()
									openAura:StartDataStream("GuildMakeLeader", v);
								end, "No", function() end);
							end;
							
							openAura:AddMenuFromData(nil, options);
						end;
					end;
				end;
			end;
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			guildForm:SetName(myGuild);
			guildForm:AddItem(panelList);
			guildForm:SetPadding(4);
			
			self.panelList:AddItem(guildForm);
		else
			local label = vgui.Create("aura_InfoText", self);
				label:SetText("No characters in your guild are playing.");
				label:SetInfoColor("orange");
			self.panelList:AddItem(label);
		end;
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Creating an guild will cost you "..FORMAT_CASH(openAura.config:Get("guild_cost"):Get(), nil, true)..".");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local createForm = vgui.Create("DForm", self);
		createForm:SetName("Create an guild");
		createForm:SetPadding(4);
		
		local textEntry = createForm:TextEntry("Name");
			textEntry:SetToolTip("Choose a nice name for your guild.");
		local okayButton = createForm:Button("Okay");
		
		-- Called when the button is clicked.
		function okayButton.DoClick(okayButton)
			openAura:StartDataStream( "CreateGuild", textEntry:GetValue() );
		end;
		
		self.panelList:AddItem(createForm);
	end;

	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (openAura.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize( self:GetWide(), math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75) );
	
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("aura_Guild", PANEL, "DFrame");