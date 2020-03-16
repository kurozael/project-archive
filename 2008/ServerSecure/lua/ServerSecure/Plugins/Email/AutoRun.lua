local Plugin = SS.Plugins:New("Email")

// When players values get set

function Plugin.PlayerSetVariables(Player)
	CVAR.New(Player, "Email", "Email Address", "")
end

// Get messages

function Plugin.Messages(Player)
	return table.Count(Plugin.MessagesTable(Player, "Inbox"))
end

// Get outbox messages

function Plugin.Outbox(Player)
	return table.Count(Plugin.MessagesTable(Player, "Outbox"))
end

// Get tables of messages

function Plugin.MessagesTable(Player, Type)
	local Email = CVAR.Request(Player, "Email")
	
	local Mail = {}
	
	if (file.IsDir("SS/Email/"..Email.."/")) then
		local Files = file.Find("../Data/SS/Email/"..Email.."/"..Type.."/*.txt")
		
		for K, V in pairs(Files) do
			local Data = "../Data/SS/Email/"..Email.."/"..Type.."/"..V
			
			local Title = string.Replace(V, ".txt", "")
			
			Mail[Title] = file.Read(Data)
		end
	end
	
	return Mail
end

// When players GUI is updated

function Plugin.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Messages", "Email: "..Plugin.Messages(Player))
	
	if (CVAR.Request(Player, "Email") == "") then
		Player:SetNetworkedString("Mail", "")
	else
		Player:SetNetworkedString("Mail", "Email: "..CVAR.Request(Player, "Email"))
	end
end

// Chat command

local EmailAccount = SS.Commands:New("EmailAccount")

function EmailAccount.Command(Player, Args)
	local Email = Args[1]
	
	Email = string.lower(Email)
	
	if (file.IsDir("SS/Email/"..Email.."/")) then
		SS.PlayerMessage(Player, "The email "..Email.." already exists!", 1)
		
		return
	end
	
	SS.PlayerMessage(Player, "Email account "..Email.." created! Type /email for help!", 0)
	
	CVAR.Update(Player, "Email", Email)
	
	Plugin.Send(Email, "Server Administrator", "Welcome", {"Welcome, to the email system!"}, "Both")
end

EmailAccount:Create(EmailAccount.Command, {"basic"}, "Create an email account", "<Username>", 1, " ")

// Send email

function Plugin.Send(User, Sender, Title, Text, Type)
	if (Type == "Both") then
		Plugin.Send(User, Sender, Title, Text, "Inbox")
		
		Plugin.Send(User, Sender, Title, Text, "Outbox")
		
		return
	end
	
	local Real = Sender.."\n"..os.date()
	
	for K, V in pairs(Text) do
		Real = Real.."\n"..V
	end
	
	local Send = User
	
	if (Type == "Outbox") then
		Send = Sender
	end
	
	file.Write("SS/Email/"..Send.."/"..Type.."/"..Title..".txt", Real)
	
	if (Type == "Inbox") then
		local Players = player.GetAll()
		
		for K, V in pairs(Players) do
			local Ready = V:IsReady()
			
			if (Ready) then
				if (CVAR.Request(V, "Email") == Send) then
					SS.PlayerMessage(V, "You have recieved a new email!", 0)
					
					local Panel = SS.Panel:New(V, "New Email!")
					
					Panel:Words("From: "..Sender)
					Panel:Words("Subject: "..Title)
					
					Panel:Button("Read", 'Email "Inbox" "'..Title..'"')
					Panel:Button("Delete", 'Email.Delete "Inbox" "'..Title..'"')
					
					Panel:Send()
					
					SS.Player.PlayerUpdateGUI(V)
				end
			end
		end
	end
end

// Chat command

local Email = SS.Commands:New("Email")

function Email.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Email Help")
	
	Panel:Words("Commands")
	Panel:Words(SS.Commands.Prefix().."emailaccount <Username>")
	Panel:Words(SS.Commands.Prefix().."emailsend <Username>, <Title>")
	Panel:Words(SS.Commands.Prefix().."emailread")
	
	Panel:Send()
end

Email:Create(Email.Command, {"basic"}, "View email help")

// Chat command

local EmailSend = SS.Commands:New("EmailSend")

function EmailSend.Command(Player, Args)
	local Email = CVAR.Request(Player, "Email")
	
	local Recipient = string.lower(Args[1])
	
	if not (Plugin.Check(Player)) then return end
	
	if not (file.IsDir("SS/Email/"..Recipient.."/")) then
		SS.PlayerMessage(Player, "No such email address!", 1)
		
		return
	end
	
	Plugin.Start(Player, Args[1], Args[2])
end

EmailSend:Create(EmailSend.Command, {"basic"}, "Send an email to another player", "<Email>, <Title>", 2, ", ")

// Start email

function Plugin.Start(Player, User, Title)
	TVAR.Update(Player, "email", {})
	
	TVAR.Request(Player, "email").Title = Title
	
	TVAR.Request(Player, "email").Recipient = User
	
	TVAR.Request(Player, "email").Text = {}
	
	local Panel = SS.Panel:New(Player, "New Email")
	
	Panel:Words("To: "..User)
	
	Panel:Words("Subject: "..Title)
	
	Panel:Words("Talk to add a new line! If the menu closes")
	
	Panel:Words("you can still type to add a new line!")
	
	Panel:Send()
end

// When player talks

