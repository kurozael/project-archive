--[[
Name: "init.lua".
Product: "kuroScript".
--]]

include("sh_init.lua");

-- Add some shared Lua files.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(25);
	self:SetSolid(SOLID_VPHYSICS);
	
	-- Set some information.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if a statement is true.
	if ( ValidEntity(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	-- Check if a statement is true.
	if (self._Item) then
		self:SetSharedVar("ks_Index", self._Item.index);
	end;
end;

-- A function to set the item of the entity.
function ENT:SetItem(item)
	local itemTable = kuroScript.item.Get(item);
	
	-- Check if a statement is true.
	if (itemTable) then
		self._Item = itemTable;
		
		-- Set some information.
		self:SetModel(itemTable.model);
		self:SetSharedVar("ks_Index", itemTable.index);
		
		-- Check if a statement is true.
		if (itemTable.skin) then
			self:SetSkin(itemTable.skin);
		end;
		
		-- Check if a statement is true.
		if (itemTable.OnCreated) then
			itemTable:OnCreated(self);
		end;
	end;
end;

-- A function to explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set some information.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(8);
	
	-- Set some information.
	util.Effect("GlassImpact", effectData);

	-- Emit a sound.
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if a statement is true.
	if (self:Health() <= 0) then
		self:Explode(); self:Remove();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		-- Set some information.
		local itemTable = self._Item;
		local quickUse = activator:KeyDown(IN_SPEED);
		
		-- Check if a statement is true.
		if (itemTable) then
			local canPickup = ( !itemTable.CanPickup or itemTable:CanPickup(activator, quickUse, self) );
			
			-- Check if a statement is true.
			if (canPickup != false) then
				if (canPickup and type(canPickup) == "string") then
					local newItemTable = kuroScript.item.Get(canPickup);
					
					-- Check if a statement is true.
					if (newItemTable) then
						itemTable = newItemTable;
					else
						return;
					end;
				end;
				
				-- Check if a statement is true.
				if (quickUse) then
					activator:SetItemEntity(self);
					
					-- Update the player's inventory.
					kuroScript.inventory.Update(activator, itemTable.uniqueID, 1, true, true);
					
					-- Check if a statement is true.
					if ( !kuroScript.player.RunKuroScriptCommand(activator, "inventory", itemTable.uniqueID, "use") ) then
						kuroScript.inventory.Update(activator, itemTable.uniqueID, -1, true, true);
						
						-- Set some information.
						activator:SetItemEntity(nil);
						
						-- Return to break the function.
						return;
					end;
					
					-- Check if a statement is true.
					if ( activator:GetItemEntity() ) then
						activator:SetItemEntity(nil);
					end;
				else
					local success, fault = kuroScript.inventory.Update(activator, itemTable.uniqueID, 1);
					
					-- Check if a statement is true.
					if (!success) then
						kuroScript.player.Notify(activator, fault);
						
						-- Return to break the function.
						return;
					end;
				end;
				
				-- Check if a statement is true.
				if (!itemTable.OnPickup or itemTable:OnPickup(activator, quickUse, self) != false) then
					self:Remove();
				end;
			end;
		end;
	end;
end;