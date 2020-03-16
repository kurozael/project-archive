Ratings = SS.Plugins:New("Ratings")

Ratings.List = {}

// Add a rating

function Ratings.Add(ID)
	table.insert(Ratings.List, ID)
end

// Rate

local Rate = SS.Commands:New("Rate")

Rate.Table = {}

// Rate console command

function Rate.Console(Player, Command, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) then return end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	local Rating = table.concat(Args, " ", 2)
	
	if (Person) then
		if Person == Player then SS.PlayerMessage(Player, "You cannot rate yourself!", 1) return end
		
		if Rate.Table[Player] == nil then
			Rate.Table[Player] = {}
			
			Rate.Table[Player][Person] = CurTime() - 1
		end
		
		if Rate.Table[Player][Person] == nil then
			Rate.Table[Player][Person] = CurTime() - 1
		end
		
		if Rate.Table[Player][Person] < CurTime() then
			if (Ratings.Rate(Player, Person, Rating)) then
				Rate.Table[Player][Person] = CurTime() + Ratings.Delay
			end
		else
			SS.PlayerMessage(Player, "You cannot rate this person again so soon!", 1)
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

concommand.Add("ss_rate", Rate.Console)

// Chat command

function Rate.Command(Player, Args)
	local Index = Args[1]
	
	local Rating = table.concat(Args, " ", 2)
	
	Player:ConCommand('ss_rate "'..Index..'" "'..Rating..'"\n')
end

Rate:Create(Rate.Command, {"basic"}, "Rate somebody", "<Player> <Rating>", 1, " ")

// Config

include("Config.lua")

// When a players variables get set

function Ratings.PlayerSetVariables(Player)
	CVAR.New(Player, "Ratings", "Ratings", {})
end

// When a players GUI gets updated

function Ratings.PlayerUpdateGUI(Player)
	Player:SetNetworkedString("Rating", "Rating: "..Ratings.Rating(Player))
end

// Largest rating

function Ratings.Rating(Player)
	local Size = 0
	
	local Rating = "None"
	
	local Real = "None"
	
	if not (Player:IsReady()) then return "None" end
	
	for K, V in pairs(CVAR.Request(Player, "Ratings")) do
		if (V > Size) then
			Size = V
			
			Rating = K.." ("..Size..")"
			
			Real = K
		end
	end
	
	for K, V in pairs(Ratings.List) do
		if (string.lower(V) == string.lower(Real)) then
			Rating = V.." ("..Size..")"
		end
	end
	
	return Rating
end

// Rate a player

function Ratings.Rate(Player, Person, Rating)
	local Found = false
	
	for K, V in pairs(Ratings.List) do
		if (string.lower(V) == string.lower(Rating)) then
			Found = V
		end
	end
	
	if not Found then SS.PlayerMessage(Player, "The rating "..Rating.." could not be found", 1) return false end
	
	CVAR.Request(Person, "Ratings")[Found] = CVAR.Request(Person, "Ratings")[Found] or 0
	
	local Plus = CVAR.Request(Person, "Ratings")[Found] + 1
	
	CVAR.Request(Person, "Ratings")[Found] = Plus
	
	SS.PlayerMessage(0, Player:Name().." rated "..Person:Name().." "..Found, 0)
	
	SS.Player.PlayerUpdateGUI(Person)
	
	SS.Hooks.Run("PlayerGivenRating", Player, Person, Found)
	
	return true
end

Ratings:Create()

SS.Adverts.Add("This server is using the Ratings plugin!")