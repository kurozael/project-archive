--[[
Name: "sv_autorun.lua".
Product: "HL2 RP".
--]]

kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- Set some information.
AddCSLuaFile("cl_autorun.lua");
AddCSLuaFile("sh_autorun.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	-- Set some information.
	self:SetModel("models/props_interiors/vendingmachinesoda01a.mdl");
	
	-- Set some information.
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetStock(0, true);
end;

-- A function to create the entity's water.
function ENT:CreateWater(activator)
	self:GiveStock(-1);
	self:EmitSound("buttons/button4.wav");
	self:SetFlashDuration(3, true);
	
	-- Set some information.
	local forward = self:GetForward() * 18;
	local chance = math.random(1, 20);
	local right = self:GetRight() * 3;
	local up = self:GetUp() * -24;
	
	-- Check if a statement is true.
	if (chance == 20) then
		kuroScript.entity.CreateItem( activator, "special_breens_water", self:GetPos() + forward + right + up, self:GetAngles() );
	elseif (chance >= 10) then
		kuroScript.entity.CreateItem( activator, "smooth_breens_water", self:GetPos() + forward + right + up, self:GetAngles() );
	else
		kuroScript.entity.CreateItem( activator, "breens_water", self:GetPos() + forward + right + up, self:GetAngles() );
	end;
end;

-- A function to get the entity's default stock.
function ENT:GetDefaultStock()
	return self._DefaultStock or 0;
end;

-- A function to give stock to the entity.
function ENT:GiveStock(amount)
	self:SetStock( math.Clamp( self:GetStock() + amount, 0, self:GetDefaultStock() ) );
end;

-- A function to set the entity's stock.
function ENT:SetStock(amount, default)
	self:SetSharedVar("ks_Stock", amount);
	
	-- Check if a statement is true.
	if (default) then
		if (type(default) == "number") then
			self._DefaultStock = default;
		else
			self._DefaultStock = amount;
		end;
	end;
end;

-- A function to restock the entity.
function ENT:Restock()
	self:SetFlashDuration(3, true);
	self:EmitSound("buttons/button5.wav");
	self:SetStock( self:GetDefaultStock() );
end;

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration, action)
	self:SetSharedVar("ks_Flash", CurTime() + duration);
	
	-- Check if a statement is true.
	if (action) then
		self:SetSharedVar("ks_Action", true);
	else
		self:EmitSound("buttons/button2.wav");
		
		-- Set some information.
		self:SetSharedVar("ks_Action", false);
	end;
end;

-- Called when the entity's physics should be updated.
function ENT:PhysicsUpdate(physicsObject)
	if ( !self:IsPlayerHolding() and !self:IsConstrained() ) then
		physicsObject:SetVelocity( Vector(0, 0, 0) );
		physicsObject:Sleep();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		local curTime = CurTime();
		
		-- Check if a statement is true.
		if (!self._NextUse or curTime >= self._NextUse) then
			if ( curTime > self:GetSharedVar("ks_Flash") ) then
				self._NextUse = curTime + 3;
				
				-- Check if a statement is true.
				if ( !kuroScript.game:PlayerIsCombine(activator) ) then
					if ( self:GetStock() == 0 or !kuroScript.player.CanAfford(activator, 5) ) then
						self:SetFlashDuration(3);
					elseif (!activator._NextVendingMachine or curTime >= activator._NextVendingMachine) then
						self:CreateWater(activator);
						
						-- Set some information.
						activator._NextVendingMachine = curTime + 600;
						
						-- Give the player currency.
						kuroScript.player.GiveCurrency(activator, -5, "Breen's Water");
					else
						self:SetFlashDuration(3);
					end;
				elseif (self:GetStock() == 0) then
					self:Restock();
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false;
end;