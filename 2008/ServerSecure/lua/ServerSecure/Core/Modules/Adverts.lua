------------------------------------------------
----[ ADVERT VARIABLES ]-------------
------------------------------------------------

SS.Adverts = {} -- Adverts table

SS.Adverts.List = {} -- Adverts list

// Add advert

function SS.Adverts.Add(Text)
	table.insert(SS.Adverts.List, Text)
end

// Run adverts

function SS.Adverts.ServerMinute()
	SS.Lib.Debug("Now showing all players a random advert!")
	
	if (table.Count(SS.Adverts.List) != 0) then
		SS.ServerTicker(0, SS.Config.Request("Advert Prefix").." "..SS.Lib.RandomTableEntry(SS.Adverts.List), 10)
	end
end

// Hook into server minute

SS.Hooks.Add("SS.Adverts.ServerMinute", "ServerMinute", SS.Adverts.ServerMinute)
