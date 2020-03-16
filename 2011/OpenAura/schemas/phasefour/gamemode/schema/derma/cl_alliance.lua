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
	self:SetTitle("Alliance");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	openAura.schema.alliancePanel = self;
	
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
	
	local myAlliance = openAura.Client:GetAlliance();
	
	if (myAlliance) then
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Click here if you want to leave the alliance permanently.");
			label:SetButton(true);
			label:SetInfoColor("red");
		self.panelList:AddItem(label);
		
		-- Called when the button is clicked.
		function label.DoClick(button)
			Derma_Query("Are you sure that you want to leave the alliance?", "Leave the alliance.", "Yes", function()
				openAura:RunCommand("AllyLeave");
			end, "No", function() end);
		end;
		
		local alliancePlayers = {};
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				local playerAlliance = v:GetAlliance();
				
				if (playerAlliance and playerAlliance == myAlliance) then
					alliancePlayers[#alliancePlayers + 1] = v;
				end;
			end;
		end;
		
		table.sort(alliancePlayers, function(a, b)
			return a:GetRank() > b:GetRank();
		end);
		
		if (#alliancePlayers > 0) then
			if ( openAura.Client:IsLeader() ) then
				local label = vgui.Create("aura_InfoText", self);
					label:SetText("You can manage characters in your alliance by clicking their name.");
					label:SetInfoColor("blue");
				self.panelList:AddItem(label);
			end;
			
			local allianceForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			for k, v in ipairs(alliancePlayers) do
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
								openAura:StartDataStream("AllyKick", v);
							end;
							
							options["Rank"] = {};
							options["Rank"]["1. Recruit"] = function()
								openAura:StartDataStream( "AllySetRank", {v, RANK_RCT} );
							end;
							options["Rank"]["2. Private"] = function()
								openAura:StartDataStream( "AllySetRank", {v, RANK_PVT} );
							end;
							options["Rank"]["3. Sergeant"] = function()
								openAura:StartDataStream( "AllySetRank", {v, RANK_SGT} );
							end;
							options["Rank"]["4. Lieutenant"] = function()
								openAura:StartDataStream( "AllySetRank", {v, RANK_LT} );
							end;
							options["Rank"]["5. Captain"] = function()
								openAura:StartDataStream( "AllySetRank", {v, RANK_CPT} );
							end;
							options["Rank"]["6. Major"] = function()
								Derma_Query("Are you sure that you want to make them a leader?", "Make them a leader.", "Yes", function()
									openAura:StartDataStream("AllyMakeLeader", v);
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
			
			allianceForm:SetName(myAlliance);
			allianceForm:AddItem(panelList);
			allianceForm:SetPadding(4);
			
			self.panelList:AddItem(allianceForm);
		else
			local label = vgui.Create("aura_InfoText", self);
				label:SetText("No characters in your alliance are playing.");
				label:SetInfoColor("orange");
			self.panelList:AddItem(label);
		end;
	else
		local label = vgui.Create("aura_InfoText", self);
			label:SetText("Creating an alliance will cost you "..FORMAT_CASH(openAura.config:Get("alliance_cost"):Get(), nil, true)..".");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		local createForm = vgui.Create("DForm", self);
		createForm:SetName("Create an alliance");
		createForm:SetPadding(4);
		
		local textEntry = createForm:TextEntry("Name");
			textEntry:SetToolTip("Choose a nice name for your alliance.");
		local okayButton = createForm:Button("Okay");
		
		-- Called when the button is clicked.
		function okayButton.DoClick(okayButton)
			openAura:StartDataStream( "CreateAlliance", textEntry:GetValue() );
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

vgui.Register("aura_Alliance", PANEL, "DFrame");