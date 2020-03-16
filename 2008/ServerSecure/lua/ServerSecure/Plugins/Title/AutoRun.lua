local Plugin = SS.Plugins:New("Title")

// When players values get set

function Plugin.PlayerSetVariables(Player)
	CVAR.New(Player, "Title", "Custom Title", "")
end

// When players GUI is updated

function Plugin.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Title", CVAR.Request(Player, "title"))
end

// Chat command

local PlayerTitle = SS.Commands:New("PlayerTitle")

function PlayerTitle.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	local Title = table.concat(Args, " ", 2)
	
	if (string.lower(Title) == "none") then
		Title = ""
	end
	
	if (string.len(Title) >= 75) then
		Title = string.sub(Title, 0, 72).."..."
	end
	
	if (Person) then
		CVAR.Update(Person, "Title", Title)
		
		SS.PlayerMessage(Player, "You changed "..Person:Name().."'s custom title!", 0)
		
		if (Player == Person) then return end
		
		SS.PlayerMessage(Person, Player:Name().." changed your custom title to "..Title.."!", 0)
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

PlayerTitle:Create(PlayerTitle.Command, {"administrator", "playertitle"}, "Set somebodies custom title", "<Player> <Title>", 2, " ")

// Finish plugin

Plugin:Create()