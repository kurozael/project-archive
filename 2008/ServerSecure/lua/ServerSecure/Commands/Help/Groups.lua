------------------------------------------------
----[ GROUPS ]-----------------------------
------------------------------------------------

local Groups = SS.Commands:New("Groups")

// View groups

function Groups.View(Player, Command, Args)
	if Args == nil then return end
	
	for K, V in pairs(SS.Groups.List) do
		if (Args[1] == V[1]) then
			local Panel = SS.Panel:New(Player, V[1])
			
			Panel:Words("Rank: "..V[6])
			
			if (table.Count(V[8]) > 0) then
				Panel:Words("Flags: "..table.concat(V[8], ", "))
			end
			
			if (V[4] != "") then
				Panel:Words("Model: "..V[4])
			end
			
			Panel:Send()
			
			return
		end
	end
	
	SS.PlayerMessage(Player, "Couldn't find this group!", 1)
end

concommand.Add("ss_viewgroups", Groups.View)

// Command

function Groups.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Groups")
	
	local Sort = SS.Groups.List
	
	table.sort(Sort, function(A, B) return SS.Groups.Rank(A[1]) < SS.Groups.Rank(B[1]) end)
	
	for K, V in pairs(Sort) do
		local Col = V[4]
		
		Panel:Button(V[1], 'ss_viewgroups "'..V[1]..'"', Col.r, Col.g, Col.b)
	end
	
	Panel:Send()
end

Groups:Create(Groups.Command, {"basic"}, "View available groups")