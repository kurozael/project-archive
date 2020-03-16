--[[
Name: "cl_overwatch.lua".
Product: "nexus".
--]]

nexus.overwatch = {};
nexus.overwatch.stored = {};

-- A function to get all overwatches.
function nexus.overwatch.GetAll()
	return nexus.overwatch.stored;
end;

-- A function to get an overwatch.
function nexus.overwatch.Get(name)
	return nexus.overwatch.stored[name];
end;

-- A function to get the overwatch panel.
function nexus.overwatch.GetPanel()
	if ( IsValid(nexus.overwatch.panel) ) then
		return nexus.overwatch.panel;
	end;
end;

-- A function to rebuild an overwatch.
function nexus.overwatch.Rebuild(name)
	local panel = nexus.overwatch.GetPanel();
	
	if (panel and nexus.overwatch.GetActive() == name) then
		panel:Rebuild();
	end;
end;

-- A function to get the active overwatch.
function nexus.overwatch.GetActive()
	local panel = nexus.overwatch.GetPanel();
	
	if (panel) then
		return panel.overwatch;
	end;
end;

-- A function to set the active overwatch.
function nexus.overwatch.SetActive(name)
	local panel = nexus.overwatch.GetPanel();
	
	if (panel) then
		panel.overwatch = name;
		panel:Rebuild();
	end;
end;

-- A function to register a new overwatch.
function nexus.overwatch.Register(overwatch)
	nexus.overwatch.stored[overwatch.name] = overwatch;
	
	if (!overwatch.HasAccess) then
		function overwatch:HasAccess()
			return nexus.player.HasFlags(g_LocalPlayer, self.access);
		end;
	end;
	
	-- A function to get whether the overwatch is active.
	function overwatch:IsActive()
		local activeOverwatch = nexus.overwatch.GetActive();
		
		if (activeOverwatch == self.name) then
			return true;
		else
			return false;
		end;
	end;
	
	-- A function to rebuild the overwatch.
	function overwatch:Rebuild()
		nexus.overwatch.Rebuild(self.name);
	end;
end;