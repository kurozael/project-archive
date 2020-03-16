--[[
Name: "cl_quiz.lua".
Product: "HL2 RP".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.panelList = vgui.Create("DPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(3);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
end;

-- Called each frame.
function PANEL:Think()
	local scrW = ScrW();
	local scrH = ScrH();
	
	-- Check if a statement is true.
	if ( self.questionsForm and self.questionsForm:IsValid() ) then
		self:SetSize(scrW * 0.5, self.questionsForm:GetTall() + 12);
	else
		self:SetSize(scrW * 0.5, scrH * 0.75);
	end;
	
	-- Set some information.
	self:SetPos( (scrW / 2) - (self:GetWide() / 2), (scrH / 2) - (self:GetTall() / 2) );
end;

-- A function to populate the panel.
function PANEL:Populate()
	local quizQuestions = kuroScript.quiz.GetQuestions();
	local questions = {};
	local k2, v2;
	local k, v;
	
	-- Set some information.
	self.questionsForm = vgui.Create("DForm");
	self.questionsForm:SetName("Questions");
	self.questionsForm:SetPadding(4);
	
	-- Clear the panel list.
	self.panelList:Clear();
	self.panelList:AddItem(self.questionsForm);
	
	-- Loop through each value in a table.
	for k, v in pairs(quizQuestions) do
		questions[k] = {k, v};
	end;
	
	-- Sort the questions.
	table.sort(questions, function(a, b)
		return a[2].question < b[2].question;
	end);
	
	-- Loop through each value in a table.
	for k, v in pairs(questions) do
		if (ScrW() < 1024) then
			local panel = vgui.Create("DMultiChoice", self.questionsForm);
			local help = self.questionsForm:Help(v[2].question);
			local key = v[1];
			
			-- Add an item to the form.
			self.questionsForm:AddItem(panel);
			
			-- Set some information.
			panel:SetEditable(false);
			panel.Stretch = true;
			
			-- Called when an option is selected.
			function panel:OnSelect(index, value, data)
				datastream.StreamToServer( "ks_QuizAnswer", {key, index} );
			end;
			
			-- Loop through each value in a table.
			for k2, v2 in ipairs(v[2].possibleAnswers) do
				panel:AddChoice(v2);
			end;
		else
			local panel = self.questionsForm:MultiChoice(v[2].question);
			local key = v[1];
			
			-- Set some information.
			panel:SetEditable(false);
			panel.Stretch = true;
			
			-- Called when an option is selected.
			function panel:OnSelect(index, value, data)
				datastream.StreamToServer( "ks_QuizAnswer", {key, index} );
			end;
			
			-- Loop through each value in a table.
			for k2, v2 in ipairs(v[2].possibleAnswers) do
				panel:AddChoice(v2);
			end;
		end;
	end;
	
	-- Set some information.
	local panel = self.questionsForm:Button("Okay");
	
	-- Called when the button is clicked.
	function panel.DoClick(button)
		datastream.StreamToServer("ks_QuizCompleted", true);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.panelList:StretchToParent(4, 4, 4, 4);
end;

-- Register the panel.
vgui.Register("ks_Quiz", PANEL, "DPanel");