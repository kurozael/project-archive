--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.system = {};
CloudScript.system.stored = {};

-- A function to get all systems.
function CloudScript.system:GetAll()
	return self.stored;
end;

-- A function to get a new system.
function CloudScript.system:New()
	return {};
end;

-- A function to get an system.
function CloudScript.system:Get(name)
	return self.stored[name];
end;

-- A function to get the system panel.
function CloudScript.system:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to rebuild an system.
function CloudScript.system:Rebuild(name)
	local panel = self:GetPanel();
	
	if (panel and self:GetActive() == name) then
		panel:Rebuild();
	end;
end;

-- A function to get the active system.
function CloudScript.system:GetActive()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.system;
	end;
end;

-- A function to set the active system.
function CloudScript.system:SetActive(name)
	local panel = self:GetPanel();
	
	if (panel) then
		panel.system = name;
		panel:Rebuild();
	end;
end;

-- A function to register a new system.
function CloudScript.system:Register(system)
	self.stored[system.name] = system;
	
	if (!system.HasAccess) then
		system.HasAccess = function(systemTable)
			return CloudScript.player:HasFlags(CloudScript.Client, systemTable.access);
		end;
	end;
	
	-- A function to get whether the system is active.
	system.IsActive = function(systemTable)
		local activeAdmin = self:GetActive();
		
		if (activeAdmin == systemTable.name) then
			return true;
		else
			return false;
		end;
	end;
	
	-- A function to rebuild the system.
	system.Rebuild = function(systemTable)
		self:Rebuild(systemTable.name);
	end;
end;