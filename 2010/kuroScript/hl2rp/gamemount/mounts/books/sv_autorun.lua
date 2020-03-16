--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Add some hints.
kuroScript.hint.Add("Books", "Invest in a book, give your character some knowledge.");

-- Hook a data stream.
datastream.Hook("ks_TakeBook", function(player, handler, uniqueID, rawData, procData)
	if ( ValidEntity(procData) ) then
		if (procData:GetClass() == "ks_book") then
			if ( player:GetPos():Distance( procData:GetPos() ) <= 192 and player:GetEyeTraceNoCursor().Entity == procData) then
				local success, fault = kuroScript.inventory.Update(player, procData._Book.uniqueID, 1);
				
				-- Check if a statement is true.
				if (!success) then
					kuroScript.player.Notify(player, fault);
				else
					procData:Remove();
				end;
			end;
		end;
	end;
end);

-- A function to load the books.
function MOUNT:LoadBooks()
	local books = kuroScript.frame:RestoreGameData( "mounts/books/"..game.GetMap() );
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(books) do
		if ( kuroScript.item.stored[v.book] ) then
			local entity = ents.Create("ks_book");
			
			-- Give the property to an offline player.
			kuroScript.player.GivePropertyOffline(v.key, v.uniqueID, entity);
			
			-- Set some information.
			entity:SetAngles(v.angles);
			entity:SetBook(v.book);
			entity:SetPos(v.position);
			entity:Spawn();
			
			-- Check if a statement is true.
			if (!v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the books.
function MOUNT:SaveBooks()
	local books = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_book") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		-- Check if a statement is true.
		if ( ValidEntity(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		-- Set some information.
		books[#books + 1] = {
			key = kuroScript.entity.QueryProperty(v, "key"),
			book = v._Book.uniqueID,
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/books/"..game.GetMap(), books);
end;