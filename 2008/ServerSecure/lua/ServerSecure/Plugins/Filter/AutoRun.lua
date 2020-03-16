Filter = SS.Plugins:New("Filter")

// Words

include("Config.lua")

// When player says something

function Filter.PlayerTypedText(Player, Text)
	Text = string.gsub(Text, "(.+)", " %1 ")
	
	for K, V in pairs(Filter.Words) do
		Text = string.gsub(Text, "(%s)"..V[1].."(%s)", "%1"..V[2].."%1")
	end
	
	local Capital = string.sub(Text, 0, 2)
	
	local Higher = string.upper(Capital)
	
	Text = SS.Lib.StringReplace(Text, Capital, Higher, 1)
	
	Text = string.sub(Text, 2, -2)
	
	if not string.find(string.sub(Text, -1), "%p") then
		Text = Text.."."
	end
	
	local Backup = Player:GetTextReturn()
	
	if not (Backup) then
		Player:SetTextReturn(Text, 4)
	end
end

Filter:Create()