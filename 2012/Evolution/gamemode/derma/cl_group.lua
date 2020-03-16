--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

AccessorFunc(PANEL, "m_bPaintBackground", "PaintBackground");
AccessorFunc(PANEL, "m_bgColor", "BackgroundColor");
AccessorFunc(PANEL, "m_bDisabled", "Disabled");

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	self:SetTitle("Group");
	self:SetSizable(false);
	self:SetDraggable(false);
	self:ShowCloseButton(false);
	
	self.membersList = vgui.Create("DPanelList", self);
 	self.membersList:SetPadding(2);
 	self.membersList:SetSpacing(3);
 	self.membersList:SizeToContents();
	self.membersList:EnableVerticalScrollbar();
	
	self.groupList = vgui.Create("DPanelList", self);
 	self.groupList:SetPadding(2);
 	self.groupList:SetSpacing(3);
 	self.groupList:SizeToContents();
	self.groupList:EnableVerticalScrollbar();
	
	self.columnSheet = vgui.Create("DColumnSheet", self);
	self.columnSheet:AddSheet("Group", self.groupList, "gui/silkicons/group");
	self.columnSheet:AddSheet("Members", self.membersList, "gui/silkicons/user");
	
	if (!IsValid(Schema.groupPanel)) then
		Schema.groupPanel = self;
	end;
	
	self:Rebuild();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	derma.SkinHook("Paint", "Frame", self);
	return true;
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.membersList:Clear(true);
	self.groupList:Clear(true);
	
	local myGroup = Clockwork.Client:GetSharedVar("Group");
	
	if (myGroup != "") then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("Click here if you want to leave the group permanently.");
			label:SetButton(true);
			label:SetInfoColor("red");
		self.groupList:AddItem(label);
		
		-- Called when the button is clicked.
		function label.DoClick(button)
			Derma_Query("Are you sure that you want to leave the group?", "Leave the group.", "Yes", function()
				Clockwork:RunCommand("GroupLeave");
			end, "No", function() end);
		end;
		
		local memberList = {};
		local formList = {};
		
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				local theirGroup = v:GetSharedVar("Group");
				local theirRank = v:GetSharedVar("Rank");
				
				if (theirGroup and theirGroup == myGroup) then
					memberList[#memberList + 1] = v;
					
					if (!formList[theirRank]) then
						formList[theirRank] = vgui.Create("DForm", self);
						formList[theirRank]:SetName(Schema:RankToName(theirRank));
						formList[theirRank]:SetPadding(4);
					end;
				end;
			end;
		end;
		
		table.sort(memberList, function(a, b)
			return a:GetSharedVar("Rank") > b:GetSharedVar("Rank");
		end);
		
		if (#memberList > 0) then
			if (Clockwork.Client:GetSharedVar("Rank") == RANK_MAJ) then
				local label = vgui.Create("cwInfoText", self);
					label:SetText("You can manage characters in your group by clicking their name.");
					label:SetInfoColor("blue");
				self.membersList:AddItem(label);
			end;
			
			for k, v in ipairs(memberList) do
				local theirRank = v:GetSharedVar("Rank");
				local label = vgui.Create("cwInfoText", self);
					label:SetText(Schema:RankToTitle(theirRank)..". "..v:Name());
					label:SetInfoColor(_team.GetColor(v:Team()));
				formList[theirRank]:AddItem(label);
				
				if (Clockwork.Client:GetSharedVar("Rank") == RANK_MAJ) then
					label:SetButton(true);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						if (IsValid(v) and v:GetSharedVar("Rank") != RANK_MAJ) then
							local options = {};
							
							options["Kick"] = function()
								Clockwork:RunCommand("GroupKick", v:SteamID());
							end;
							
							options["Rank"] = {};
							options["Rank"]["1. Recruit"] = function()
								Clockwork:RunCommand("GroupSetRank", v:SteamID(), RANK_RCT);
							end;
							options["Rank"]["2. Private"] = function()
								Clockwork:RunCommand("GroupSetRank", v:SteamID(), RANK_PVT);
							end;
							options["Rank"]["3. Sergeant"] = function()
								Clockwork:RunCommand("GroupSetRank", v:SteamID(), RANK_SGT);
							end;
							options["Rank"]["4. Lieutenant"] = function()
								Clockwork:RunCommand("GroupSetRank", v:SteamID(), RANK_LT);
							end;
							options["Rank"]["5. Captain"] = function()
								Derma_Query("Are you sure that you want to make them a Captain?", "Make them a Captain.", "Yes", function()
									Clockwork:RunCommand("GroupSetRank", v:SteamID(), RANK_CPT);
								end, "No", function() end);
							end;
							
							Clockwork:AddMenuFromData(nil, options);
						end;
					end;
				end;
			end;
			
			for i = RANK_MAJ, RANK_RCT, -1 do
				if (formList[i]) then
					self.membersList:AddItem(formList[i]);
				end;
			end;
			
			local groupNotesForm = vgui.Create("DForm", self);
			groupNotesForm:SetName("Group Notes");
			groupNotesForm:SetPadding(4);
			
			local textEntry = vgui.Create("DTextEntry");
				textEntry:SetMultiline(true);
				textEntry:SetHeight(512);
			textEntry:SetText("");
			
			if (Schema.groupNotes) then
				textEntry:SetText(Schema.groupNotes);
			end;
			
			-- A function to set the text entry's real value.
			function textEntry:SetRealValue(text)
				self:SetValue(text);
				self:SetCaretPos(string.len(text));
			end;
			
			-- Called each frame.
			function textEntry:Think()
				local text = self:GetValue();
				
				if (string.len(text) > 1024) then
					self:SetRealValue(string.sub(text, 0, 1024));
					surface.PlaySound("common/talk.wav");
				end;
			end;
			
			if (Clockwork.Client:GetSharedVar("Rank") >= RANK_SGT) then
				local button = vgui.Create("DButton");
				button:SetText("Okay");
				
				-- Called when the button is clicked.
				function button.DoClick(button)
					Clockwork:StartDataStream(
						"GroupNotes", string.sub(textEntry:GetValue(), 0, 1024)
					);
					gui.EnableScreenClicker(false);
				end;

				groupNotesForm:AddItem(textEntry);
				groupNotesForm:AddItem(button);
				textEntry:SetEditable(true);
			else
				groupNotesForm:AddItem(textEntry);
				textEntry:SetEditable(false);
			end;
			
			self.groupList:AddItem(groupNotesForm);
		else
			local label = vgui.Create("cwInfoText", self);
				label:SetText("No characters in your group are playing.");
				label:SetInfoColor("orange");
			self.membersList:AddItem(label);
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("Starting a group will cost you "..FORMAT_CASH(1000, nil, true)..".");
			label:SetInfoColor("blue");
		self.groupList:AddItem(label);
		
		local createForm = vgui.Create("DForm", self);
		createForm:SetName("Start a Group");
		createForm:SetPadding(4);
		
		local textEntry = createForm:TextEntry("Name");
			textEntry:SetToolTip("Choose a nice name for your group.");
		local okayButton = createForm:Button("Okay");
		
		-- Called when the button is clicked.
		function okayButton.DoClick(okayButton)
			Clockwork:RunCommand("GroupStart", textEntry:GetValue());
		end;
		
		self.groupList:AddItem(createForm);
		
		local label = vgui.Create("cwInfoText", self);
			label:SetText("You need to be a member of a group to access this section!");
			label:SetInfoColor("red");
		self.membersList:AddItem(label);
	end;

	self.membersList:InvalidateLayout(true);
	self.groupList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (Clockwork.menu:GetActivePanel() == self) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.columnSheet:StretchToParent(4, 28, 4, 4);
	self.membersList:StretchToParent(4, 4, 4, 4);
	self.groupList:StretchToParent(4, 4, 4, 4);
	
	self:SetSize(self:GetWide(), ScrH() * 0.75);
	derma.SkinHook("Layout", "Frame", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwGroup", PANEL, "DFrame");