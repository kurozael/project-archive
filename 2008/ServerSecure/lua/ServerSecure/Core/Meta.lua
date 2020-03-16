// Meta table ajustments

local Meta = FindMetaTable("Player")

// Include

function Meta:IncludeFile(File)
	umsg.Start("Include.File", self)
		umsg.String(File)
	umsg.End()
end

// PropSecure

function Meta:PropSecureIsPlayers(Entity)
	if (PropSecure) then
		if not (SS.Flags.PlayerHas(self, "propsecure")) then
			if not (PropSecure.IsPlayers(self, Entity)) then
				return false
			end
		end
	end
	
	return true
end

// Play a sound

function Meta:PlaySound(Sound)
	umsg.Start("SS.GUI.PlaySound", Player)
		umsg.String(Sound)
	umsg.End()
end

// Trace

function Meta:TraceLine()
	local Trace = util.GetPlayerTrace(self)
	
	return util.TraceLine(Trace)
end

// Delete when killed

function Meta:RemoveWhenKilled(Entity)
	TVAR.New(self, "RemoveWhenKilled", {})
	
	local Index = Entity:EntIndex()
	
	TVAR.Request(self, "RemoveWhenKilled")[Index] = Entity
end

// Set controlling entity

function Meta:SetControllingEntity(Entity)
	self:SetNetworkedEntity("GetControllingEntity", Entity)
end

// Get controlling entity

function Meta:GetControllingEntity()
	return self:GetNetworkedEntity("GetControllingEntity")
end

// Player is ready

function Meta:IsReady()
	local Identity = self:SteamID()
	
	if (CVAR.Store[Identity]) then
		return true
	end
	
	return false
end

// Hide GUI

function Meta:HideGUI(Type, Bool)
	local Number = 1
	
	if not (Bool) then
		Number = 0
	end
	
	self:SetNetworkedInt("Hide: "..Type, Number)
end

// Return chat value

function Meta:GetTextReturn()
	local Return = TVAR.Request(self, "TextReturnValue")
	
	return Return
end

// Set return chat value

function Meta:SetTextReturn(Return, Priority)
	local Backup = self:GetTextReturn()
	
	if (Backup) then
		if (Backup[2] < Priority) then
			return
		end
	end
	
	TVAR.Update(self, "TextReturnValue", {Return, Priority})
end