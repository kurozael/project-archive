local Plugin = SS.Plugins:New("Smartness")

// Config

Plugin.Lose = 25 -- Points lost for each bad word
Plugin.Start  = 5000 -- Smartness players start with

Plugin.Ban = true -- Ban if smartness gets to a point
Plugin.Time = 1440 -- Time in minutes the ban lasts
Plugin.Points = 1000 -- The point inwhich a players smartness must decrease to for them to get banned

Plugin.Rating = {}

Plugin.Rating.Smart = {"Smart", "Agree"} -- If player is rated this they smartness will go up below value
Plugin.Rating.Gain = 25 -- If rated the above players smartness will raise by this

Plugin.Rating.Dumb = {"Dumb", "Idiot"} -- If player is rated this they smartness will go down below value
Plugin.Rating.Lose = 25 -- If rated the above players smartness will lower by this

Plugin.Rating.Posts = 10 -- Posts without one single mistake gains you smartness!

Plugin.Words = {} -- Don't edit these.

Plugin.Words.Bad = { -- Bad words
	"cant",
	"dont",
	"wont",
	"i",
	"u",
	"sux",
	"m8",
	"hax",
	"suxxor",
	"haxxor",
	"r",
	"leik",
	"liek",
	"sechs",
	"its",
	"dood",
	"h4x",
	"omfg",
	"llo",
	"cunna",
	"coona",
	"canna",
	"gayry"
}

// Check smartness

function Plugin.Check(Player)
	if Plugin.Ban then
		if CVAR.Request(Player, "Smartness") <= Plugin.Points then
			CVAR.Update(Player, "Smartness", Plugin.Start)
			
			SS.PlayerMessage(0, Player:Name().." banned for "..Plugin.Time.." minutes by Smartness system!", 0)
			
			SS.Lib.PlayerBan(Player, Plugin.Time, "Your smartness is too low!")
		end
	end
end

// Take smartness

function Plugin.Take(Player, Amount, Reason)
	umsg.Start("Smartness.Lose", Player)
		umsg.Short(Amount)
		umsg.String(Reason)
	umsg.End()
	
	SS.Player.PlayerUpdateGUI(Player)
end

------[ GIVE SMARTNESS ]---------

function Plugin.Give(Player, Amount, Reason)
	umsg.Start("Smartness.Gain", Player)
		umsg.Short(Amount)
		umsg.String(Reason)
	umsg.End()
	
	SS.Player.PlayerUpdateGUI(Player)
end

// When players variables are set

function Plugin.PlayerSetVariables(Player)
	CVAR.New(Player, "Smartness", "Smartness", Plugin.Start)
	CVAR.New(Player, "Correct", "Correct Sentances", 0)
end

// Check if something is dumb

function Plugin.Dumb(Rating)
	for K, V in pairs(Plugin.Rating.Dumb) do
		if (V == Rating) then
			return true
		end
	end
	
	return false
end

// Check if something is smart

function Plugin.Smart(Rating)
	for K, V in pairs(Plugin.Rating.Smart) do
		if (V == Rating) then
			return true
		end
	end
	
	return false
end

// When player is rated

function Plugin.PlayerRated(Player, Rating)
	if (Plugin.Dumb(Rating)) then
		CVAR.Update(Player, "Smartness", CVAR.Request(Player, "Smartness") - Plugin.Rating.Lose)
		
		Plugin.Take(Player, Plugin.Rating.Lose, "Rated "..Rating)
	end
	
	if (Plugin.Smart(Rating)) then
		CVAR.Update(Player, "Smartness", CVAR.Request(Player, "Smartness") + Plugin.Rating.Gain)
		
		Plugin.Give(Player, Plugin.Rating.Gain, "Rated "..Rating)
	end
	
	Plugin.Check(Player)
end

// When players GUI is updated

function Plugin.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Smartness", "Smartness: "..CVAR.Request(Player, "Smartness"))
end


// When player says something

function Plugin.PlayerTypedText(Player, Text)
	Text = " "..Text.." "
	
	local Amount = 0
	local Good = 0
	
	for K, V in pairs(Plugin.Words.Bad) do
		if (string.find(Text, " "..V.." ")) then
			Amount = Amount + Plugin.Lose
			
			CVAR.Update(Player, "Smartness", CVAR.Request(Player, "Smartness") - Plugin.Lose)
		end
	end
	
	if (Amount != 0) then
		Plugin.Take(Player, Amount, "Terrible Spelling")
	else
		CVAR.Update(Player, "Correct", CVAR.Request(Player, "Correct") + 1)
		
		if (CVAR.Request(Player, "Correct") >= Plugin.Rating.Posts) then
			CVAR.Update(Player, "Correct", 0)
			
			CVAR.Update(Player, "Smartness", CVAR.Request(Player, "Smartness") + Plugin.Rating.Gain)
			
			Plugin.Give(Player, Plugin.Rating.Gain, Plugin.Rating.Posts.." Perfect Posts!")
		end
	end
	
	Plugin.Check(Player)
end

Plugin:Create()