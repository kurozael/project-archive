--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.hint:Add("Books", "Invest in a book, give your character some knowledge.");

openAura:HookDataStream("TakeBook", function(player, data)
	if ( IsValid(data) ) then
		if (data:GetClass() == "aura_book") then
			if ( player:GetPos():Distance( data:GetPos() ) <= 192 and player:GetEyeTraceNoCursor().Entity == data) then
				local success, fault = player:UpdateInventory(data.book.uniqueID, 1);
				
				if (!success) then
					openAura.player:Notify(player, fault);
				else
					data:Remove();
				end;
			end;
		end;
	end;
end);

-- A function to load the books.
function PLUGIN:LoadBooks()
	local books = openAura:RestoreSchemaData( "plugins/books/"..game.GetMap() );
	
	for k, v in pairs(books) do
		if ( openAura.item:GetAll()[v.book] ) then
			local entity = ents.Create("aura_book");
			
			openAura.player:GivePropertyOffline(v.key, v.uniqueID, entity);
			
			entity:SetAngles(v.angles);
			entity:SetBook(v.book);
			entity:SetPos(v.position);
			entity:Spawn();
			
			if (!v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the books.
function PLUGIN:SaveBooks()
	local books = {};
	
	for k, v in pairs( ents.FindByClass("aura_book") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;
		
		if ( IsValid(physicsObject) ) then
			moveable = physicsObject:IsMoveable();
		end;
		
		books[#books + 1] = {
			key = openAura.entity:QueryProperty(v, "key"),
			book = v.book.uniqueID,
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;
	
	openAura:SaveSchemaData("plugins/books/"..game.GetMap(), books);
end;