--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.quiz = {};
openAura.quiz.stored = {};

-- A function to set the quiz name.
function openAura.quiz:SetName(name)
	self.name = name;
end;

-- A function to get the quiz name.
function openAura.quiz:GetName()
	return self.name or "Questions";
end;

-- A function to set whether the quiz is enabled.
function openAura.quiz:SetEnabled(enabled)
	self.enabled = enabled;
end;

-- A function to get whether the quiz is enabled.
function openAura.quiz:GetEnabled()
	return self.enabled;
end;

-- A function to get the amount of quiz questions.
function openAura.quiz:GetQuestionsAmount()
	return table.Count(self.stored);
end;

-- A function to get the quiz questions.
function openAura.quiz:GetQuestions()
	return self.stored;
end;

-- A function to get a question.
function openAura.quiz:GetQuestion(index)
	return self.stored[index];
end;

-- A function to get if an answer is correct.
function openAura.quiz:IsAnswerCorrect(index, answer)
	question = self:GetQuestion(index);
	
	if (question) then
		if ( type(question.answer) == "table" and table.HasValue(question.answer, answer) ) then
			return true;
		elseif ( answer == question.possibleAnswers[question.answer] ) then
			return true;
		elseif (question.answer == answer) then
			return true;
		end;
	end;
end;

-- A function to add a new quiz question.
function openAura.quiz:AddQuestion(question, answer, ...)
	local index = openAura:GetShortCRC(question);
	
	self.stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	};
end;

-- A function to remove a quiz question.
function openAura.quiz:RemoveQuestion(question)
	if ( self.stored[question] ) then
		self.stored[question] = nil;
	else
		local index = openAura:GetShortCRC(question);
		
		if ( self.stored[index] ) then
			self.stored[index] = nil;
		end;
	end;
end;

if (CLIENT) then
	function openAura.quiz:SetCompleted(completed)
		self.completed = completed;
	end;
	
	-- A function to get whether the quiz is completed.
	function openAura.quiz:GetCompleted()
		return self.completed;
	end;
	
	-- A function to get the quiz panel.
	function openAura.quiz:GetPanel()
		if ( IsValid(self.panel) ) then
			return self.panel;
		end;
	end;
else
	function openAura.quiz:SetCompleted(player, completed)
		if (completed) then
			player:SetData( "quiz", self:GetQuestionsAmount() );
		else
			player:SetData("quiz", nil);
		end;
		
		umsg.Start("aura_QuizCompleted", player);
			umsg.Bool(completed);
		umsg.End();
	end;
	
	-- A function to get whether a player has completed the quiz.
	function openAura.quiz:GetCompleted(player)
		if ( player:GetData("quiz") == self:GetQuestionsAmount() ) then
			return true;
		else
			return player:IsBot();
		end;
	end;
	
	-- A function to set the quiz percentage.
	function openAura.quiz:SetPercentage(percentage)
		self.percentage = percentage;
	end;
	
	-- A function to get the quiz percentage.
	function openAura.quiz:GetPercentage()
		return self.percentage or 100;
	end;
	
	-- A function to call the quiz kick Callback.
	function openAura.quiz:CallKickCallback(player, correctAnswers)
		local kickCallback = self:GetKickCallback();
		
		if (kickCallback) then
			kickCallback(player, correctAnswers);
		end;
	end;
	
	-- A function to get the quiz kick Callback.
	function openAura.quiz:GetKickCallback()
		if (self.kickCallback) then
			return self.kickCallback;
		else
			return function(player, correctAnswers)
				player:Kick("You got too many questions wrong!");
			end;
		end;
	end;
	
	-- A function to set the quiz kick Callback.
	function openAura.quiz:SetKickCallback(Callback)
		self.kickCallback = Callback;
	end;
end;