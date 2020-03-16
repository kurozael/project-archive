SS.Part.Add("AFK", "Name")

// Locals

local User = LocalPlayer()

// AFK

SS.AFK = {}

// Usermessage

function SS.AFK.Usermessage(Message)
	local Bool = Message:ReadBool()
	
	if (Bool) then
		SS.Notice.New("AFK", "You are currently AFK!", Color(255, 60, 60, 255))
		SS.Notice.Content("Please move again to continue playing", Color(255, 255, 255, 255))
		SS.Notice.Finish()
	else
		SS.Notice.Hide("AFK")
	end
end

usermessage.Hook("SS.AFK", SS.AFK.Usermessage)