// Blind

SS.Blind = {}

// Usermessage

function SS.Blind.Usermessage(Message)
	local Bool = Message:ReadBool()
	
	if (Bool) then
		SS.Notice.New("Blind", "You have been blinded!", Color(255, 60, 60, 255))
		SS.Notice.Content("You probably deserve it", Color(255, 255, 255, 255))
		SS.Notice.Finish()
	else
		SS.Notice.Hide("Blind")
	end
end

usermessage.Hook("SS.Blind", SS.Blind.Usermessage)