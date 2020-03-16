--[[
Name: "sh_junk_base.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.name = "Book Base";
ITEM.weight = 0.4;
ITEM.access = "i3";
ITEM.category = "Books";
ITEM.isBaseItem = true;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	
	-- Check if a statement is true.
	if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
		local entity = ents.Create("ks_book");
		
		-- Give the property to the player.
		kuroScript.player.GiveProperty(player, entity);
		
		-- Set some information.
		entity:SetModel(self.model);
		entity:SetBook(self.uniqueID);
		entity:SetPos(trace.HitPos);
		entity:Spawn();
		
		-- Check if a statement is true.
		if ( ValidEntity(itemEntity) ) then
			local physicsObject = itemEntity:GetPhysicsObject();
			
			-- Set some information.
			entity:SetPos( itemEntity:GetPos() );
			entity:SetAngles( itemEntity:GetAngles() );
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				if ( !physicsObject:IsMoveable() ) then
					physicsObject = entity:GetPhysicsObject();
					
					-- Check if a statement is true.
					if ( ValidEntity(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			end;
		else
			kuroScript.entity.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
		end;
	else
		kuroScript.player.Notify(player, "You cannot drop a book that far away!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when the item should be setup.
function ITEM:OnSetup()
	if (self.bookInformation) then
		self.bookInformation = string.gsub( string.gsub(self.bookInformation, "\n", "<br>"), "\t", string.rep("&nbsp;", 4) );
		self.bookInformation = "<html><font face='Arial' size='2'>"..self.bookInformation.."</font></html>";
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);