--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.mission = Clockwork:NewLibrary("Mission");
Clockwork.mission.locations = {};
Clockwork.mission.stored = {};

-- A function to create a new mission.
function Clockwork.mission:New()
	local missionTable = {
		description = "An undescribed mission.",
		name = "Unknown"
	};
	
	missionTable.GetDescription = function(missionTable)
		return missionTable.description;
	end;
	
	missionTable.GetLocations = function(missionTable)
		if (self.locations[missionTable.name]) then
			return self.locations[missionTable.name];
		else
			return self.locations["Default"];
		end;
	end;
	
	missionTable.GetName = function(missionTable)
		return missionTable.name;
	end;
	
	missionTable.Register = function(missionTable)
		self:Register(missionTable);
	end;
	
	missionTable.Stop = function(missionTable)
		self:Set(false);
	end;
	
	return missionTable;
end;

-- A function to register a new mission.
function Clockwork.mission:Register(missionTable)
	self.stored[missionTable.name] = missionTable;
end;

-- A function to find an mission by ID.
function Clockwork.mission:FindByID(identifier)
	if (self.stored[identifier]) then
		return self.stored[identifier];
	end;
	
	for k, v in pairs(self.stored) do
		if (string.lower(v.name) == string.lower(identifier)) then
			return v;
		end;
	end;
end;

-- A function to get a random mission.
function Clockwork.mission:GetRandomMission()
	local availableMissions = {};
	
	for k, v in pairs(self.stored) do
		if (!v.CanStart or v:CanStart()) then
			availableMissions[#availableMissions + 1] = v;
		end;
	end;
	
	if (#availableMissions > 0) then
		return availableMissions[math.random(1, #availableMissions)];
	end;
end;

-- A function to set the active mission.
function Clockwork.mission:Set(missionTable)
	local stopText = "This mission is now over.";
	
	if (type(missionTable) == "string") then
		missionTable = self:FindByID(missionTable);
	end;
	
	if (self.active and self.active.OnStop) then
		stopText = self.active:OnStop() or stopText;
	end;
	
	if (SERVER) then
		if (self.active) then
			umsg.Start("cwStopMission");
				umsg.String(stopText);
			umsg.End();
		end;
		
		Clockwork:DestroyTimer("Mission");
	end;
	
	if (!missionTable) then
		Clockwork.plugin:Remove("Mission");
			self.active = nil;
		return false;
	end;
	
	self.active = table.Copy(missionTable);
	
	if (SERVER) then
		if (self.active.CanStart
		and !self.active:CanStart()) then
			self.active = nil;
			return false;
		end;
		
		umsg.Start("cwStartMission");
			umsg.String(missionTable.name);
		umsg.End();
		
		if (self.active.playTime) then
			Clockwork:CreateTimer("Mission", self.active.playTime, 1, function()
				self.active:Stop();
			end);
		end;
	end;
	
	if (self.active.OnStart) then
		self.active:OnStart();
	end;
	
	Clockwork.plugin:Add("Mission", self.active);
	return true;
end;

-- A function to get the active mission.
function Clockwork.mission:Get()
	return self.active;
end;

--[[ Include all the custom missions from the schema folder. --]]
Clockwork:IncludeDirectory(Clockwork:GetSchemaFolder("missions"));

if (SERVER) then
	function Clockwork.mission:PrintCenter(player, text, subText)
		umsg.Start("cwPrintCenter", player);
			umsg.String(text);
			umsg.String(subText);
		umsg.End();
	end;
else
	usermessage.Hook("cwStartMission", function(msg)
		local missionTable = Clockwork.mission:FindByID(msg:ReadString());
			Clockwork.mission:Set(missionTable);
		Schema:PrintTextCenter(
			missionTable:GetName(), missionTable:GetDescription(), "hl1/fvox/activated.wav"
		);
	end);
	
	usermessage.Hook("cwStopMission", function(msg)
		local missionTable = Clockwork.mission:Get();
		
		if (missionTable) then
			Schema:PrintTextCenter(
				missionTable:GetName(), msg:ReadString(), "hl1/fvox/deactivated.wav"
			);
		end;
		
		Clockwork.mission:Set(false);
	end);
end;