function Plugin.PlayerTypedText(Player, Text)
	if (TVAR.Request(Player, "email")) then
		table.insert(TVAR.Request(Player, "email").Text, Text)
		
		local Panel = SS.Panel:New(Player, "New Email")
		
		Panel:Words("To: "..TVAR.Request(Player, "email").Recipient)
		
		Panel:Words("Subject: "..TVAR.Request(Player, "email").Title)
		
		for K, V in pairs(TVAR.Request(Player, "email").Text) do
			Panel:Words(V)
		end
		
		Panel:Button("Send", "Email.Send")
		
		Panel:Send()
		
		Player:SetTextReturn("", 1)
	end
end

// Does player have an account

function Plugin.Check(Player)
	local Email = CVAR.Request(Player, "Email")
	
	if (Email == "") then
		SS.PlayerMessage(Player, "Type "..SS.Commands.Prefix().."account <Username> to create an email account!", 1)
		
		return false
	end
	
	return true
end

// Send email

function Plugin.Finalise(Player, Command, Args)
	if not (Plugin.Check(Player)) then return end
	
	if not (TVAR.Request(Player, "email")) then
		SS.PlayerMessage(Player, "You have not started an email!", 1)
		
		return
	end
	
	Plugin.Send(TVAR.Request(Player, "Email").Recipient, CVAR.Request(Player, "Email"), TVAR.Request(Player, "Email").Title, TVAR.Request(Player, "Email").Text, "Both")	
	
	SS.PlayerMessage(Player, "Email has been sent!", 0)
	
	TVAR.Update(Player, "email", nil)
end

concommand.Add("Email.Send", Plugin.Finalise)

// Read email

function Plugin.Read(Player, Command, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) then return end
	
	local Email = CVAR.Request(Player, "Email")
	
	for K, V in pairs(Plugin.MessagesTable(Player, Args[1])) do
		if (string.lower(K) == string.lower(Args[2])) then
			local Panel = SS.Panel:New(Player, K)
			
			local Text = string.Explode("\n", V)
			
			local Sender = Text[1]
			
			local Date = Text[2]
			
			Panel:Words("Sender: "..Sender)
			Panel:Words("Date Sent: "..Date)
			
			table.remove(Text, 1)
			
			table.remove(Text, 1)
			
			for K, V in pairs(Text) do
				V = string.Trim(V)
				
				Panel:Words(V)
			end
			
			if (Args[1] == "Inbox") then
				Panel:Button("Reply", 'Email.Reply "'..Sender..'" "'..K..'"')
			end
			
			Panel:Button("Delete", 'Email.Delete "'..Args[1]..'" "'..K..'"')
			
			Panel:Send()
			
			return
		end
	end
end

concommand.Add("Email", Plugin.Read)

// Reply

function Plugin.Reply(Player, Command, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) then return end
	
	if not (Plugin.Check(Player)) then return end
	
	Plugin.Start(Player, Args[1], "(RE) "..Args[2])
end

concommand.Add("Email.Reply", Plugin.Reply)

// Delete email

function Plugin.Delete(Player, Command, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) then return end
	
	local Email = CVAR.Request(Player, "Email")
	
	if (Email != "") then
		file.Delete("SS/Email/"..Email.."/"..Args[1].."/"..Args[2]..".txt")
		
		SS.PlayerMessage(Player, "Message '"..Args[2].."' deleted from "..Args[1].."!", 0)
		
		SS.Player.PlayerUpdateGUI(Player)
	end
end

concommand.Add("Email.Delete", Plugin.Delete)

// Delete all in folder

function Plugin.Folder(Player, Command, Args)
	if not (Args) or not (Args[1]) then return end
	
	if (Args[1] != "Inbox") and (Args[1] != "Outbox") then return end
	
	local Email = CVAR.Request(Player, "Email")
	
	if (Email != "") then
		local Files = file.Find("SS/Email/"..Email.."/"..Args[1].."/*.txt")
		
		for K, V in pairs(Files) do
			file.Delete("SS/Email/"..Email.."/"..Args[1].."/"..V)
		end
		
		SS.PlayerMessage(Player, "All emails in folder "..Args[1].." have been deleted!", 0)
	end
end

concommand.Add("Email.Folder", Plugin.Folder)

// View email

function Plugin.View(Player, Command, Args)
	if not (Args) or not (Args[1]) then return end
	
	if not (Plugin.Check(Player)) then return end
	
	if (Args[1] != "Inbox") and (Args[1] != "Outbox") then return end
	
	local Panel = SS.Panel:New(Player, Args[1].." Messages")
	
	Panel:Button("Delete all in this folder", 'Email.Folder "'..Args[1]..'"')
	
	for K, V in pairs(Plugin.MessagesTable(Player, Args[1])) do
		Panel:Button(K, 'Email "'..Args[1]..'" "'..K..'"')
	end
	
	Panel:Send()
end

concommand.Add("Email.View", Plugin.View)

// Chat command

local EmailRead = SS.Commands:New("EmailRead")

function EmailRead.Command(Player, Args)
	if not (Plugin.Check(Player)) then return end
	
	local Panel = SS.Panel:New(Player, "Email Messages")
	
	Panel:Button("Inbox ("..Plugin.Messages(Player)..")", 'Email.View Inbox')
	Panel:Button("Outbox ("..Plugin.Outbox(Player)..")", 'Email.View Outbox')
	
	Panel:Send()
end

EmailRead:Create(EmailRead.Command, {"basic"}, "Read email")

// Finish plugin

Plugin:Create()

SS.Adverts.Add("Type "..SS.Commands.Prefix().."account <Username> to create an email account!")