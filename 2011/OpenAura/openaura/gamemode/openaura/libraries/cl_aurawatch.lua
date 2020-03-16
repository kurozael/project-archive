--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.moderator = {};
openAura.moderator.stored = {};

-- A function to get all moderators.
function openAura.moderator:GetAll()
	return self.stored;
end;

-- A function to get a new moderator.
function openAura.moderator:New()
	return {};
end;

-- A function to get an moderator.
function openAura.moderator:Get(name)
	return self.stored[name];
end;

-- A function to get the moderator panel.
function openAura.moderator:GetPanel()
	if ( IsValid(self.panel) ) then
		return self.panel;
	end;
end;

-- A function to rebuild an moderator.
function openAura.moderator:Rebuild(name)
	local panel = self:GetPanel();
	
	if (panel and self:GetActive() == name) then
		panel:Rebuild();
	end;
end;

-- A function to get the active moderator.
function openAura.moderator:GetActive()
	local panel = self:GetPanel();
	
	if (panel) then
		return panel.moderator;
	end;
end;

-- A function to set the active moderator.
function openAura.moderator:SetActive(name)
	local panel = self:GetPanel();
	
	if (panel) then
		panel.moderator = name;
		panel:Rebuild();
	end;
end;

-- A function to register a new moderator.
function openAura.moderator:Register(moderator)
	self.stored[moderator.name] = moderator;
	
	if (!moderator.HasAccess) then
		moderator.HasAccess = function(moderatorTable)
			return openAura.player:HasFlags(openAura.Client, moderatorTable.access);
		end;
	end;
	
	-- A function to get whether the moderator is active.
	moderator.IsActive = function(moderatorTable)
		local activeAdmin = self:GetActive();
		
		if (activeAdmin == moderatorTable.name) then
			return true;
		else
			return false;
		end;
	end;
	
	-- A function to rebuild the moderator.
	moderator.Rebuild = function(moderatorTable)
		self:Rebuild(moderatorTable.name);
	end;
end;