--[[
Name: "sh_quiz.lua".
Product: "nexus".
--]]

nexus.quiz = {};
nexus.quiz.stored = {};

-- A function to set the quiz name.
function nexus.quiz.SetName(name)
	nexus.quiz.name = name;
end;

-- A function to get the quiz name.
function nexus.quiz.GetName()
	return nexus.quiz.name or "Questions";
end;

-- A function to set whether the quiz is enabled.
function nexus.quiz.SetEnabled(enabled)
	nexus.quiz.enabled = enabled;
end;

-- A function to get whether the quiz is enabled.
function nexus.quiz.GetEnabled()
	return nexus.quiz.enabled;
end;

-- A function to get the amount of quiz questions.
function nexus.quiz.GetQuestionsAmount()
	return table.Count(nexus.quiz.stored);
end;

-- A function to get the quiz questions.
function nexus.quiz.GetQuestions()
	return nexus.quiz.stored;
end;

-- A function to get a question.
function nexus.quiz.GetQuestion(index)
	return nexus.quiz.stored[index];
end;

-- A function to get if an answer is correct.
function nexus.quiz.IsAnswerCorrect(index, answer)
	question = nexus.quiz.GetQuestion(index);
	
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
function nexus.quiz.AddQuestion(question, answer, ...)
	local index = NEXUS:GetShortCRC(question);
	
	nexus.quiz.stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	};
end;

-- A function to remove a quiz question.
function nexus.quiz.RemoveQuestion(question)
	if ( nexus.quiz.stored[question] ) then
		nexus.quiz.stored[question] = nil;
	else
		local index = NEXUS:GetShortCRC(question);
		
		if ( nexus.quiz.stored[index] ) then
			nexus.quiz.stored[index] = nil;
		end;
	end;
end;

if (CLIENT) then
	function nexus.quiz.SetCompleted(completed)
		nexus.quiz.completed = completed;
	end;
	
	-- A function to get whether the quiz is completed.
	function nexus.quiz.GetCompleted()
		return nexus.quiz.completed;
	end;
	
	-- A function to get the quiz panel.
	function nexus.quiz.GetPanel()
		if ( IsValid(nexus.quiz.panel) ) then
			return nexus.quiz.panel;
		end;
	end;
else
	function nexus.quiz.SetCompleted(player, completed)
		if (completed) then
			player:SetData( "quiz", nexus.quiz.GetQuestionsAmount() );
		else
			player:SetData("quiz", nil);
		end;
		
		umsg.Start("nx_QuizCompleted", player);
			umsg.Bool(completed);
		umsg.End();
	end;
	
	-- A function to get whether a player has completed the quiz.
	function nexus.quiz.GetCompleted(player)
		if ( player:GetData("quiz") == nexus.quiz.GetQuestionsAmount() ) then
			return true;
		else
			return player:IsBot();
		end;
	end;
	
	-- A function to set the quiz percentage.
	function nexus.quiz.SetPercentage(percentage)
		nexus.quiz.percentage = percentage;
	end;
	
	-- A function to get the quiz percentage.
	function nexus.quiz.GetPercentage()
		return nexus.quiz.percentage or 100;
	end;
	
	-- A function to call the quiz kick Callback.
	function nexus.quiz.CallKickCallback(player, correctAnswers)
		local kickCallback = nexus.quiz.GetKickCallback();
		
		if (kickCallback) then
			kickCallback(player, correctAnswers);
		end;
	end;
	
	-- A function to get the quiz kick Callback.
	function nexus.quiz.GetKickCallback()
		if (nexus.quiz.kickCallback) then
			return nexus.quiz.kickCallback;
		else
			return function(player, correctAnswers)
				player:Kick("You got too many questions wrong!");
			end;
		end;
	end;
	
	-- A function to set the quiz kick Callback.
	function nexus.quiz.SetKickCallback(Callback)
		nexus.quiz.kickCallback = Callback;
	end;
end;