------------------------------------------------
----[ SELECT ]-----------------------------
------------------------------------------------

local Select = SS.Commands:New("Select")

// Select command

function Select.Command(Player, Args)
	local TR = Player:TraceLine()
	
	if (TR.Entity and SS.Lib.Valid(TR.Entity)) then
		if (TR.Entity:IsNPC() or TR.Entity:IsPlayer()) then
			SS.PlayerMessage(Player, "You cannot select this entity class!", 1)
			
			return
		end
		
		if not (Player:PropSecureIsPlayers(TR.Entity)) then
			SS.PlayerMessage(Player, "This entity does not belong to you!", 1)
			
			return
		end
		
		local Index = TR.Entity:EntIndex()
		
		TVAR.New(Player, "Selected", {})
		
		if (TVAR.Request(Player, "Selected")[Index]) then
			Player:DeselectEntity(TR.Entity)
		else
			local Select = Player:SelectEntity(TR.Entity)
			
			if not (Select) then
				SS.PlayerMessage("This entity is already selected by another player!")
			end
		end
	else
		SS.PlayerMessage(Player, "You must aim at a valid entity!", 1)
	end
end

Select:Create(Select.Command, {"basic"}, "Select or deselect an entity")

// Meta

local Meta = FindMetaTable("Player")

// Deselect all

function Meta:DeselectEntities()
	local Selected = TVAR.Request(self, "Selected")
	
	local Table = table.Copy(Selected)
	
	local Number = 0
	
	if (Selected) then
		for K, V in pairs(Selected) do
			if (SS.Lib.Valid(V)) then
				self:DeselectEntity(V)
				
				Number = Number + 1
			end
		end
	end
	
	return Number
end

// Selected entities

function Meta:EntitiesSelected()
	local Selected = TVAR.Request(self, "Selected")
	
	if (Selected) then
		for K, V in pairs(Selected) do
			if not (V) or not (SS.Lib.Valid(V)) then
				TVAR.Request(self, "Selected")[K] = nil
			end
		end
		
		if (table.Count(Selected) == 0) then
			return false
		end
	end
	
	return TVAR.Request(self, "Selected")
end

// Remove marker

function Meta:RemoveAxisMarker()
	timer.Remove("Player.CreateAxisMarker: "..self:UniqueID())
	
	if (self.SelectAxisMarker and SS.Lib.Valid(self.SelectAxisMarker)) then
		self.SelectAxisMarker:Remove()
	end
end

// Create marker

function Meta:CreateAxisMarker(Entity)
	local function Func(Player, Entity)
		self:RemoveAxisMarker()
		
		if not (SS.Lib.Valid(Entity)) then return end
		
		local Select = ents.Create("Selection")
		
		Select:SetPos(Entity:GetPos())
		Select:SetAngles(Entity:GetAngles())
		Select:SetParent(Entity)
		
		Select:SetPlayer(self)
		
		Select:Spawn()
		
		Player.SelectAxisMarker = Select
	end
	
	timer.Create("Player.CreateAxisMarker: "..self:UniqueID(), 1, 0, Func, self, Entity)
end

// Select entity

function Meta:SelectEntity(Entity, Bool)
	if not (Entity) or not (SS.Lib.Valid(Entity)) then return false end
	
	if (Entity.PlayerSelected and Entity.PlayerSelected != self and Entity.PlayerSelected:IsConnected()) then
		return false
	end
	
	if (Entity:IsNPC() or Entity:IsPlayer()) then return false end
	
	if not (self:PropSecureIsPlayers(Entity)) then
		return false
	end
	
	local Index = Entity:EntIndex()
	
	TVAR.New(self, "Selected", {})
	
	TVAR.Request(self, "Selected")[Index] = Entity
	
	local R, G, B, A = Entity:GetColor()
	
	Entity.Col = {R, G, B, A}
	
	Entity.Mat = Entity:GetMaterial()
	
	Entity:SetMaterial("models/debug/debugwhite")
	
	Entity:SetColor(175, 255, 100, 255)
	
	Entity.PlayerSelected = self
	
	self:CreateAxisMarker(Entity)
	
	return true
end

// Deselect entity

function Meta:DeselectEntity(Entity)
	local Index = Entity:EntIndex()
	
	TVAR.Request(self, "Selected")[Index] = nil
	
	if (Entity.Mat) then
		local Mat = Entity.Mat
		
		Entity:SetMaterial(Mat)
	end
	
	if (Entity.Col) then
		local Col = Entity.Col
		
		Entity:SetColor(Col[1], Col[2], Col[3], Col[4])
	else
		Entity:SetColor(255, 255, 255, 255)
	end
	
	Entity.PlayerSelected = nil
	
	self:RemoveAxisMarker()
end