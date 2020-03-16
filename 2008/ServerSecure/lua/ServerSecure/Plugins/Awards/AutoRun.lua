SS.Awards = SS.Plugins:New("Awards")

// Awards

SS.Awards.List = {}

function SS.Awards.Add(ID)
	SS.Awards.List[ID] = {ID, ""}
end

// Include

include("Config.lua")

// When players values get set

function SS.Awards.PlayerSetVariables(Player)
	CVAR.New(Player, "Awards", "Awards", {})
end

// When players GUI is updated

function SS.Awards.PlayerUpdateGUI(Player)
	local Awards = CVAR.Request(Player, "Awards")
	
	local Count = 0
	
	for K, V in pairs(Awards) do
		Count = Count + V
	end
	
	Player:SetNetworkedString("Awards", "Awards: "..Count)
end

// Find

function SS.Awards.Find(ID)
	for K, V in pairs(SS.Awards.List) do
		if (string.lower(K) == string.lower(ID)) then
			return K
		end
	end
	
	return ID
end

// Award

function SS.Awards.Award(Player, Args)
	if not (Args) or not (Args[1]) or not (Args[2]) or not (Args[3]) then return end
	
	if not (SS.Flags.PlayerHas(Player, "Award")) then SS.PlayerMessage(Player, "You need to have the award flag!", 1) return end
	
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		for K, V in pairs(SS.Awards.List) do
			if (Args[2] == V[1]) then
				local Index = string.lower(V[1])
				
				if (Args[3] == "1") then
					CVAR.Request(Person, "Awards")[Index] = CVAR.Request(Person, "Awards")[Index] or 0
					
					CVAR.Request(Person, "Awards")[Index] = CVAR.Request(Person, "Awards")[Index] + 1
					
					SS.PlayerMessage(0, Player:Name().." gave "..Person:Name().." the "..V[1].." award!", 0)
				elseif (Args[3] == "0") then
					if not (CVAR.Request(Person, "Awards")[Index]) then
						SS.PlayerMessage(Player, Person:Name().." doesn't have the "..V[1].." award!", 1)
					else
						CVAR.Request(Person, "Awards")[Index] = CVAR.Request(Person, "Awards")[Index] - 1
						
						if (CVAR.Request(Person, "Awards")[Index] <= 0) then
							CVAR.Request(Person, "Awards")[Index] = nil
						end
						
						SS.PlayerMessage(0, Player:Name().." has taken one of "..Person:Name().."'s "..V[1].." awards!", 0)
					end
				end
				
				SS.Player.PlayerUpdateGUI(Person)
			end
		end
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

SS.ConsoleCommand.Simple("awardcommand", SS.Awards.Award, 3)

// Branch flag

SS.Flags.Branch("Administrator", "Award")

// Chat command

local GiveAward = SS.Commands:New("GiveAward")

function GiveAward.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local ID = Person:Name()
		
		local Panel = SS.Panel:New(Player, "Give Award: "..ID)
		
		for K, V in pairs(SS.Awards.List) do
			Panel:Button(V[1], 'ss awardcommand "'..Args[1]..'" "'..V[1]..'" "1"')
		end
		
		Panel:Send()
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

GiveAward:Create(GiveAward.Command, {"administrator", "award"}, "Give an award to somebody", "<Player>", 1, " ")

// Branch flag

SS.Flags.Branch("Administrator", "TakeAward")

// Chat command

local TakeAward = SS.Commands:New("TakeAward")

function TakeAward.Command(Player, Args)
	local Person, Error = SS.Lib.Find(Args[1])
	
	if (Person) then
		local ID = Person:Name()
		
		local Found = false
		
		local Panel = SS.Panel:New(Player, "Take Award: "..ID)
		
		for K, V in pairs(CVAR.Request(Person, "Awards")) do
			local Award = SS.Awards.Find(K)
			
			Panel:Button(Award, 'ss awardcommand "'..Args[1]..'" "'..Award..'" "0"')
			
			Found = true
		end
		
		if not (Found) then
			Panel:Words("This player does not have any awards!")
		end
		
		Panel:Send()
	else
		SS.PlayerMessage(Player, Error, 1)
	end
end

TakeAward:Create(TakeAward.Command, {"administrator", "award"}, "Take an award from somebody", "<Player>", 1, " ")

// Finish Awards

Awards:Create()