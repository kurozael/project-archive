// Ban

SS.Ban        = {}
SS.Ban.Reason = "<None Specified>"
SS.Ban.Time   = 0
SS.Ban.Kick   = 0

// Recieve

function SS.Ban.Recieve(Message)
	SS.Ban.Reason = Message:ReadString()
	SS.Ban.Time   = Message:ReadShort()
	SS.Ban.Kick   = 10
	SS.Ban.Banned = true
	
	// Timer
	
	local function Reduce()
		SS.Ban.Kick = math.Clamp(SS.Ban.Kick - 1, 0, 10)
	end
	
	timer.Create("SS.Ban", 1, 10, Reduce)
end

usermessage.Hook("SS.Ban", SS.Ban.Recieve)

// HUDDrawScoreBoard

function SS.Ban.HUDDrawScoreBoard()
	if (SS.Ban.Banned) then
		SS.Notice.New("Ban", "You have been banned!", Color(255, 60, 60, 255))
		SS.Notice.Content("You will be kicked in: "..SS.Ban.Kick.." second(s)", Color(255, 255, 255, 255))
		SS.Notice.Content("Reason: "..SS.Ban.Reason, Color(255, 255, 255, 255))
		
		if (SS.Ban.Time < 60) then
			SS.Notice.Content("Time: "..SS.Ban.Time.." minute(s)", Color(255, 255, 255, 255))
		else
			local Seconds = SS.Ban.Time * 60
			
			local Time = string.FormattedTime(Seconds)
			
			Time.m = math.Clamp(Time.m, 0, 60)
			
			SS.Notice.Content("Time: "..Time.h.." hour(s) and "..Time.m.." minute(s)", Color(255, 255, 255, 255))
		end
		
		SS.Notice.Finish()
	end
end

hook.Add("HUDDrawScoreBoard", "SS.Ban.HUDDrawScoreBoard", SS.Ban.HUDDrawScoreBoard)

// HUDShouldDraw

function SS.Ban.HUDShouldDraw(ID)
	if (ID != "CHudGMod" and SS.Ban.Banned) then
		return false
	end
end

hook.Add("HUDShouldDraw", "SS.Ban.HUDShouldDraw", SS.Ban.HUDShouldDraw) 