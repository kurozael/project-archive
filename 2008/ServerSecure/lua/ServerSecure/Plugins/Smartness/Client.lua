SS.Part.Add("Smartness", "Bar")
SS.Part.Add("Smartness", "Hover")

// Core

Smartness = {}
Smartness.Fade = {false, 0, 0, 0, 255, 20, false}

// Lose smartness

function Smartness.Lose(Message)
	local Amount = Message:ReadShort()
	local Reason = Message:ReadString()
	
	Smartness.Fade = {true, Amount, ScrW() / 2, ScrH() / 2, 255, 20, false, Reason }
end

usermessage.Hook("Smartness.Lose", Smartness.Lose)

// Gain smartness

function Smartness.Gain(Message)
	local Amount = Message:ReadShort()
	local Reason = Message:ReadString()
	
	Smartness.Fade = {true, Amount, ScrW() / 2, ScrH() / 2, 255, 20, true, Reason}
end

usermessage.Hook("Smartness.Gain", Smartness.Gain)

// Draw smartness

function Smartness.HUD()
	if Smartness.Fade[1] then
		if not Smartness.Fade[7] then
			draw.SimpleText("- "..Smartness.Fade[2].." Smartness ("..Smartness.Fade[8]..")", "Default", Smartness.Fade[3] + 1, Smartness.Fade[4] + 1, Color(0, 0, 0, Smartness.Fade[5]), 1, 1)
			draw.SimpleText("- "..Smartness.Fade[2].." Smartness ("..Smartness.Fade[8]..")", "Default", Smartness.Fade[3], Smartness.Fade[4], Color(255, 0, 0, Smartness.Fade[5]), 1, 1)
		else
			draw.SimpleText("+ "..Smartness.Fade[2].." Smartness ("..Smartness.Fade[8]..")", "Default", Smartness.Fade[3] + 1, Smartness.Fade[4] + 1, Color(0, 0, 0, Smartness.Fade[5]), 1, 1)
			draw.SimpleText("+ "..Smartness.Fade[2].." Smartness ("..Smartness.Fade[8]..")", "Default", Smartness.Fade[3], Smartness.Fade[4], Color(128, 255, 0, Smartness.Fade[5]), 1, 1)
		end
		
		Smartness.Fade[6] = Smartness.Fade[6] - 1
		Smartness.Fade[5] = Smartness.Fade[5] - 5
		Smartness.Fade[4] = Smartness.Fade[4] - Smartness.Fade[6]
		
		if Smartness.Fade[6] <= 1 then
			Smartness.Fade[6] = 2
		end
		
		if Smartness.Fade[5] <= 0 then
			Smartness.Fade[1] = false
		end
	end
end

hook.Add("HUDPaint", "Smartness.HUD", Smartness.HUD)