SS.Instaban = SS.Plugins:New("Instaban")

// Words

include("Config.lua")

// When player says something

function Filter.PlayerTypedText(Player, Text)
	for K, V in pairs(SS.Instaban.List) do
		if (string.find(string.lower(Text), string.lower(V))) then
			if not (SS.Flags.PlayerHas(Player, "immune")) then
				SS.PlayerMessage(0, Player:Name().." instabanned for "..SS.Instaban.Time.." minutes ("..V..")!", 0)
				
				SS.Lib.PlayerBan(Player, SS.Instaban.Time, V)
				
				break
			end
		end
	end
end

Filter:Create()