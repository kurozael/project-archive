SS.Purchase          = {} -- Purchase table
SS.Purchase.List     = {} -- Where purchases are stored
SS.Purchase.Packages = {} -- Packages table

------------------------------------------------
----[ ADD A NEW PURCHASE ]---------
------------------------------------------------

function SS.Purchase.Add(Index, Price, Groups, Category, Friendly, Description, Condition, Rem)
	Price = (Price * SS.Config.Request("Points Given"))
	
	table.insert(SS.Purchase.List, {Index, Price, Groups, Category, Friendly, Description, Condition, Rem})
end

-------------------------------------------------------------
----[ INITIATE NEW PURCHASE FILE ]---------
-------------------------------------------------------------

function SS.Purchase:New(Index, Friendly)
	local Table = {}
	
	setmetatable(Table, self)
	
	self.__index = self
	
	Index = string.lower(Index)
	
	Table.Name = Index
	
	Table.Friendly = Friendly
	
	return Table
end

-------------------------------------------------------------
----[ PURCHASE CATEGORIES ]-------------------
-------------------------------------------------------------

function SS.Purchase.Categories()
	local Categories = {}
	
	for K, V in pairs(SS.Purchase.List) do
		local Cat = V[4]
		
		Categories[Cat] = Categories[Cat] or {}
		
		local Friendly = V[5]
		local Index    = V[1]
		local Cost     = V[2]
		local Desc     = V[6]
		local Cond     = V[7]
		
		Categories[Cat][Friendly] = {Cost, Index, Desc, Cond}
	end
	
	return Categories
end

-------------------------------------------------------------
----[ ADD PACKAGE ]----------------------------------
-------------------------------------------------------------

function SS.Purchase.Package(Friendly, ID, Price, Groups, Description, ...)
	ID = string.lower(ID)
	
	local Items = {}
	
	for I = 1, table.getn(arg) do
		Items[I] = string.lower(arg[I])
	end
	
	SS.Purchase.Packages[ID] = Items
	
	local Purchase = SS.Purchase:New(ID, Friendly) Purchase:Create(Price, Groups, "Packages", Description)
end

-------------------------------------------------------------
----[ FINALISE ADDING PURCHASE ]-----------
-------------------------------------------------------------

function SS.Purchase:Create(Cost, Groups, Category, Description)
	self.Condition = self.Condition or function() return true end
	
	self.Remove = self.Remove or function() end
	
	SS.Purchase.Add(self.Name, Cost, Groups, Category, self.Friendly, Description, self.Condition, self.Remove)
end

-------------------------------------------------------------
----[ HAS PURCHASE ]--------------------------------
-------------------------------------------------------------

function SS.Purchase.Has(Player, Index)
	Index = string.lower(Index)
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return false end
	
	local Purchases = CVAR.Request(Player, "Purchases")
	
	for K, V in pairs(Purchases) do
		if (V == Index) then
			return true
		end
	end
	
	for K, V in pairs(SS.Purchase.List) do
		if (V[1] == Index) then
			if (SS.Flags.PlayerHas(Player, V[3])) then
				return true
			end
		end
	end
	
	return false
end

-------------------------------------------------------------
----[ PURCHASES MENU ]---------------------------
-------------------------------------------------------------

function SS.Purchase.Menu(Player, Command, Args)
	if not (Args) or not (Args[1]) then SS.PlayerMessage(Player, "You must enter the index of the purchase!", 1) return end
	
	for K, V in pairs(SS.Purchase.List) do
		if (Args[1] == V[1]) then
			if (SS.Purchase.Has(Player, V[1])) or not (V[7](Player, V[1])) then
				SS.PlayerMessage(Player, "You already have "..V[1].."!", 1)
				
				return
			end
			
			if (CVAR.Request(Player, "Points") >= V[2]) then
				CVAR.Update(Player, "Points", CVAR.Request(Player, "Points") - V[2])
				
				SS.PlayerMessage(Player, "You have purchased "..V[5].."!", 0)
				
				SS.Purchase.Give(Player, V[1], V[5])
				
				SS.Player.PlayerUpdateGUI(Player)
			else
				local Needed = V[2] - CVAR.Request(Player, "Points")
				
				SS.PlayerMessage(Player, "You need "..Needed.." more "..SS.Config.Request("Points").."!", 0)
			end
		end
	end
end

concommand.Add("ss_purchase", SS.Purchase.Menu)

---------------------------------------------------------------
----[ ADD PURCHASE TO PLAYER ]------------------
---------------------------------------------------------------

function SS.Purchase.Give(Player, Index, Friendly)
	Index = string.lower(Index)
	
	CVAR.Request(Player, "Purchases")[Index] = Index
	
	if (SS.Purchase.Packages[Index]) then
		for B, J in pairs(SS.Purchase.Packages[Index]) do
			if not (SS.Purchase.Has(Player, J)) then
				SS.Purchase.Give(Player, J)
			end
		end
	end
	
	SS.Hooks.Run("PlayerGivenPurchase", Player, Index, Friendly)
end

-------------------------------------------------------------
----[ REMOVE PURCHASE ]--------------------------
-------------------------------------------------------------

function SS.Purchase.Remove(Player, Index)
	Index = string.lower(Index)
	
	local Ready = Player:IsReady()
	
	if not (Ready) then return false end
	
	for K, V in pairs(SS.Purchase.List) do
		if (V[1] == Index) then
			V[8](Player, Index)
		end
	end
	
	CVAR.Request(Player, "Purchases")[Index] = nil
end

--------------------------------------------------------------------------------------
----[ CHECK IF A PLAYER SHOULD GET A FREE PURCHASE ]-------
--------------------------------------------------------------------------------------

function SS.Purchase.Free(Player)
	CVAR.New(Player, "Purchases", "Purchases", {})
	
	for K, V in pairs(CVAR.Request(Player, "Purchases")) do
		if (SS.Purchase.Packages[V]) then
			for B, J in pairs(SS.Purchase.Packages[V]) do
				if not (SS.Purchase.Has(Player, J)) then
					SS.Purchase.Give(Player, J)
				end
			end
		end
	end
	
	SS.Hooks.Run("PlayerGiveFreePurchases", Player)
end

-------------------------------------------------------------------------------------------------------------------------------------------
----[ HOOK INTO PLAYER VALUES AND GIVE FREE PURCHASES AND CREATE PURCHASES TABLE ]-------
-------------------------------------------------------------------------------------------------------------------------------------------

SS.Hooks.Add("SS.Purchases.Free", "PlayerSetVariables", SS.Purchase.Free)