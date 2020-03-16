--[[
Name: "sh_quiz.lua".
Product: "kuroScript".
--]]

kuroScript.quiz = {};
kuroScript.quiz.stored = {};

-- A function to set whether the quiz is enabled.
function kuroScript.quiz.SetEnabled(enabled)
	kuroScript.quiz.enabled = enabled;
end;

-- A function to get whether the quiz is enabled.
function kuroScript.quiz.GetEnabled()
	return kuroScript.quiz.enabled;
end;

-- A function to get the amount of quiz questions.
function kuroScript.quiz.GetQuestionsAmount()
	return table.Count(kuroScript.quiz.stored);
end;

-- A function to get the quiz questions.
function kuroScript.quiz.GetQuestions()
	return kuroScript.quiz.stored;
end;

-- A function to get a question.
function kuroScript.quiz.GetQuestion(index)
	return kuroScript.quiz.stored[index];
end;

-- A function to get if an answer is correct.
function kuroScript.quiz.IsAnswerCorrect(index, answer)
	question = kuroScript.quiz.GetQuestion(index);
	
	-- Check if a statement is true.
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
function kuroScript.quiz.AddQuestion(question, answer, ...)
	local index = kuroScript.frame:GetShortCRC(question);
	
	-- Set some information.
	kuroScript.quiz.stored[index] = {
		possibleAnswers = {...},
		question = question,
		answer = answer
	};
end;

-- A function to remove a quiz question.
function kuroScript.quiz.RemoveQuestion(question)
	if ( kuroScript.quiz.stored[question] ) then
		kuroScript.quiz.stored[question] = nil;
	else
		local index = kuroScript.frame:GetShortCRC(question);
		
		-- Check if a statement is true.
		if ( kuroScript.quiz.stored[index] ) then
			kuroScript.quiz.stored[index] = nil;
		end;
	end;
end;

-- Check if a statement is true.
if (CLIENT) then
	function kuroScript.quiz.SetCompleted(completed)
		kuroScript.quiz.completed = completed;
	end;
	
	-- A function to get whether the quiz is completed.
	function kuroScript.quiz.GetCompleted()
		return kuroScript.quiz.completed;
	end;
else
	function kuroScript.quiz.SetCompleted(player, completed)
		if (completed) then
			player:SetData( "quiz", kuroScript.quiz.GetQuestionsAmount() );
		else
			player:SetData("quiz", nil);
		end;
		
		-- Start a user message.
		umsg.Start("ks_QuizCompleted", player);
			umsg.Bool(completed);
		umsg.End();
	end;
	
	-- A function to get whether a player has completed the quiz.
	function kuroScript.quiz.GetCompleted(player)
		return player:GetData("quiz") == kuroScript.quiz.GetQuestionsAmount();
	end;
	
	-- A function to set the quiz percentage.
	function kuroScript.quiz.SetPercentage(percentage)
		kuroScript.quiz.percentage = percentage;
	end;
	
	-- A function to get the quiz percentage.
	function kuroScript.quiz.GetPercentage()
		return kuroScript.quiz.percentage or 100;
	end;
	
	-- A function to call the quiz kick callback.
	function kuroScript.quiz.CallKickCallback(player, correctAnswers)
		local kickCallback = kuroScript.quiz.GetKickCallback();
		
		-- Check if a statement is true.
		if (kickCallback) then
			kickCallback(player, correctAnswers);
		end;
	end;
	
	-- A function to get the quiz kick callback.
	function kuroScript.quiz.GetKickCallback()
		if (kuroScript.quiz.kickCallback) then
			return kuroScript.quiz.kickCallback;
		else
			return function(player, correctAnswers)
				player:Kick("You got too many questions wrong!");
			end;
		end;
	end;
	
	-- A function to set the quiz kick callback.
	function kuroScript.quiz.SetKickCallback(callback)
		kuroScript.quiz.kickCallback = callback;
	end;
end;