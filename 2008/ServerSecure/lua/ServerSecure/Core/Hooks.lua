SS.Hooks      = {} -- Hooks.
SS.Hooks.List = {} -- Where hooks are stored

------------------------------------------------
----[ ADD A HOOK ]----------------------
------------------------------------------------

function SS.Hooks.Add(Unique, ID, Function)
	table.insert(SS.Hooks.List, {ID, Function, Unique})
end

------------------------------------------------
----[ REMOVE A HOOK ]----------------------
------------------------------------------------

function SS.Hooks.Remove(ID)
	for K, V in pairs(SS.Hooks.List) do
		if (V[3] == ID) then
			table.remove(SS.Hooks.List, K)
		end
	end
end

---------------------------------------------------------------
----[ RUN HOOKS ]--------------------------------------
---------------------------------------------------------------

function SS.Hooks.Run(ID, ...)
	for K, V in pairs(SS.Hooks.List) do
		if (V[1] == ID) then
			if V[2] != nil then
				arg = arg or {}
				
				local B, Retval = pcall(V[2], unpack(arg))
				
				if not B then
					SS.Lib.Error("HOOK ERROR, "..tostring(Retval).."!")
				end
				
			else
				SS.Lib.Error("HOOK ERROR "..ID.." NO FUNCTION! REMOVING HOOK!")
				
				SS.Hooks.List[K] = nil
			end
		end
	end
	
	if (ID != "ServerHook") then
		SS.Hooks.Run("ServerHook", ID, unpack(arg))
	end
end