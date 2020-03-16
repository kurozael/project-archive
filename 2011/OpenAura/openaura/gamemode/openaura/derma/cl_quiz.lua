--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.createTime = SysTime();
	
	self:SetPaintBackground(false);
	self:SetMouseInputEnabled(true);
	self:SetKeyboardInputEnabled(true);
	
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
 	self.panelList:SetDrawBackground(false);
	self.panelList:EnableVerticalScrollbar();
end;

-- Called when the panel is painted.
function PANEL:Paint()
	openAura:RegisterBackgroundBlur(self, self.createTime);
	
	derma.SkinHook("Paint", "Panel", self);
	
	return true;
end;

-- A function to populate the panel.
function PANEL:Populate()
	local smallTextFont = openAura.option:GetFont("menu_text_small");
	local quizQuestions = openAura.quiz:GetQuestions();
	local questions = {};
	
	self.questionsForm = vgui.Create("DForm");
	self.questionsForm:SetName( openAura.quiz:GetName() );
	self.questionsForm:SetPadding(4);
	
	self.panelList:Clear(true);
	
	local label = vgui.Create("aura_InfoText", self);
		label:SetText("If any answers are incorrect, you may be kicked from the server.");
		label:SetInfoColor("orange");
	self.panelList:AddItem(label);

	self.panelList:AddItem(self.questionsForm);
	
	for k, v in pairs(quizQuestions) do
		questions[k] = {k, v};
	end;
	
	table.sort(questions, function(a, b)
		return a[2].question < b[2].question;
	end);
	
	for k, v in pairs(questions) do
		if (ScrW() < 1024) then
			local panel = vgui.Create("DMultiChoice", self.questionsForm);
			local help = self.questionsForm:Help(v[2].question);
			local key = v[1];
			
			self.questionsForm:AddItem(panel);
			
			panel:SetEditable(false);
			panel.Stretch = true;
			
			-- Called when an option is selected.
			function panel:OnSelect(index, value, data)
				openAura:StartDataStream( "QuizAnswer", {key, index} );
			end;
			
			for k2, v2 in ipairs(v[2].possibleAnswers) do
				panel:AddChoice(v2);
			end;
		else
			local panel = self.questionsForm:MultiChoice(v[2].question);
			local key = v[1];
			
			panel:SetEditable(false);
			panel.Stretch = true;
			
			-- Called when an option is selected.
			function panel:OnSelect(index, value, data)
				openAura:StartDataStream( "QuizAnswer", {key, index} );
			end;
			
			for k2, v2 in ipairs(v[2].possibleAnswers) do
				panel:AddChoice(v2);
			end;
		end;
	end;
	
	self.disconnectButton = vgui.Create("aura_LabelButton", self);
	self.disconnectButton:SetText("DISCONNECT");
	self.disconnectButton:SetFont(smallTextFont);
	self.disconnectButton:SetCallback(function(panel)
		RunConsoleCommand("disconnect");
	end);
	self.disconnectButton:SizeToContents();
	self.disconnectButton:SetMouseInputEnabled(true);
	
	self.continueButton = vgui.Create("aura_LabelButton", self);
	self.continueButton:SetText("CONTINUE");
	self.continueButton:SetFont(smallTextFont);
	self.continueButton:SetCallback(function(panel)
		openAura:StartDataStream("QuizCompleted", true);
	end);
	self.continueButton:SizeToContents();
	self.continueButton:SetMouseInputEnabled(true);
	
	self.panelList:AddItem(self.disconnectButton);
	self.panelList:AddItem(self.continueButton);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local scrW = ScrW();
	local scrH = ScrH();
	
	self.panelList:StretchToParent(0, 0, 0, 0);
	
	self:SetSize( scrW * 0.5, math.min(self.panelList.pnlCanvas:GetTall() + 8, ScrH() * 0.75) );
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
	
	derma.SkinHook("Layout", "Panel", self);
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("aura_Quiz", PANEL, "DPanel");