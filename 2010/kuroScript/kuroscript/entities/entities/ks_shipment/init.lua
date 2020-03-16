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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetHealth(50);
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
function ENT:SetItem(item, batch)
	local itemTable = kuroScript.item.Get(item);
	
	-- Check if a statement is true.
	if (itemTable) then
		self._Inventory = {};
		self._Weight = itemTable.weight * batch;
		self._Item = itemTable;
		
		-- Set some information.
		self._Inventory[self._Item.uniqueID] = batch;
		
		-- Set some information.
		self:SetModel(itemTable.shipmentModel or MODEL_SHIPMENT);
		self:SetSharedVar("ks_Index", itemTable.index);
	end;
end;

-- A function to explode the entity.
function ENT:Explode(scale)
	local effectData = EffectData();
	
	-- Set some information.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(scale or 8);
	
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

-- Called when the entity is removed.
function ENT:OnRemove()
	local k, v;
	local i;
	
	-- Loop through each value in a table.
	if (self._Inventory) then
		for k, v in pairs(self._Inventory) do
			if (v > 0) then
				for i = 1, v do
					local item = kuroScript.entity.CreateItem( nil, k, self:GetPos() + Vector( 0, 0, math.random(1, 48) ), self:GetAngles() );
					
					-- Copy the entity's owner.
					kuroScript.entity.CopyOwner(self, item);
				end;
			end;
		end;
		
		-- Set some information.
		self._Inventory = nil;
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		activator:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
		
		-- Open storage for the player.
		kuroScript.player.OpenStorage( activator, {
			name = "Shipment",
			weight = self._Weight,
			entity = self,
			distance = 192,
			inventory = self._Inventory,
			OnClose = function(player, storageTable, entity)
				if ( ValidEntity(self) ) then
					if (!self._Inventory or table.Count(self._Inventory) == 0) then
						self:Explode(self:BoundingRadius() * 2);
						self:Remove();
					end;
				end;
			end,
			CanGive = function(player, storageTable, itemTable)
				return false;
			end
		} );
	end;
end;