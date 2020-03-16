------------------------------------------------
----[ PURCHASE ]----------------------------------
------------------------------------------------

local Purchase = SS.Commands:New("Purchase")

// Purchase command

function Purchase.Command(Player, Args)
	local Panel = SS.Panel:New(Player, "Purchase Categories")
	
	local Cat = SS.Purchase.Categories()
	
	for K, V in pairs(Cat) do
		Panel:Button(K, 'ss_showcategory "'..K..'"')
	end
	
	Panel:Send()
end

// Category

function Purchase.Category(Player, Command, Args)
	if not (Args) or not (Args[1]) then SS.PlayerMessage(Player, "You must enter the name of the category!", 1) return end
	
	local Index = Args[1]
	
	if not SS.Purchase.Categories()[Index] then
		SS.PlayerMessage(Player, "The purchase category '"..Index.."' doesn't exist!", 1)
	else
		local Panel = SS.Panel:New(Player, "Purchase ("..Index..")")
		
		local Added = false
		
		local Sort = SS.Purchase.Categories()[Index]
		
		table.sort(Sort, function(A, B) return (A[1] > B[1]) end)
		
		for K, V in pairs(Sort) do
			if not (SS.Purchase.Has(Player, V[2])) and (V[4](Player, V[2])) then
				Panel:Words(V[3])
				
				Panel:Button(K.." ("..V[1].." "..SS.Config.Request("Points")..")", 'ss_purchase "'..V[2]..'"')
				
				Added = true
			end
		end
		
		if not (Added) then
			Panel:Words("You have purchased everything in this category!")
		end
		
		Panel:Send()
	end
end

concommand.Add("ss_showcategory", Purchase.Category)

// Create it

Purchase:Create(Purchase.Command, {"basic"}, "View the purchases menu")

// Advert

SS.Adverts.Add("Type "..SS.Commands.Prefix().."purchase to access the purchases menu!")